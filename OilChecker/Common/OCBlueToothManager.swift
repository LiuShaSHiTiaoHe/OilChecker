//
//  OCBlueToothManager.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/3.
//

import UIKit
import BluetoothKit
import CoreBluetooth
import SwiftyUserDefaults
import SVProgressHUD


enum BleSendDataState {
    case RequestDeviceParamers
    case RequestSettingDeviceParamers
    case RequestFueLData
}

protocol OCBlueToothManagerDelegate: NSObjectProtocol {
   
    func bleScanChangedWith(_ changes: [BKDiscoveriesChange], _ discoveries: [BKDiscovery])
    
}

private struct OCBlueToothManagerWrapper {
  weak var wrapped: OCBlueToothManagerDelegate?
  init(_ wrapped: OCBlueToothManagerDelegate) {
    self.wrapped = wrapped
  }
}


class OCBlueToothManager: NSObject {

    
    static let shared = OCBlueToothManager()
    
    private var objservers: [OCBlueToothManagerWrapper] = []
    private var bleIsAvailable: Bool = false
    private var sendDataState: BleSendDataState = .RequestDeviceParamers
    var discoveries: [BKDiscovery] = []
    let central = BKCentral()
    var connectedRemotePeripheral: BKRemotePeripheral?
    
    var historyData:[String: Array<String>] = [:]

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
    
    func startSyncData() {

        SVProgressHUD.show()
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            self.discoveries = discoveries
            if self.sendDataState == .RequestDeviceParamers{
                self.connectToRemotePeripheral()
            }
        }, stateHandler: { newState in
            logger.info("state changed")
        },errorHandler: { error in
            if !self.bleIsAvailable {
                SVProgressHUD.showError(withStatus: "BlueTooth Unsupported".localized())
            }
            logger.error("Error from scanning: \(error)")
        })
    }

    func connectToRemotePeripheral() {
        let currenDeviceID = Defaults[\.currentCarID]!
        for item in discoveries {
            guard item.localName != nil else {
                continue
            }
            if item.localName!.contains(currenDeviceID) {
                central.interruptScan()
                SVProgressHUD.show(withStatus: "Connecting")
                central.connect(remotePeripheral: item.remotePeripheral) { remotePeripheral, error in
                    self.connectedRemotePeripheral = remotePeripheral
                    self.connectedRemotePeripheral!.delegate = self
                    self.connectedRemotePeripheral!.peripheralDelegate = self
                    SVProgressHUD.show(withStatus: "Connected")
                    
                }
                break
            }
        }
 
    }
    
    
    func requsetDeviceInfo() {
        guard connectedRemotePeripheral != nil else {
            return
        }
        sendDataState = .RequestDeviceParamers
        if connectedRemotePeripheral?.state == .connected {
            
            let defaultDeviceID: [UInt8] = Defaults[\.currentCarID]!.hexa
            var datas: [UInt8] = []
            datas.append(0x02)//STX 1字节
            datas.append(0x02)//数据长度  1字节
            datas.append(0xFE)//数据长补数 1字节
            datas.append(defaultDeviceID[0])//设备ID
            datas.append(defaultDeviceID[1])
            datas.append(0x01)//帧标识 APP -> Hard 0x01
            datas.append(0x85)//CMD ID  参数设置应答 0x85
            datas.append(0x11)
            
            var  checkSum: UInt64 = 0x00
            checkSum += 0x01
            checkSum += 0x01
            checkSum += UInt64(defaultDeviceID[0])
            checkSum += UInt64(defaultDeviceID[1])
            checkSum += 0x01
            checkSum += 0x85
            checkSum += 0x11

            datas.append(UInt8(checkSum^checkSum))//BCC Lengh开始到数据区结尾数据和的异或
            datas.append(0x30)//ETX 0x30
            
            let sendData = Data.init(datas)//Data(bytes: datas)
            SVProgressHUD.show(withStatus: "requsetDeviceInfo")
            central.sendData(sendData, toRemotePeer: connectedRemotePeripheral!) { data, remotepeer, error in
                guard error == nil else {
                    SVProgressHUD.showError(withStatus: "Failed sending requsetDeviceInfo to \(remotepeer.identifier)")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "Sent requsetDeviceInfo Data to \(remotepeer.identifier)")
            }
        }else{
            startSyncData()
        }
    }
    
    func requestHistoryData() {
        guard connectedRemotePeripheral != nil else {
            return
        }
        sendDataState = .RequestFueLData
        if connectedRemotePeripheral?.state == .connected {
            
            let defaultDeviceID: [UInt8] = Defaults[\.currentCarID]!.hexa
            var datas: [UInt8] = []
            datas.append(0x02)//STX 1字节
            datas.append(0x02)//数据长度  1字节
            datas.append(0xFE)//数据长补数 1字节
            datas.append(defaultDeviceID[0])//设备ID
            datas.append(defaultDeviceID[1])
            datas.append(0x01)//帧标识 APP -> Hard 0x01
            datas.append(0x81)//CMD ID
            datas.append(0x01)
            
            var  checkSum: UInt64 = 0x00
            checkSum += 0x01
            checkSum += 0x01
            checkSum += UInt64(defaultDeviceID[0])
            checkSum += UInt64(defaultDeviceID[1])
            checkSum += 0x01
            checkSum += 0x81
            checkSum += 0x01

            datas.append(UInt8(checkSum^checkSum))//BCC Lengh开始到数据区结尾数据和的异或
            datas.append(0x30)//ETX 0x30
            
            let sendData = Data.init(datas)//Data(bytes: datas)
            central.sendData(sendData, toRemotePeer: connectedRemotePeripheral!) { data, remotepeer, error in
                guard error == nil else {
                    SVProgressHUD.showError(withStatus: "发送油量数据请求失败!")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "发送油量数据请求成功!")
                
                SVProgressHUD.show()
                self.historyData.removeAll()
                
            }
        }else{
            startSyncData()
        }
    }

    
    /////////////////////////////////////
    func startCentral() {
        do {
            central.delegate = self
            central.addAvailabilityObserver(self)
            let dataServiceUUID = UUID.init(uuidString: "0000FFE0-0000-1000-8000-00805F9B34FB")!
            let dataServiceCharacteristicUUID = UUID.init(uuidString: "0000FFE1-0000-1000-8000-00805F9B34FB")!
            let configuration = BKConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch let error {
            print("Error while starting: \(error)")
        }
    }
    
    func analyzeData(_ data: [String: Array<String>]) {
        
    }
    
    
}

extension OCBlueToothManager:  BKRemotePeripheralDelegate, BKRemotePeerDelegate {
    func remotePeripheral(_ remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        logger.info("didUpdateName \(name)")
    }
    
    func remotePeripheralIsReady(_ remotePeripheral: BKRemotePeripheral) {
        logger.info("Peripheral ready: \(remotePeripheral)")
        if sendDataState == .RequestDeviceParamers {
            self.requsetDeviceInfo()
        }
    }
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        logger.info("didSendArbitraryData \(data)")
        if sendDataState == .RequestDeviceParamers {
            
            var binary = Binary.init(bytes: data.bytes)
            let _ = try? binary.readBytes(1) //stx
            let _ = try? binary.readBytes(1)//dataLength
            let _ = try? binary.readBytes(1)//length comp
            let deviceID = try? binary.readBytes(2)
            if deviceID!.hexa == Defaults[\.currentCarID]! {
                let property = try? binary.readBytes(1)
                if property![0] != 0x00 {
                    logger.info("Hard -> APP")
                    return
                }
                let cmd = try? binary.readBytes(1)
                if cmd![0] == 0x86 {//请求设备信息应答
                    let _ = try? binary.readBytes(2)//deviceID
                    let length = try? binary.readBytes(2)
                    let width = try? binary.readBytes(2)
                    let height = try? binary.readBytes(2)
                    let compareV = try? binary.readBytes(2)
                    if length?.hexa != "FFFF" && width?.hexa != "FFFF" && height?.hexa != "FFFF" && compareV?.hexa != "FFFF" {
                        let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(Defaults[\.currentCarID]!)'").first
                        guard carModel != nil else {
                            return
                        }
                        carModel!.fuelTankLength = (length?.hexa.float())!
                        carModel!.fuelTankHeight = (height?.hexa.float())!
                        carModel!.fuelTankWidth = (width?.hexa.float())!
                        SettingManager.shared.updateUserCarInfo(carModel!)
                        SVProgressHUD.show(withStatus: "请求历史数据")
                        
                        requestHistoryData()

                        
                    }else{
                        SVProgressHUD.show(withStatus: "油箱数据有误，请去设置页面重新设置")
                    }
                }
                
            }
        }
  
        if sendDataState == .RequestFueLData {

            var binary = Binary.init(bytes: data.bytes)
            let _ = try? binary.readBytes(1) //stx
            let length = try? binary.readBytes(1)
            let _ = try? binary.readBytes(1)//length comp
            let deviceID = try? binary.readBytes(2)
            if deviceID! == Defaults[\.currentCarID]!.hexa {
                let property = try? binary.readBytes(1)
                if property![0] != 0x00 {
                    logger.info("Hard -> APP")
                    return
                }
                let cmd = try? binary.readBytes(1)
                if cmd![0] == 0x82 {//获取油量历史数据
                    let number = try? binary.readBytes(1)
                    let numberIntStrng = OCByteManager.shared.integer(from: number!.hexa)
                    if number![0] == 0xFF{
                        SVProgressHUD.show(withStatus: "数据传输完成,正在解析...")
                        SVProgressHUD.dismiss(withDelay: 3)
                        return
                    }
                    var dataArray :[String] = []
                    for _ in 1 ... (length![0] - 2)/2 {
                        let data = try?binary.readBytes(2)
                        dataArray.append(data?.hexa ?? "0000")
                    }
                    historyData.updateValue(dataArray, forKey: numberIntStrng.string)
                }
            }else{
                SVProgressHUD.show(withStatus: "不是当前设备")
            }

        }
    }
    
}
 
extension OCBlueToothManager: BKCentralDelegate, BKAvailabilityObserver {
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        logger.info("Remote peripheral did disconnect: \(remotePeripheral)")
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        
        switch availability {
        case .available:
            bleIsAvailable = true
        case let .unavailable(cause):
            bleIsAvailable = false
            central.interruptScan()
            switch cause {
            case .poweredOff:
                SVProgressHUD.showInfo(withStatus: "BlePoweredOff")
            case .resetting,.any,.unsupported:
                SVProgressHUD.showInfo(withStatus: "BleUnsupported")
            case .unauthorized:
                SVProgressHUD.showInfo(withStatus: "BleUnauthorazed")
            }
        }
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        
    }
}
