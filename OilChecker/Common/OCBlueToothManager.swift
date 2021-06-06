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
                    SVProgressHUD.show(withStatus: "Connected and Sending Request")
                    
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
            datas.append(0x01)//数据长度  1字节
            datas.append(0x01)//数据长补数 1字节
            datas.append(defaultDeviceID[0])//设备ID
            datas.append(defaultDeviceID[1])
            datas.append(0x01)//帧标识 APP -> Hard 0x01
            datas.append(0x85)//CMD ID  参数设置应答 0x85
            datas.append(0x11)
            
            var  checkSum: UInt8 = 0x00
            checkSum += 0x01
            checkSum += 0x01
            checkSum += defaultDeviceID[0] + defaultDeviceID[1]
            checkSum += 0x01
            checkSum += 0x85
            checkSum += 0x11

            datas.append(checkSum^checkSum)//BCC Lengh开始到数据区结尾数据和的异或
            datas.append(0x30)//ETX 0x30
            
            let sendData = Data(bytes: datas)
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
            datas.append(0x01)//数据长度  1字节
            datas.append(0x01)//数据长补数 1字节
            datas.append(defaultDeviceID[0])//设备ID
            datas.append(defaultDeviceID[1])
            datas.append(0x01)//帧标识 APP -> Hard 0x01
            datas.append(0x81)//CMD ID
            datas.append(0x01)
            
            var  checkSum: UInt8 = 0x00
            checkSum += 0x01
            checkSum += 0x01
            checkSum += defaultDeviceID[0] + defaultDeviceID[1]
            checkSum += 0x01
            checkSum += 0x81
            checkSum += 0x01

            datas.append(checkSum^checkSum)//BCC Lengh开始到数据区结尾数据和的异或
            datas.append(0x30)//ETX 0x30
            
            let sendData = Data(bytes: datas)
            central.sendData(sendData, toRemotePeer: connectedRemotePeripheral!) { data, remotepeer, error in
                guard error == nil else {
                    SVProgressHUD.showError(withStatus: "Failed sending RequestFueLData to \(remotepeer.identifier)")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "Sent RequestFueLData Data to \(remotepeer.identifier)")
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
    
    func startScan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            self.discoveries = discoveries
            for item in self.objservers {
                item.wrapped?.bleScanChangedWith(changes, discoveries)
            }
            
        }, stateHandler: { newState in
            if newState == .scanning {
                SVProgressHUD.show()
                return
            } else if newState == .stopped {
                self.discoveries.removeAll()
                for item in self.objservers {
                    item.wrapped?.bleScanChangedWith([], [])
                }
            }
            SVProgressHUD.dismiss()
            
        }, errorHandler: { error in
            logger.error("Error from scanning: \(error)")
        })
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
            requestHistoryData()
        }
        
        if sendDataState == .RequestFueLData {
            
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
//            startScan()
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
