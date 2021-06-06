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

extension AddNewDeviceViewController: BKRemotePeripheralDelegate, BKRemotePeerDelegate {
    func remotePeripheral(_ remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        logger.info("didUpdateName \(name)")
    }
    
    func remotePeripheralIsReady(_ remotePeripheral: BKRemotePeripheral) {
        logger.info("Peripheral ready: \(remotePeripheral)")
        SVProgressHUD.showInfo(withStatus: "Device is ready")
        if sendDataState == .RequestDeviceParamers {
            requestDeviceInfo()
        }
    }
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        logger.info("didSendArbitraryData \(data)")
    }
    
}


class AddNewDeviceViewController: UIViewController {

    var central: BKCentral? = OCBlueToothManager.shared.central
    var remotePeripheral: BKRemotePeripheral? = OCBlueToothManager.shared.connectedRemotePeripheral
    private var sendDataState: BleSendDataState = .RequestDeviceParamers
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
    
    func sendDeviceInfo(_ deviceID: String, _ length: String, _ width: String, _ height: String, _ compareV: String) {
        var datas: [UInt8] = []
        
        let defaultDeviceID: [UInt8] = DefualtDeviceID.hw_to2Bytes()
        
        let deviceSettingID: [UInt8] = OCByteManager.shared.bytes(from: deviceID)
        let deviceLength: [UInt8] = Int(length)!.hw_to2Bytes()
        let deviceWidth: [UInt8] = Int(width)!.hw_to2Bytes()
        let deviceHeight: [UInt8] = Int(height)!.hw_to2Bytes()
        let deviceCompareV: [UInt8] = Int(compareV)!.hw_to2Bytes()

        datas.append(0x02)//STX 1字节
        datas.append(0x0F)//数据长度  10字节
        datas.append(0x0F)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x83)//CMD ID  参数设置应答 0x83
        datas.append(deviceSettingID[0])
        datas.append(deviceSettingID[1])
        
        datas.append(deviceLength[0])
        datas.append(deviceLength[1])
        
        datas.append(deviceWidth[0])
        datas.append(deviceWidth[1])
        
        datas.append(deviceHeight[0])
        datas.append(deviceHeight[1])
        
        datas.append(deviceCompareV[0])
        datas.append(deviceCompareV[1])
        
        var  checkSum: UInt8 = 0x00
        checkSum += 0x0F
        checkSum += 0x0F
        checkSum += defaultDeviceID[0] + defaultDeviceID[1]
        checkSum += 0x01
        checkSum += 0x83
        checkSum += deviceSettingID[0] + deviceSettingID[1]
        checkSum += deviceLength[0] + deviceLength[1]
        checkSum += deviceWidth[0] + deviceWidth[1]
        checkSum += deviceCompareV[0] + deviceCompareV[1]

        datas.append(checkSum^checkSum)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x30)//ETX 0x30
        
        let sendData = Data(bytes: datas)
        central!.sendData(sendData, toRemotePeer: remotePeripheral!) { data, remotepeer, error in
            guard error == nil else {
                SVProgressHUD.showError(withStatus: "Failed sending to \(remotepeer.identifier)")
                return
            }
            logger.info("send Data \(data) to  remote \(remotepeer)")
            SVProgressHUD.showSuccess(withStatus: "Sent Data to \(remotepeer.identifier)")
        }
        
    }
    
    func requestDeviceInfo() {

        let defaultDeviceID: [UInt8] = DefualtDeviceID.hw_to2Bytes()
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
        central!.sendData(sendData, toRemotePeer: remotePeripheral!) { data, remotepeer, error in
            guard error == nil else {
                SVProgressHUD.showError(withStatus: "Failed sending to \(remotepeer.identifier)")
                return
            }
            logger.info("send Data \(data) to  remote \(remotepeer)")
            SVProgressHUD.showSuccess(withStatus: "Sent Data to \(remotepeer.identifier)")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    func initData() {
        SVProgressHUD.show()
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
        input.textfield.keyboardType = .default
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



