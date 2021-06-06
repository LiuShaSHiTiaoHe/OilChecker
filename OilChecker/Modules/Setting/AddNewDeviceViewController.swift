//
//  AddNewDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import SkyFloatingLabelTextField
import BluetoothKit
import CoreBluetooth
import SVProgressHUD

let TextFieldHeight = 45

class AddNewDeviceViewController: UIViewController {

    var central: BKCentral? = OCBlueToothManager.shared.central
    var remotePeripheral: BKRemotePeripheral? = OCBlueToothManager.shared.connectedRemotePeripheral

//    init(central: BKCentral, remotePeripheral: BKRemotePeripheral) {
//        self.central = central
//        self.remotePeripheral = remotePeripheral
//        super.init(nibName: nil, bundle: nil)
//        remotePeripheral.delegate = self
//        remotePeripheral.peripheralDelegate = self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
  

    
    @objc
    func saveButtonAction() {
        logger.info("saveButtonAction")
        let deviceID = deviceIDInput.textfield.text
        let carNumberSting = carNumberInput.textfield.text
        let tankLength = fuelTankLengthInput.textfield.text
        let tankWitdh = fuelTankWitdhInput.textfield.text
        let tankHeight = fuelTankHeightInput.textfield.text
        let compareV = compareVoltageInput.textfield.text        
        
        if !deviceID!.isEmpty && !carNumberSting!.isEmpty && !tankLength!.isEmpty && !tankWitdh!.isEmpty && !tankHeight!.isEmpty && !compareV!.isEmpty {
            let userModel = UserAndCarModel()
            userModel.deviceID = deviceID!
            userModel.carNumber = carNumberSting!
            userModel.fuelTankLength = tankLength!.float()!
            userModel.fuelTankWidth = tankWitdh!.float()!
            userModel.fuelTankHeight = tankHeight!.float()!
            userModel.createTime = NSDate.now
            userModel.voltage = compareV!.int!
            SettingManager.shared.updateUserCarInfo(userModel)
            SVProgressHUD.showSuccess(withStatus: "Add Success".localized())
            self.navigationController?.popViewController(animated: true)
        }else{
            SVProgressHUD.showError(withStatus: "Please Enter Correctly".localized())
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kWhiteColor
        self.navigationItem.title = "Add".localized()
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightSaveButton)
        // Do any additional setup after loading the view.
        initUI()
    }
    
    func initData() {
        guard remotePeripheral != nil else {
            SVProgressHUD.showError(withStatus: "connect a device first".localized())
            self.navigationController?.popViewController()
            return
        }
        
        remotePeripheral!.delegate = self
        remotePeripheral!.peripheralDelegate = self
    }
    
    func initUI() {
        self.view.addSubview(scrollView)
        let scrollBackView = UIView.init()
        scrollView.addSubview(scrollBackView)
        scrollView.addSubview(carNumberInput)
        scrollView.addSubview(deviceIDInput)
        scrollView.addSubview(fuelTankLengthInput)
        scrollView.addSubview(fuelTankWitdhInput)
        scrollView.addSubview(fuelTankHeightInput)
        scrollView.addSubview(compareVoltageInput)
        scrollView.addSubview(rightSaveButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollBackView.snp.makeConstraints({ (make) in
           make.edges.equalToSuperview()
           make.width.equalTo(kScreenWidth)
           make.height.greaterThanOrEqualTo(scrollView).offset(1)
        })
        
        carNumberInput.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
        }
        
        deviceIDInput.snp.makeConstraints { (make) in
            make.top.equalTo(carNumberInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
        }
        
        fuelTankLengthInput.snp.makeConstraints { (make) in
            make.top.equalTo(deviceIDInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
        }
        
        fuelTankWitdhInput.snp.makeConstraints { (make) in
            make.top.equalTo(fuelTankLengthInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
        }
        
        
        fuelTankHeightInput.snp.makeConstraints { (make) in
            make.top.equalTo(fuelTankWitdhInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
        }
        
        compareVoltageInput.snp.makeConstraints { (make) in
            make.top.equalTo(fuelTankHeightInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
//            make.right.equalToSuperview().offset(-kMargin)
        }
        
        rightSaveButton.snp.makeConstraints { make  in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(kScreenWidth - kMargin*2)
            make.height.equalTo(50)
            make.top.equalTo(compareVoltageInput.snp.bottom).offset(kMargin*2)
            make.bottom.lessThanOrEqualTo(scrollView.snp.bottom).offset(-kMargin)

        }
    }

    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        scroll.backgroundColor = kWhiteColor
        scroll.contentSize = .init(width: kScreenWidth, height: kScreenHeight)
        return scroll
    }()
    
    lazy var rightSaveButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kThemeGreenColor
        btn.layer.cornerRadius = 10
        btn.setTitle("Save".localized(), for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k16Font
        btn.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return btn
    }()
    
    
    
    lazy var carNumberInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Plate Number".localized()
        input.textfield.placeholder = "Enter Your Plate Number".localized()
        return input
    }()
    
    lazy var deviceIDInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Device Identify".localized()
        input.textfield.placeholder = "Set Device Identify".localized()
        return input
    }()
    
    lazy var fuelTankLengthInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Length".localized()
        input.textfield.placeholder = "Length".localized()
        input.unitsLabel.text = "mm"
        return input
    }()
    
    
    lazy var fuelTankWitdhInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Witdh".localized()
        input.textfield.placeholder = "Witdh".localized()
        input.unitsLabel.text = "mm"
        return input
    }()
    
    lazy var fuelTankHeightInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Height".localized()
        input.textfield.placeholder = "Height".localized()
        input.unitsLabel.text = "mm"
        return input
    }()
    
    lazy var compareVoltageInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Compare Voltage".localized()
        input.textfield.placeholder = "Compare Voltage".localized()
        input.textfield.text = "1152"
        input.unitsLabel.text = "v"
        return input
    }()
    

}


extension AddNewDeviceViewController: BKRemotePeripheralDelegate, BKRemotePeerDelegate {
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
