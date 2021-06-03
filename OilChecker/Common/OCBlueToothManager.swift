//
//  OCBlueToothManager.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/3.
//

import UIKit
import BluetoothKit
import CoreBluetooth

class OCBlueToothManager: NSObject {
    static let shared = OCBlueToothManager()
    
    var discoveries = [BKDiscovery]()
    let central = BKCentral()
    var remotePeripheral: BKRemotePeripheral?
    
}
