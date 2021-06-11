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
            logger.info("扫描到设备 + \(String(describing: advertisementData))")
            if peripheral != nil {
                if !self.discoveries.contains(peripheral!) {
                    self.discoveries.append(peripheral!)
                    self.tableView.reloadData()
                }
            }
        })
        
        //设备连接成功
        baby?.setBlockOnConnectedAtChannel(BabyChannelScanViewIdentifier, block: { central, peripheral in
            //            logger.info("设备连接成功" + (peripheral?.name)!)
            logger.info("设备连接成功")
            SVProgressHUD.showSuccess(withStatus: "连接设备成功")
            let vc = AddNewDeviceViewController()
            vc.currentPeripheral = peripheral!
            self.navigationController?.pushViewController(vc)
            
        })
        
        baby?.setBlockOnFailToConnectAtChannel(BabyChannelScanViewIdentifier, block: { central, peripheral, error in
            SVProgressHUD.showError(withStatus: "连接设备失败")
            self.scan()
        })
        
        //发现设备的服务
        baby?.setBlockOnDiscoverServicesAtChannel(BabyChannelScanViewIdentifier, block: { peripheral, error in
            for service in peripheral!.services! {
                logger.info("设备的服务 + \(service.uuid.uuidString)")
            }
        })

        
        //发现设service的Characteristics
        baby?.setBlockOnDiscoverCharacteristicsAtChannel(BabyChannelScanViewIdentifier, block: { peripheral, service, error in
            guard service != nil else {
                return
            }
            let characteristics = service?.characteristics as! Array<CBCharacteristic>
            for c in characteristics {
                logger.info("发现设service的Characteristics + \(c.uuid.uuidString)")
            }
        })

        
        baby?.setFilterOnDiscoverPeripheralsAtChannel(BabyChannelScanViewIdentifier, filter: { (name, adv, RSSi) -> Bool in
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
    
    
    internal override func viewDidAppear(_ animated: Bool) {
        scan()
    }

    internal override func viewWillDisappear(_ animated: Bool) {
        //取消连接
        baby?.cancelAllPeripheralsConnection()
        //停止搜索
        baby?.cancelScan()
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
//        tableView.isUserInteractionEnabled = false
//        SVProgressHUD.show()
        baby?.cancelScan()
        let peripheral = discoveries[indexPath.row]
//        baby?.having(discovery).and().channel(BabyChannelScanViewIdentifier).then().connectToPeripherals().begin()
        let vc = AddNewDeviceViewController()
        vc.currentPeripheral = peripheral
        self.navigationController?.pushViewController(vc)
    }
    
    
}
