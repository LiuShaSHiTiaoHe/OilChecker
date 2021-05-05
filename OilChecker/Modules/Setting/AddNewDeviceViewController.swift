//
//  AddNewDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import SkyFloatingLabelTextField
//import GMStepper
import SVProgressHUD

let TextFieldHeight = 45

class AddNewDeviceViewController: UIViewController {

    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        scroll.backgroundColor = kWhiteColor
//        scroll.contentInset = .init(top: kMargin, left: 0, bottom: 0, right: 0)
        scroll.contentSize = .init(width: kScreenWidth, height: kScreenHeight)
        return scroll
    }()
    
    lazy var rightSaveButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 80, height: 30)
        btn.backgroundColor = kThemeGreenColor
        btn.layer.cornerRadius = 15
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return btn
    }()
    
    
    
    lazy var nameInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Name"
        input.textfield.placeholder = "Enter Your Name"
        return input
    }()
    
    lazy var carNumberInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Plate Number"
        input.textfield.placeholder = "Enter Your Plate Number"
        return input
    }()
    
    
    lazy var fuelTankLengthInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Length"
        input.textfield.placeholder = "Length"
        input.unitsLabel.text = "CM"
        return input
    }()
    
    
    lazy var fuelTankWitdhInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Witdh"
        input.textfield.placeholder = "Witdh"
        input.unitsLabel.text = "CM"
        return input
    }()
    
    
    lazy var scanTimeIntervalInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Scan TimeInterval"
        input.textfield.placeholder = "Set Device Scan TimeInterval"
        input.unitsLabel.text = "Second"
        return input
    }()
    
    
    lazy var cacheStorageDurationInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "Device Storage Duration"
        input.textfield.placeholder = "Set Device Data Storage Duration"
        input.unitsLabel.text = "Day"
        return input
    }()
    
    
    //////////////////////////////////////

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kWhiteColor
        self.navigationItem.title = "Add".localized()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightSaveButton)
        // Do any additional setup after loading the view.
        initUI()
    }
    
    func initUI() {
        self.view.addSubview(scrollView)

        scrollView.addSubview(nameInput)
        scrollView.addSubview(carNumberInput)
        scrollView.addSubview(fuelTankLengthInput)
        scrollView.addSubview(fuelTankWitdhInput)
        scrollView.addSubview(scanTimeIntervalInput)
        scrollView.addSubview(cacheStorageDurationInput)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        nameInput.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*3)
        }
        
        carNumberInput.snp.makeConstraints { (make) in
            make.top.equalTo(nameInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*3)
        }
        
        fuelTankLengthInput.snp.makeConstraints { (make) in
            make.top.equalTo(carNumberInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*3)
        }
        
        fuelTankWitdhInput.snp.makeConstraints { (make) in
            make.top.equalTo(fuelTankLengthInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*3)
        }
        
        
        scanTimeIntervalInput.snp.makeConstraints { (make) in
            make.top.equalTo(fuelTankWitdhInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*3)
        }
        
        cacheStorageDurationInput.snp.makeConstraints { (make) in
            make.top.equalTo(scanTimeIntervalInput.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*3)
        }

    }

    
    @objc
    func saveButtonAction() {
        logger.info("saveButtonAction")
        let nameString = nameInput.textfield.text
        let carNumberSting = carNumberInput.textfield.text
        let tankLength = fuelTankLengthInput.textfield.text
        let tankWitdh = fuelTankWitdhInput.textfield.text
        let scanTimeIntervalString = scanTimeIntervalInput.textfield.text
        let storageDurationString = cacheStorageDurationInput.textfield.text
        
        
        
        if !nameString!.isEmpty && !carNumberSting!.isEmpty && !tankLength!.isEmpty && !tankWitdh!.isEmpty && !scanTimeIntervalString!.isEmpty && !storageDurationString!.isEmpty {
            let userModel = UserAndCarModel()
            userModel.deviceID = "999"
            userModel.carNumber = carNumberSting!
            userModel.fuelTankLength = tankLength!.float()!
            userModel.fuelTankWidth = tankWitdh!.float()!
            userModel.createTime = NSDate.now
            userModel.userName = nameString!
            userModel.deviceScanTimeInterval = scanTimeIntervalString!.float()!.int
            userModel.deviceCacheStorageDuration = storageDurationString!.float()!.int
            SettingManager.shared.updateUserCarInfo(userModel)
            SVProgressHUD.showSuccess(withStatus: "Add Success")
            self.navigationController?.popViewController(animated: true)
        }else{
            SVProgressHUD.showError(withStatus: "Please Enter Correctly")
        }
        
    }
}

