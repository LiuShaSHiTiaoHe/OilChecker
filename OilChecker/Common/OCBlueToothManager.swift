//
//  OCBlueToothManager.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/3.
//

import UIKit
import CoreBluetooth
import SwiftyUserDefaults
import SVProgressHUD
import Schedule

enum BleSendDataState {
    case RequestDeviceParamers
    case RequestSettingDeviceParamers
    case RequestFueLData
}

protocol OCBlueToothManagerDelegate: NSObjectProtocol {
       
}

private struct OCBlueToothManagerWrapper {
  weak var wrapped: OCBlueToothManagerDelegate?
  init(_ wrapped: OCBlueToothManagerDelegate) {
    self.wrapped = wrapped
  }
}


class OCBlueToothManager: NSObject {

    
    static let shared = OCBlueToothManager()

    //MARK: observers
    private var objservers: [OCBlueToothManagerWrapper] = []
    
    func addObserver(_ observer: OCBlueToothManagerDelegate) {
        objservers.append(OCBlueToothManagerWrapper(observer))
    }
    
    func removeObserver(_ observer: OCBlueToothManagerDelegate){
        objservers.removeAll { (element: OCBlueToothManagerWrapper) -> Bool in
          if let wrapped = element.wrapped {
            return wrapped === observer
          } else {
            // Handle observers who dealloc'd without removing themselves.
            return true
          }
        }
    }
    
    private var bleIsAvailable: Bool = false

    /////////////////////////////////////////////
    let baby = BabyBluetooth.share();
    var currentPeripheral: CBPeripheral!
//    private var sendDataState: BleSendDataState = .RequestDeviceParamers

    private var readCBCharacteristic: CBCharacteristic?
    private var writeCBCharacteristic: CBCharacteristic?
    private var currentDeviceID: String!
    
    private var isReceiveFuelData: Bool = false
    private var receivedFuelDatas:Data = Data.init()

    func startScan(_ deviceID: String) {
        currentDeviceID = deviceID
        receivedFuelDatas = Data.init()
        SVProgressHUD.show()
        SVProgressHUD.dismiss(withDelay: 20) {
            if self.receivedFuelDatas.count == 0 {
                SVProgressHUD.showInfo(withStatus: "搜索不到当前设备")
            }
        }
        addBabyDelegate()
        baby?.channel(BabyChannelHomeIdentifier).scanForPeripherals().begin().stop(20)
    }
    
    func stopScan() {
        baby?.cancelScan()
    }
    
    func connetDevice() {
        guard currentPeripheral != nil else {
            return
        }
        baby?.channel(BabyChannelHomeIdentifier).having(currentPeripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin()
    }
    
    func addBabyDelegate() {
        baby?.setBlockOnCentralManagerDidUpdateStateAtChannel(BabyChannelHomeIdentifier, block: { central in
            if central?.state == .poweredOn  {
                
            }else{
                SVProgressHUD.showInfo(withStatus: "open mobile bluetooth".localized())
            }
        })
        
        //扫描到设备
        baby?.setBlockOnDiscoverToPeripheralsAtChannel(BabyChannelHomeIdentifier, block: { central, peripheral, advertisementData, RSSI in
            guard advertisementData != nil else{
                return
            }
            if let name = advertisementData!["kCBAdvDataLocalName"] as? String {
                if name.contains(self.currentDeviceID) {
                    if peripheral != nil {
                        self.currentPeripheral = peripheral
                        self.stopScan()
                        self.connetDevice()
                    }
                }
//                if name == "BT-" + self.currentDeviceID {
//                    if peripheral != nil {
//                        self.currentPeripheral = peripheral
//                        self.stopScan()
//                        self.connetDevice()
//                    }
//                }
            }
        })
        
        //设备连接成功
        baby?.setBlockOnConnectedAtChannel(BabyChannelHomeIdentifier, block: { central, peripheral in
            logger.info("设备连接成功")
            SVProgressHUD.showSuccess(withStatus: "Successfully connected the device".localized())
            self.currentPeripheral = peripheral!

        })
        
        baby?.setBlockOnFailToConnectAtChannel(BabyChannelHomeIdentifier, block: { central, peripheral, error in
            SVProgressHUD.showError(withStatus: "Failed to connect device".localized())
        })
        

        baby?.setFilterOnDiscoverPeripheralsAtChannel(BabyChannelHomeIdentifier, filter: { (name, advertisementData, RSSi) -> Bool in

            logger.info("扫描到设备 + name:\(name ?? "")\n advertisementData: \(String(describing: advertisementData)) \r\n")
            if advertisementData == nil {
                return false
            }
            if advertisementData!.has(key: "kCBAdvDataServiceUUIDs") {
                let serviceUUIDs = advertisementData!["kCBAdvDataServiceUUIDs"] as? [CBUUID]
                if serviceUUIDs != nil && serviceUUIDs!.count > 0{
                    let serviceuuid = serviceUUIDs!.first
                    if serviceuuid!.uuidString == ServiceUUIDString {
                        return true
                    }
                }
            }
            
            return false
        })
        
        //发现设service的Characteristics
        baby?.setBlockOnDiscoverCharacteristicsAtChannel(BabyChannelHomeIdentifier, block: { peripheral, service, error in
            guard service != nil else {
                return
            }
            let characteristics = service!.characteristics!
            for c in characteristics {
                logger.info("发现设service的Characteristics + \(c.uuid.uuidString)")
                if c.uuid.uuidString == CharacteristicNotifyUUIDString {
                    self.readCBCharacteristic = c
                    self.currentPeripheral.setNotifyValue(true, for: self.readCBCharacteristic!)
                }
                if c.uuid.uuidString == CharacteristicWriteUUIDString {
                    self.writeCBCharacteristic = c
                    self.currentPeripheral.setNotifyValue(true, for: self.writeCBCharacteristic!)
                    //开始请求设备信息
                    self.requsetDeviceInfo()
                }
            }
        })
        
        baby?.setBlockOnDidWriteValueForCharacteristicAtChannel(BabyChannelHomeIdentifier, block: { characteristic, error in
            guard characteristic != nil else {
                return
            }
            logger.info("写入数据成功\(characteristic!.uuid.uuidString)")
        })
        
        //读取characteristics
        baby?.setBlockOnReadValueForCharacteristicAtChannel(BabyChannelHomeIdentifier, block: { peripheral, characteristic, error in
            
            guard characteristic != nil else{
                return
            }
            logger.info("读取characteristics UUID + \(characteristic!.uuid.uuidString)")
            logger.info("读取characteristics Value + \(String(describing: characteristic!.value?.hexa))")
            if characteristic!.uuid.uuidString != CharacteristicNotifyUUIDString && characteristic!.uuid.uuidString != CharacteristicWriteUUIDString {
                return
            }
            
            if let value = characteristic!.value {
                if characteristic!.uuid.uuidString == CharacteristicNotifyUUIDString && self.isReceiveFuelData {
                    if self.receivedFuelDatas.count == 0 {
                        var binary = Binary.init(bytes: value.bytes)
                        let stx = try? binary.readBytes(1)//stx
                        if stx![0] != 0x02 {
                            return
                        }
                    }
                    self.receivedFuelDatas.append(value)
                    if self.checkFuelDataReceiveEnd(self.receivedFuelDatas) {
                        logger.info("油量数据已经传输完成")
                        SVProgressHUD.show(withStatus: "Data transfer completed, Parsing data...".localized())
                        self.isReceiveFuelData = false
                        self.sendReceiveHistoryDataFeedBack()
                        self.analyzeData()
                    }else{
                        logger.info("油量数据还没有传输完成！！！！")
                    }
                }else{
                    var binary = Binary.init(bytes: value.bytes)
                    if binary.count < 10 {
                        return
                    }
                    let _ = try? binary.readBytes(1)//stx
                    let _ = try? binary.readBytes(1)//dataLength
                    let _ = try? binary.readBytes(1)//length comp
                    let dataDeviceID = try? binary.readBytes(2)//deviceID
                    let _ = dataDeviceID?.hexa
                    let property = try? binary.readBytes(1)
                    if property![0] != 0x00 {
                        logger.info("Hard -> APP")
                        return
                    }
                    let cmd = try? binary.readBytes(1)
                    guard cmd != nil else {
                        return
                    }
                    if cmd![0] == 0x86 {//请求设备信息应答
                        SVProgressHUD.showSuccess(withStatus: "Requested device info successfully".localized())
                        let deviceID = try? binary.readBytes(2)
                        let length = try? binary.readBytes(2)
                        let width = try? binary.readBytes(2)
                        let height = try? binary.readBytes(2)
                        let compareV = try? binary.readBytes(2)
                        
                        if deviceID?.hexa ==  self.currentDeviceID{
                            if length?.hexa != "FFFF" && width?.hexa != "FFFF" && height?.hexa != "FFFF" && compareV?.hexa != "FFFF" {//设备参数符合标准
                                let deviceIDString = deviceID?.hexa
//                                let deviceIDIntValue = OCByteManager.shared.integer(from: deviceIDString!)
                                let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(deviceIDString!)'").first
                                guard carModel != nil else {
                                    return
                                }
                                let userModel = UserAndCarModel()
                                userModel.id = carModel!.id
                                userModel.deviceID = deviceIDString!//deviceIDIntValue.string
                                userModel.carNumber = carModel!.carNumber
                                userModel.fuelTankLength = OCByteManager.shared.integer(from: length!.hexa).float
                                userModel.fuelTankWidth = OCByteManager.shared.integer(from: width!.hexa).float
                                userModel.fuelTankHeight = OCByteManager.shared.integer(from: height!.hexa).float
                                userModel.createTime = carModel!.createTime
                                userModel.voltage = OCByteManager.shared.integer(from: compareV!.hexa)
                                SettingManager.shared.updateUserCarInfo(userModel)
                                //设备参数无误，开始请求油量数据
                                self.requestHistoryData()
                            }else{
                                SVProgressHUD.show(withStatus: "Please reset device parameters".localized())
                                self.baby?.cancelAllPeripheralsConnection()
                            }
                        }else{
                            SVProgressHUD.show(withStatus: "Device parameters has changed, please synchronous the latest".localized())
                            self.baby?.cancelAllPeripheralsConnection()
                        }
                    }
                }
                                
//                if cmd![0] == 0x82 {//获取油量历史数据
//                    logger.info("获取油量历史数据 + \(String(describing: characteristic!.value))")
//                    logger.info("获取油量历史数据 + \(characteristic!.value!.bytes.hexa)")
//                    let number = try? binary.readBytes(1)
//                    let numberIntStrng = OCByteManager.shared.integer(from: number!.hexa)
//                    if number![0] == 0xFF{
//                        SVProgressHUD.show(withStatus: "数据传输完成,正在解析...")
//                        SVProgressHUD.dismiss(withDelay: 4)
//                        self.analyzeData()
//                        return
//                    }
//                    self.showProcessWhenReceiveData()
//                    var dataArray :[String] = []
//                    for _ in 1 ... (dataLength![0] - 2)/2 {
//                        let data = try?binary.readBytes(2)
//                        guard data != nil else {
//                            continue
//                        }
//                        dataArray.append(data!.hexa)
//                    }
//                    self.historyData.updateValue(dataArray, forKey: numberIntStrng.string)
//                    self.sendReceiveHistoryDataFeedBack()
//                }
            }
        })

        
        baby?.setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel(BabyChannelHomeIdentifier, block: { characteristic, error in
            guard characteristic != nil else {
                return
            }
            guard self.currentPeripheral != nil else {
                return
            }
            self.currentPeripheral!.readValue(for: characteristic!)
            if characteristic!.isNotifying {
                self.currentPeripheral!.readValue(for: characteristic!)
            }
        })
        
    }
    
    func checkFuelDataReceiveEnd(_ datas: Data) -> Bool {
        logger.info("接收到油量数据数据 \(datas.hexa)")
        var count = datas.count
        var isEndofFuelData = false
        //一帧数据字节 帧头6字节 + 1个字节cmd + data区length字节 + 帧尾2字节
        if count > 8 {
            var binary = Binary.init(bytes: datas.bytes)
            var isContinue = true
            while isContinue {
                let stx = try? binary.readBytes(1)//stx
//                logger.info("stx \(stx!.hexa)")
                let length = try? binary.readBytes(1)//dataLength
//                logger.info("length \(length!.hexa)")
                let dataLength = OCByteManager.shared.integer(from: length!.hexa)//第一条数据帧的数据区长度
                let _ = try? binary.readBytes(5)//length comp + deviceID + 帧标识 hard->APP 0x00 + cmd油量历史数据 0x82
                
                let dataNumber = try? binary.readBytes(1)
                if dataNumber![0] == 0xFF {//数据区第一个字节为编号 1-253 255为结束
                    isContinue = false
                    isEndofFuelData = true
                }else{
                    if count < dataLength + 9 {//一条完整的数据帧没有传完
                        isContinue = false
                        isEndofFuelData = false
                    }else{
                        let _ = try? binary.readBytes(dataLength - 1)
                        let _ = try? binary.readBytes(2)
                        if count == dataLength + 9 {//正好是一个完整的数据帧，但是前面数据区的第一个自己不是0xFF,数据还没有传完
                            isContinue = false
                            isEndofFuelData = false
                        }else {
                            if count > dataLength + 9 && count < dataLength + 9 + 8 { //保证下个循环能读到数据区的第一个字节
                                isContinue = false
                                isEndofFuelData = false
                            }else{
                                count = count - dataLength - 9//读完一个数据帧，减去其长度
                            }
                        }
                    }
                }
            }
     
        
        }
        return isEndofFuelData
    }
    
    func showProcessWhenReceiveData() {
        if SVProgressHUD.isVisible() {
            return
        }else{
            SVProgressHUD.show()
        }
    }
    
    func requsetDeviceInfo() {
        guard currentPeripheral != nil else {
            return
        }
        let defaultDeviceID: [UInt8] = currentDeviceID.hexa
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x01)//数据长度  1字节
        datas.append(0xFF)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x85)//CMD ID
        datas.append(0x11)
        
        var  bcc: UInt8 = 0x00
        bcc ^= 0x01
        bcc ^= 0xFF
        bcc ^= defaultDeviceID[0]
        bcc ^= defaultDeviceID[1]
        bcc ^= 0x01
        bcc ^= 0x85
        bcc ^= 0x11

        datas.append(bcc)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showError(withStatus: "Please reconnect the device".localized())
        }else{
            logger.info("请求设备信息 + \(sendData)")
            logger.info("请求设备信息 + \(sendData.bytes.hexa)")
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
//            SVProgressHUD.showSuccess(withStatus: "请求设备信息\(sendData.hexa)")
        }

    }
    
    func requestHistoryData() {
        
        guard currentPeripheral != nil else {
            return
        }
        let defaultDeviceID: [UInt8] = currentDeviceID.hexa
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x01)//数据长度  1字节
        datas.append(0xFF)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x81)//CMD ID
        datas.append(0x00)
        
        var bcc: UInt8 = 0x00
        bcc ^= 0x01
        bcc ^= 0xFF
        bcc ^= defaultDeviceID[0]
        bcc ^= defaultDeviceID[1]
        bcc ^= 0x01
        bcc ^= 0x81
        bcc ^= 0x00

        datas.append(bcc)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showError(withStatus: "Please reconnect the device".localized())
        }else{
            logger.info("发送油量数据请求 + \(sendData.bytes.hexa)")
            self.isReceiveFuelData = true
            self.receivedFuelDatas = Data.init()
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
            SVProgressHUD.showInfo(withStatus: "Updating fuel data, please wait...".localized())
        }
    }
    
    func sendReceiveHistoryDataFeedBack() {
        guard currentPeripheral != nil else {
            return
        }
        let defaultDeviceID: [UInt8] = currentDeviceID.hexa
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x01)//数据长度  1字节
        datas.append(0xFF)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x81)//CMD ID
        datas.append(0xFF)
        
        var bcc: UInt8 = 0x00
        bcc ^= 0x01
        bcc ^= 0xFF
        bcc ^= defaultDeviceID[0]
        bcc ^= defaultDeviceID[1]
        bcc ^= 0x01
        bcc ^= 0x81
        bcc ^= 0xFF

        datas.append(bcc)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showError(withStatus: "Please reconnect the device".localized())
        }else{
            logger.info("发送油量数据接收状态请求 + \(sendData.bytes.hexa)")
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
//            SVProgressHUD.show(withStatus: "发送油量数据请求")
        }
    }

    
    
    func analyzeData() {
        if receivedFuelDatas.count == 0 {
            return
        }
        var fuelData: Array<Int> = []//Data.init()
        //一帧数据字节 帧头6字节 + 1个字节cmd + data区length字节 + 帧尾2字节
        var isContinue = true
        var binary = Binary.init(bytes: receivedFuelDatas.bytes)
        while isContinue {
            let stx = try? binary.readBytes(1)//stx
            logger.info("stx \(stx!.hexa)")
            let length = try? binary.readBytes(1)//dataLength
            logger.info("length \(length!.hexa)")
            let dataLength = OCByteManager.shared.integer(from: length!.hexa)//数据帧的数据区长度
            let _ = try? binary.readBytes(5)//length comp + deviceID + 帧标识 hard->APP 0x00 + cmd油量历史数据 0x82
            let dataNumber = try? binary.readBytes(1)
            if dataNumber![0] == 0xFF {//数据区第一个字节为编号 1-253 255为结束
                isContinue = false
            }else{
                for _ in 1 ... ((dataLength - 1) / 2) {
                    if let singleData = try? binary.readBytes(2) {
                        fuelData.append(OCByteManager.shared.integer(from: singleData.hexa))
                    }
                }
                let _ = try? binary.readBytes(2)//数据帧末尾
            }
        }
        
        let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(currentDeviceID!)'").first
        guard carModel != nil else {
            return
        }
        let width = carModel!.fuelTankWidth.double
        let length = carModel!.fuelTankLength.double
//        logger.info("width: \(width) + length: \(length)")

        RealmHelper.deleteObjectFilter(objectClass: BaseFuelDataModel(), filter: "deviceID = '\(currentDeviceID!)'")
        var dataSource: [BaseFuelDataModel] = []
        var isFirstActive: Bool = false//是否是上电
        for (index, data) in fuelData.enumerated()  {
            logger.info("index: \(index) + data: \(data)")
            if data == 0xFFFD {//0xFFFD
                isFirstActive = true
                return
            }
            if data == 0 {
                return
            }
            let baseFuelModel = BaseFuelDataModel.init()
            if isFirstActive {
                baseFuelModel.isFirstActive = true
            }
            baseFuelModel.deviceID = currentDeviceID
            baseFuelModel.fuelLevel = data.double*width*length/1000000
            baseFuelModel.recordIDFromDevice = Int64(index)
            dataSource.append(baseFuelModel)
            isFirstActive = false
        }
        logger.info("dataSource count \(dataSource.count)")
        RealmHelper.addObjects(by: dataSource)
        GlobalDataMananger.shared.fuelDataProcessor(currentDeviceID!)
        NotificationCenter.default.post(name: NSNotification.Name.SyncDateCompleteNotify, object: nil)
        SVProgressHUD.showSuccess(withStatus: "Fuel data processing completed".localized())
        baby?.cancelAllPeripheralsConnection()
    }
    
}

