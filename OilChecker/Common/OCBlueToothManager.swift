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
    
    private var readCBCharacteristic: CBCharacteristic?
    private var writeCBCharacteristic: CBCharacteristic?
    private var services: [CBService] = []
    private var currentDeviceID: String!
    
    private var receiveDataEnd: Bool = false

    var historyData:[String: Array<String>] = [:]

    func startScan(_ deviceID: String) {
        currentDeviceID = deviceID
        SVProgressHUD.show()
        let plan = Plan.after(10.seconds)
        let _ = plan.do {
            if self.currentPeripheral == nil {
                self.stopScan()
                SVProgressHUD.showError(withStatus: "无法连接当前设备")
            }
        }
        baby?.cancelAllPeripheralsConnection()
        baby?.channel(BabyChannelHomeIdentifier).scanForPeripherals().begin()
    }
    
    func stopScan() {
        baby?.cancelScan()
    }
    
    func connetDevice() {
        guard currentPeripheral != nil else {
            return
        }
        
        baby?.having(currentPeripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin()
    }
    
    func addBabyDelegate() {
        baby?.setBlockOnCentralManagerDidUpdateStateAtChannel(BabyChannelHomeIdentifier, block: { central in
            if central?.state == .poweredOn  {
                
            }else{
                SVProgressHUD.showInfo(withStatus: "蓝牙没有打开")
            }
        })

        //扫描到设备
        baby?.setBlockOnDiscoverToPeripheralsAtChannel(BabyChannelHomeIdentifier, block: { central, peripheral, advertisementData, RSSI in
            logger.info("扫描到设备 + \(String(describing: advertisementData))")
            guard advertisementData != nil else{
                return
            }
            if let name = advertisementData!["kCBAdvDataLocalName"] as? String {
                if name == "BT-" + self.currentDeviceID.int!.intTo2Bytes().hexa {
                    if peripheral != nil {
                        self.currentPeripheral = peripheral
                        self.stopScan()
                        self.connetDevice()
                    }
                }
            }
      
        })
        
        //设备连接成功
        baby?.setBlockOnConnectedAtChannel(BabyChannelHomeIdentifier, block: { central, peripheral in
            logger.info("设备连接成功")
            SVProgressHUD.showSuccess(withStatus: "连接设备成功")
            //开始请求设备信息
            self.requsetDeviceInfo()
        })
        
        baby?.setBlockOnFailToConnectAtChannel(BabyChannelHomeIdentifier, block: { central, peripheral, error in
            SVProgressHUD.showError(withStatus: "连接设备失败")
        })
        
        //发现设备的服务
        baby?.setBlockOnDiscoverServicesAtChannel(BabyChannelHomeIdentifier, block: { peripheral, error in
            for service in peripheral!.services! {
                logger.info("设备的服务 + \(service.uuid.uuidString)")
            }
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
                    self.setNotify()
                }
                if c.uuid.uuidString == CharacteristicWriteUUIDString {
                    self.writeCBCharacteristic = c
                }
            }
        })

        baby?.setBlockOnDiscoverDescriptorsForCharacteristicAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            
            if characteristic == nil {
                return
            }
            logger.info("Descriptors + \(characteristic!.uuid.uuidString)")

        })
        
        //读取characteristics
        baby?.setBlockOnReadValueForCharacteristicAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            logger.info("读取characteristics UUID + \(characteristic!.uuid.uuidString)")
            logger.info("读取characteristics Value + \(characteristic!.value)")
            if characteristic != nil {
                if let value = characteristic!.value {
                    var binary = Binary.init(bytes: value.bytes)
                    if binary.count < 10 {
                        return
                    }
                    let _ = try? binary.readBytes(1)//stx
                    let dataLength = try? binary.readBytes(1)//dataLength
                    let _ = try? binary.readBytes(1)//length comp
                    let dataDeviceID = try? binary.readBytes(2)//deviceID
                    let stringDID = dataDeviceID?.hexa
                    logger.info("\(String(describing: stringDID))")
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
                        SVProgressHUD.show(withStatus: "请求设备信息应答成功")
                        let deviceID = try? binary.readBytes(2)
                        let length = try? binary.readBytes(2)
                        let width = try? binary.readBytes(2)
                        let height = try? binary.readBytes(2)
                        let compareV = try? binary.readBytes(2)
                        if deviceID?.hexa ==  self.currentDeviceID.int!.intTo2Bytes().hexa{
                            if length?.hexa != "FFFF" && width?.hexa != "FFFF" && height?.hexa != "FFFF" && compareV?.hexa != "FFFF" {//设备参数符合标准
                                let deviceIDString = deviceID?.hexa
                                let deviceIDIntValue = OCByteManager.shared.integer(from: deviceIDString!)
                                let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(deviceIDIntValue.string)'").first
                                carModel!.fuelTankLength = (length?.hexa.float())!
                                carModel!.fuelTankHeight = (height?.hexa.float())!
                                carModel!.fuelTankWidth = (width?.hexa.float())!
                                SettingManager.shared.updateUserCarInfo(carModel!)
                                //设备参数无误，开始请求油量数据
                                self.requestHistoryData()
                            }else{
                                SettingManager.shared.deleteUserCar(self.currentDeviceID)
                                SVProgressHUD.show(withStatus: "设置参数参数有误,请重新设置")
                            }
                        }
                    }
                    
                    if cmd![0] == 0x82 {//获取油量历史数据
                        logger.info("获取油量历史数据 + \(String(describing: characteristic!.value))")
                        logger.info("获取油量历史数据 + \(characteristic!.value!.bytes.hexa)")
                        let number = try? binary.readBytes(1)
                        let numberIntStrng = OCByteManager.shared.integer(from: number!.hexa)
                        if number![0] == 0xFF{
                            SVProgressHUD.show(withStatus: "数据传输完成,正在解析...")
                            SVProgressHUD.dismiss(withDelay: 4)
                            self.analyzeData()
                            return
                        }
                        self.showProcessWhenReceiveData()
                        var dataArray :[String] = []
                        for _ in 1 ... (dataLength![0] - 2)/2 {
                            let data = try?binary.readBytes(2)
                            guard data != nil else {
                                continue
                            }
                            dataArray.append(data!.hexa)
                        }
                        self.historyData.updateValue(dataArray, forKey: numberIntStrng.string)
                    }
                }
            }
        })

        baby?.setBlockOnReadValueForDescriptorsAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            logger.info("读取Descriptors + \(characteristic!.uuid.uuidString)")
        })
        
        baby?.setFilterOnDiscoverPeripheralsAtChannel(BabyChannelHomeIdentifier, filter: { (name, adv, RSSi) -> Bool in
            if adv == nil {
                return false
            }
            if let serviceUUIDs = adv!["kCBAdvDataServiceUUIDs"] as? Array<CBUUID> {
                for cbuuid in serviceUUIDs {
                    if cbuuid.uuidString == ServiceUUIDString {
                        return true
                    }
                }
            }
            return false
        })
        
        
    }
    
    func showProcessWhenReceiveData() {
        if SVProgressHUD.isVisible() {
            return
        }else{
            SVProgressHUD.show()
        }
    }

    func setNotify() {
        guard readCBCharacteristic != nil else {
            return
        }
        if readCBCharacteristic?.isNotifying == false {
            logger.info("readCBCharacteristic?.isNotifying == false   setNotify")
            currentPeripheral.setNotifyValue(true, for: readCBCharacteristic!)
        }
    }
    
    func requsetDeviceInfo() {
        guard currentPeripheral != nil else {
            return
        }
        let defaultDeviceID: [UInt8] = currentDeviceID.int!.intTo2Bytes()
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x02)//数据长度  1字节
        datas.append(0xFE)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x85)//CMD ID
        datas.append(0x11)
        
        var  checkSum: UInt8 = 0x00
        checkSum ^= 0x02
        checkSum ^= 0xFE
        checkSum ^= defaultDeviceID[0]
        checkSum ^= defaultDeviceID[1]
        checkSum ^= 0x01
        checkSum ^= 0x85
        checkSum ^= 0x11

        datas.append(checkSum)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showSuccess(withStatus: "writeCBCharacteristic 为空,重新连接设备")
        }else{
            logger.info("请求设备信息 + \(sendData)")
            logger.info("请求设备信息 + \(sendData.bytes.hexa)")
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
            SVProgressHUD.showSuccess(withStatus: "请求设备信息\(sendData.hexa)")
        }

    }
    
    func requestHistoryData() {
        
        guard currentPeripheral != nil else {
            return
        }
        let defaultDeviceID: [UInt8] = currentDeviceID.int!.intTo2Bytes()
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x02)//数据长度  1字节
        datas.append(0xFE)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x81)//CMD ID
        datas.append(0x00)
        
        var checkSum: UInt8 = 0x00
        checkSum ^= 0x02
        checkSum ^= 0xFE
        checkSum ^= defaultDeviceID[0]
        checkSum ^= defaultDeviceID[1]
        checkSum ^= 0x01
        checkSum ^= 0x81
        checkSum ^= 0x00

        datas.append(checkSum)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showSuccess(withStatus: "writeCBCharacteristic 为空,重新连接设备")
        }else{
            logger.info("发送油量数据请求 + \(sendData)")
            logger.info("发送油量数据请求 + \(sendData.bytes.hexa)")
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
            SVProgressHUD.show(withStatus: "发送油量数据请求")
        }

    }

    
    
    func analyzeData() {
        logger.info("data count \(historyData.count)")
        if historyData.count == 0 {
            return
        }
        let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(currentDeviceID!)'").first
        guard carModel != nil else {
            return
        }
        let width = carModel!.fuelTankWidth.double
        let length = carModel!.fuelTankLength.double
        
        RealmHelper.deleteObjectFilter(objectClass: BaseFuelDataModel(), filter: "deviceID = '\(currentDeviceID!)'")
        var dataSource: [BaseFuelDataModel] = []
        
        var allRecordArray:[String] = []
        let numbersFormDevice = historyData.keys.sorted { first, second in
            return first.int! < second.int!
        }
        logger.info("sorted keys \(numbersFormDevice)")
        for index in numbersFormDevice {
            for data in historyData[index]! {
                allRecordArray.append(data)
            }
        }
        for (index, data) in allRecordArray.enumerated()  {
            let baseFuelModel = BaseFuelDataModel.init()
            baseFuelModel.deviceID = currentDeviceID
            baseFuelModel.fuelLevel = data.double()!*width*length/1000000
            baseFuelModel.recordIDFromDevice = Int64(index)
            dataSource.append(baseFuelModel)
        }
        RealmHelper.addObjects(by: dataSource)
        GlobalDataMananger.shared.fuelDataProcessor(Defaults[\.currentCarID]!)
        NotificationCenter.default.post(name: NSNotification.Name.SyncDateCompleteNotify, object: nil)
    }
    
}

