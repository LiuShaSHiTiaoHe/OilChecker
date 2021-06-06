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

    var discoveries = [BKDiscovery]()
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
        if connectedRemotePeripheral != nil {
            connectedRemotePeripheral!.delegate = nil
            connectedRemotePeripheral!.peripheralDelegate = nil
//            connectedRemotePeripheral
        }
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            for item in discoveries {
                if item.localName.contains(Defaults[\.currentCarID]) {
                    self.connectToRemotePeripheral(item.remotePeripheral)
                    break
                }
            }
        }, stateHandler: { newState in

        }, duration: 10, inBetweenDelay: 3) { error in
            logger.error("Error from scanning: \(error)")
        }
    }
    
    func connectToRemotePeripheral(_ remotePeripheral: BKRemotePeripheral) {
        central.connect(remotePeripheral: remotePeripheral) { remotePeripheral, error in
            self.connectedRemotePeripheral = remotePeripheral
            self.connectedRemotePeripheral!.delegate = self
            self.connectedRemotePeripheral!.peripheralDelegate = self
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
    
//    func requsetDeviceInfo() {
//        guard connectedRemotePeripheral != nil else {
//            return
//        }
//        let sendData = [0xff]
//        central.sendData(sendData, toRemotePeer: connectedRemotePeripheral) { data, remotepeer, error in
//            guard error == nil else {
//                logger.error("Failed sending to \(remotePeripheral)")
//                return
//            }
//            logger.info("Sent to \(remotePeripheral)")
//        }
//    }

    
    
}

extension OCBlueToothManager:  BKRemotePeripheralDelegate, BKRemotePeerDelegate {
    func remotePeripheral(_ remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        logger.info("didUpdateName \(name)")
    }
    
    func remotePeripheralIsReady(_ remotePeripheral: BKRemotePeripheral) {
        logger.info("Peripheral ready: \(remotePeripheral)")
    }
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        logger.info("didSendArbitraryData \(data)")
    }
    
}
 
extension OCBlueToothManager: BKCentralDelegate, BKAvailabilityObserver {
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        logger.info("Remote peripheral did disconnect: \(remotePeripheral)")
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        
        switch availability {
        case .available:
            startScan()
        case let .unavailable(cause):
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
