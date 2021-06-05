//
//  ScanBleDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/7.
//

import UIKit
import BluetoothKit
import CoreBluetooth
import SVProgressHUD

class ScanBleDeviceViewController: UIViewController {

    private var discoveries = [BKDiscovery]()
    private let central = OCBlueToothManager.shared.central//BKCentral()
    private var currentBKDiscovery: BKDiscovery?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        startCentral()
    }
    

    
    private func startCentral() {
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
    
    internal override func viewDidAppear(_ animated: Bool) {
        if OCBlueToothManager.shared.remotePeripheral != nil {
            do {
                try central.disconnectRemotePeripheral(OCBlueToothManager.shared.remotePeripheral!)
                OCBlueToothManager.shared.remotePeripheral = nil
            } catch let error {
                logger.info("Error disconnecting remote peripheral: \(error)")
            }
        }
        scan()
    }

    internal override func viewWillDisappear(_ animated: Bool) {
        central.interruptScan()
    }

//    deinit {
//        _ = try? central.stop()
//    }
    
    private func scan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            let indexPathsToRemove = changes.filter({ $0 == .remove(discovery: nil) }).map({ IndexPath(row: self.discoveries.firstIndex(of: $0.discovery)!, section: 0) })
            self.discoveries = discoveries
            let indexPathsToInsert = changes.filter({ $0 == .insert(discovery: nil) }).map({ IndexPath(row: self.discoveries.firstIndex(of: $0.discovery)!, section: 0) })
            if !indexPathsToRemove.isEmpty {
                self.tableView.deleteRows(at: indexPathsToRemove, with: UITableView.RowAnimation.automatic)
            }
            if !indexPathsToInsert.isEmpty {
                self.tableView.insertRows(at: indexPathsToInsert, with: UITableView.RowAnimation.automatic)
            }
            for insertedDiscovery in changes.filter({ $0 == .insert(discovery: nil) }) {
                logger.info("Discovery: \(insertedDiscovery)")
            }
        }, stateHandler: { newState in
            if newState == .scanning {
                SVProgressHUD.show()
                return
            } else if newState == .stopped {
                self.discoveries.removeAll()
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
            
        }, errorHandler: { error in
            logger.error("Error from scanning: \(error)")
        })
    }
    func initUI(){
        self.navigationItem.title = "BLE Devices".localized()
        self.view.backgroundColor = kWhiteColor
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView()
        table.backgroundColor = kWhiteColor
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .singleLine
        return table
    }()
}

extension ScanBleDeviceViewController: BKCentralDelegate, BKAvailabilityObserver{
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
       
    }
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        logger.info("availability: \(availability)")
        if availability == .available {
            scan()
        } else {
            central.interruptScan()
        }
    }

    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        logger.info("Remote peripheral did disconnect: \(remotePeripheral)")
    }
    
}


extension ScanBleDeviceViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BlueDeviceCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell==nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        let discovery = discoveries[indexPath.row]
        cell?.textLabel?.text = discovery.localName != nil ? discovery.localName : discovery.remotePeripheral.name
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.isUserInteractionEnabled = false
        SVProgressHUD.show()
        let discovery = discoveries[indexPath.row]
        central.connect(30.0, remotePeripheral: discovery.remotePeripheral) { remotePeripheral, error in
            SVProgressHUD.dismiss()
            tableView.isUserInteractionEnabled = true
            guard error == nil else {
                print("Error connecting peripheral: \(String(describing: error))")
                return
            }
            OCBlueToothManager.shared.remotePeripheral = remotePeripheral
            self.navigationController?.pushViewController(AddNewDeviceViewController())
        }
    }
    
    
}