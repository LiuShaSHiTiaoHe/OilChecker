//
//  HomeViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/20.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults
import SVProgressHUD

class HomeViewController: UIViewController {

    let realm = try! Realm()
    var userCarArray: [UserAndCarModel] = []
    var currentCarModel: UserAndCarModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = kBackgroundColor
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Home".localized()
        OCBlueToothManager.shared.startCentral()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    @objc
    func carNumberButtonAction() {
        if userCarArray.count > 0 {
            let deviceListVC = MyDeviceListViewController()
            deviceListVC.delegate = self
            self.navigationController?.pushViewController(deviceListVC)
        }else{
            //TODO
            if OCBlueToothManager.shared.connectedRemotePeripheral != nil {
                //add current conneted ble device
                self.navigationController?.pushViewController(AddNewDeviceViewController())

            }else{
                SVProgressHUD.showInfo(withStatus: "please add a device first".localized())
                self.navigationController?.pushViewController(ScanBleDeviceViewController())
                return
            }
        }
    }
    
    @objc
    func syncDataFromDevice() {
        if Defaults[\.currentCarID]!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "please add a device first".localized())
            self.navigationController?.pushViewController(ScanBleDeviceViewController())
            return
        }
        //TODO
        if OCBlueToothManager.shared.connectedRemotePeripheral != nil {
            //sync data via ble
            OCBlueToothManager.shared.requsetDeviceInfo()
            
        }else{
            //try connect current selected device
            OCBlueToothManager.shared.startSyncData()
        }
    }
    
    func initData()  {
        let models = realm.objects(UserAndCarModel.self)
        userCarArray = models.filter({ (model) -> Bool in
            !model.isDeleted
        })
        
        if userCarArray.count == 0 {
            carNumberLabel.textColor = kThemeGreenColor
            carNumberLabel.text = "Add A Device".localized()
        }else{
            if Defaults[\.currentCarID]!.isEmpty {
                currentCarModel = userCarArray[0]
                Defaults[\.currentCarID] = currentCarModel!.deviceID
            }else{
                currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
                    model.deviceID == Defaults[\.currentCarID]
                }).first
                guard currentCarModel != nil else {
                    return
                }
                chartView.updateCurrentDevice(model: currentCarModel!)
            }
            carNumberLabel.text = currentCarModel?.carNumber
            updateLatestFuelCapacityAndConsumption(deviceID: currentCarModel?.deviceID)
        }
    }
    
    func updateLatestFuelCapacityAndConsumption(deviceID: String?) {
        guard let _ = deviceID else {
            return
        }
        let state = GlobalDataMananger.shared.checkLastFuelStatus(deviceID!)
        switch state {
        case .Irregular:
            capacityView.statusLabel.textColor = kRedFontColor
        case .Unknown:
            capacityView.statusLabel.textColor = kSecondBlackColor
        default :
            break
        }
        capacityView.statusLabel.text  = state.rawValue.localized() //FuelCapacityState.Normal.rawValue.localized()
        consumptionView.statusLabel.text = GlobalDataMananger.shared.getAverageConsumption(deviceID!) + "L"//DefaultEmptyNumberString
    }
    
 
    func initUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(carNumberLabel)
        scrollContentView.addSubview(deviceSwitchButton)
        scrollContentView.addSubview(capacityView)
        scrollContentView.addSubview(consumptionView)
        scrollContentView.addSubview(chartView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.height.greaterThanOrEqualTo(scrollView).offset(kMargin)
        }
        
        carNumberLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin)
            make.right.equalTo(scrollContentView.snp.centerX).offset(-kMargin/2)
            make.height.equalTo(60)
        }
        
        deviceSwitchButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin/2)
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalTo(scrollContentView.snp.centerX).offset(kMargin/2)
            make.height.equalTo(60)
        }
        
        capacityView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalTo(carNumberLabel.snp.bottom).offset(kMargin)
            make.right.equalTo(scrollContentView.snp.centerX).offset(-kMargin/2)
            make.height.equalTo(100)
        }
        
        consumptionView.snp.makeConstraints { (make) in
            make.centerY.equalTo(capacityView.snp.centerY)
            make.height.equalTo(100)
            make.left.equalTo(scrollContentView.snp.centerX).offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.top.equalTo(capacityView.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(450)
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        return scroll
    }()
    
    lazy var scrollContentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = kBackgroundColor
        return view
    }()
    
    
    lazy var carNumberLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = kWhiteColor
        label.font = UIFont.systemFont(ofSize: 20)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.textColor = kSecondBlackColor
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(carNumberButtonAction)))
        return label
    }()
    
    lazy var deviceSwitchButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("Sync".localized(), for: .normal)
        btn.setTitleColor(kGreenFontColor, for: .normal)
        btn.setImage(UIImage.init(named: "btn_sync"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: kMargin)
        btn.backgroundColor = kWhiteColor
        btn.titleLabel?.font = k15BoldFont
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(syncDataFromDevice), for: .touchUpInside)
        return btn
    }()
    
    lazy var capacityView: FuelCapacityView = {
        let view = FuelCapacityView()
        view.nameLabel.text = "Fuel Capacity Status".localized()
        view.statusLabel.textColor = kThemeGreenColor
        view.statusLabel.text = FuelCapacityState.Unknown.rawValue.localized()
        return view
    }()
    
    lazy var consumptionView: FuelCapacityView = {
        let view = FuelCapacityView()
        view.nameLabel.text = "Average Fuel Consumption".localized()
//        view.statusLabel.textColor = kRedFontColor
        view.statusLabel.text = DefaultEmptyNumberString + "L"
        return view
    }()
    
    lazy var chartView: HomeChartView = {
        let view = HomeChartView.init()
        return view
    }()
}

extension HomeViewController: MyDeviceListViewControllerDelegate {

    func selectedCarInfo(_ data: UserAndCarModel) {
        carNumberLabel.text = data.carNumber
        Defaults[\.currentCarID] = data.deviceID
        chartView.updateCurrentDevice(model: data)
        updateLatestFuelCapacityAndConsumption(deviceID: data.deviceID)
    }
}


