//
//  ScanBleDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/7.
//

import UIKit
import CoreBluetooth
import SVProgressHUD

class ScanBleDeviceViewController: UIViewController {
    
    let baby = BabyBluetooth.share();

    private var discoveries = [CBPeripheral]()
    private var currentPeripheral: CBPeripheral!

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
                SVProgressHUD.showInfo(withStatus: "蓝牙没有打开")
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
        
//        //设备连接成功
//        baby?.setBlockOnConnectedAtChannel(BabyChannelScanViewIdentifier, block: { central, peripheral in
//            //            logger.info("设备连接成功" + (peripheral?.name)!)
//            logger.info("设备连接成功")
//            SVProgressHUD.showSuccess(withStatus: "连接设备成功")
//            let vc = AddNewDeviceViewController()
//            vc.currentPeripheral = peripheral!
//            self.navigationController?.pushViewController(vc)
//
//        })
//
//        baby?.setBlockOnFailToConnectAtChannel(BabyChannelScanViewIdentifier, block: { central, peripheral, error in
//            SVProgressHUD.showError(withStatus: "连接设备失败")
//            self.scan()
//        })
        
//        //发现设备的服务
//        baby?.setBlockOnDiscoverServicesAtChannel(BabyChannelScanViewIdentifier, block: { peripheral, error in
//            for service in peripheral!.services! {
//                logger.info("设备的服务 + \(service.uuid.uuidString)")
//            }
//        })
//
//        
//        //发现设service的Characteristics
//        baby?.setBlockOnDiscoverCharacteristicsAtChannel(BabyChannelScanViewIdentifier, block: { peripheral, service, error in
//            guard service != nil else {
//                return
//            }
//            let characteristics = service?.characteristics as! Array<CBCharacteristic>
//            for c in characteristics {
//                logger.info("发现设service的Characteristics + \(c.uuid.uuidString)")
//            }
//        })

        
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
//            if let serviceUUIDs = advertisementData!["kCBAdvDataServiceUUIDs"] as? [CBUUID]{
//                let serviceuuid = serviceUUIDs.first
//                if serviceuuid != nil && serviceuuid!.uuidString == ServiceUUIDString {
//                    return true
//                }
//             }
//            return false
            
            
//            if name == nil || name!.isEmpty {
//                return false
//            }
//            return true
        })
            
    }
    

    override func viewWillAppear(_ animated: Bool) {
        discoveries.removeAll()
        scan()
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        discoveries.removeAll()
//    }
//    internal override func viewWillDisappear(_ animated: Bool) {
//        //取消连接
//        baby?.cancelAllPeripheralsConnection()
//        //停止搜索
//        baby?.cancelScan()
//    }

    
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
        baby?.cancelScan()
        let peripheral = discoveries[indexPath.row]
//        if let services = peripheral.services {
//            if services.count == 0 {
//                SVProgressHUD.showError(withStatus: "选择设备 Services 为空")
//            }else{
//                var containsService = false
//                for service in services {
//                    if service.uuid.uuidString == ServiceUUIDString {
//                        containsService = true
//                        break
//                    }
//                }
//                if containsService {
//                    let vc = AddNewDeviceViewController()
//                    vc.currentPeripheral = peripheral
//                    self.navigationController?.pushViewController(vc)
//                }else{
//                    SVProgressHUD.showError(withStatus: "选择设备没有 FFE0 的Service")
//                }
//            }
//        }else{
//            SVProgressHUD.showError(withStatus: "选择设备 Services 为空")
//        }
        
//        if let name = peripheral.name {
//            if name.contains("BT-") {
//                let vc = AddNewDeviceViewController()
//                vc.currentPeripheral = peripheral
//                self.navigationController?.pushViewController(vc)
//            }else{
//                SVProgressHUD.showError(withStatus: "选择设备不符合条件")
//            }
//        }
        let vc = AddNewDeviceViewController()
        vc.currentPeripheral = peripheral
        self.navigationController?.pushViewController(vc)
    }
    
    
}
