//
//  ScanBleDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/7.
//

import UIKit
import CoreBluetooth
import SVProgressHUD
import Schedule

class ScanBleDeviceViewController: UIViewController {
    
    let baby = BabyBluetooth.share();

    private var discoveries = [CBPeripheral]()
    private var currentPeripheral: CBPeripheral!
    var  reloadTask: Task!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
        addBabyDelegate()

    }
    

    func addBabyDelegate() {
        baby?.setBlockOnCentralManagerDidUpdateStateAtChannel(BabyChannelScanViewIdentifier, block: { central in
            if central?.state == .poweredOn  {
                
            }else{
                SVProgressHUD.showInfo(withStatus: "open mobile bluetooth".localized())
            }
        })

        //扫描到设备
        baby?.setBlockOnDiscoverToPeripheralsAtChannel(BabyChannelScanViewIdentifier, block: { central, peripheral, advertisementData, RSSI in
//            logger.info("扫描到设备 + \(String(describing: advertisementData))")
            if peripheral != nil {
                if !self.discoveries.contains(peripheral!) {
                    self.discoveries.append(peripheral!)
                    self.tableView.reloadData()
                }
            }
        })
        
        
        baby?.setFilterOnDiscoverPeripheralsAtChannel(BabyChannelScanViewIdentifier, filter: { (name, advertisementData, RSSi) -> Bool in

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
            
    }
    

    override func viewWillAppear(_ animated: Bool) {
//        discoveries.removeAll()
//        self.tableView.reloadData()
        reloadTask = Plan.every(20.second).do {
            logger.info("reload task")
            self.baby?.cancelScan()
            self.discoveries.removeAll()
            self.tableView.reloadData()
            self.scan()
        }
        scan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        baby?.cancelScan()
        reloadTask.cancel()
    }
    
    private func scan() {
        baby?.channel(BabyChannelScanViewIdentifier).scanForPeripherals().begin()
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
        cell?.textLabel?.text = discovery.name
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if discoveries.count == 0 {
            SVProgressHUD.showError(withStatus: "Device unconnected".localized())
            return
        }
        let peripheral = discoveries[indexPath.row]
        let vc = AddNewDeviceViewController()
        vc.currentPeripheral = peripheral
        self.navigationController?.pushViewController(vc)
    }
    
    
}
