//
//  AddNewDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import SkyFloatingLabelTextField
import CoreBluetooth
import SVProgressHUD

let TextFieldHeight = 45

class AddNewDeviceViewController: UIViewController {

    let baby = BabyBluetooth.share();
    var currentPeripheral: CBPeripheral!
    
    private var readCBCharacteristic: CBCharacteristic?
    private var writeCBCharacteristic: CBCharacteristic?
    private var services: [CBService] = []
    
    private var sendDataState: BleSendDataState = .RequestDeviceParamers
    private var originalDeviceIDFromDevice: String = "0000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kWhiteColor
        self.navigationItem.title = "Add A Device".localized()
        // Do any additional setup after loading the view.
        initUI()
        addBabyDelegate()
        initData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        baby?.cancelAllPeripheralsConnection()
    }
    
    func initData() {
        SVProgressHUD.show()
        if currentPeripheral == nil {
            return
        }
        baby?.having(currentPeripheral).channel(BabyChannelAddDeviceIdentifier).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin()
    }
    
    
    func addBabyDelegate() {

        //设备连接成功
        baby?.setBlockOnConnectedAtChannel(BabyChannelAddDeviceIdentifier, block: { central, peripheral in
            logger.info("设备连接成功")
            SVProgressHUD.showSuccess(withStatus: "Successfully connected the device".localized())
            self.currentPeripheral = peripheral!
        })
        
        baby?.setBlockOnFailToConnectAtChannel(BabyChannelAddDeviceIdentifier, block: { central, peripheral, error in
            SVProgressHUD.showError(withStatus: "Failed to connect device".localized())
            logger.info("连接设备失败")
            self.navigationController?.popViewController()
        })
        
        
        //发现设备的服务
        baby?.setBlockOnDiscoverServicesAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, error in
            self.services.removeAll()
            for service in peripheral!.services! {
                logger.info("设备的服务 + \(service.uuid.uuidString)")
                self.services.append(service)
            }
        })
        
        //发现设service的Characteristics
        baby?.setBlockOnDiscoverCharacteristicsAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, service, error in
            guard service != nil else {
                return
            }
            if service!.uuid.uuidString == ServiceUUIDString {
                let characteristics = service!.characteristics!
                for c in characteristics {
                    logger.info("发现设service的Characteristics + \(c.uuid.uuidString)")
                    if c.uuid.uuidString == CharacteristicNotifyUUIDString {
                        self.readCBCharacteristic = c
                        self.currentPeripheral.setNotifyValue(true, for: self.readCBCharacteristic!)
                    }
                    if c.uuid.uuidString == CharacteristicWriteUUIDString {
                        self.writeCBCharacteristic = c
                        self.currentPeripheral.setNotifyValue(true, for: self.writeCBCharacteristic!)
                        self.requestDeviceInfo()
                    }
                }
            }

        })
        
        //读取characteristics
        baby?.setBlockOnReadValueForCharacteristicAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            
            guard characteristic != nil else{
                return
            }
            logger.info("读取characteristics UUID + \(characteristic!.uuid.uuidString)")
            logger.info("读取characteristics Value + \(String(describing: characteristic!.value?.hexa))")
            if characteristic!.uuid.uuidString != CharacteristicNotifyUUIDString && characteristic!.uuid.uuidString != CharacteristicWriteUUIDString {
                return
            }

            if let value = characteristic!.value {
                var binary = Binary.init(bytes: value.bytes)
                if binary.count < 10 {
                    return
                }
                let _ = try? binary.readBytes(1)//stx
                let _ = try? binary.readBytes(1)//dataLength
                let _ = try? binary.readBytes(1)//length comp
                let _ = try? binary.readBytes(2)//deviceID
                let property = try? binary.readBytes(1)
                if property![0] != 0x00 {
                    logger.info("Hard -> APP")
                    return
                }
                let cmd = try? binary.readBytes(1)
                guard cmd != nil else {
                    return
                }
                if cmd![0] == 0x86 {//请求设备信息应答
                    guard self.sendDataState == .RequestDeviceParamers else {
                        return
                    }
                    let deviceID = try? binary.readBytes(2)
                    if let deviceIDString = deviceID?.hexa  {
                        SVProgressHUD.showSuccess(withStatus: "Requested device info successfully".localized())
                        let length = try? binary.readBytes(2)
                        let width = try? binary.readBytes(2)
                        let height = try? binary.readBytes(2)
                        let compareV = try? binary.readBytes(2)
                        
                        self.originalDeviceIDFromDevice = deviceIDString
                        if deviceIDString !=  DefualtDeviceID.intTo2Bytes().hexa{//已经被设置过的设备
                            if length?.hexa != "FFFF" && width?.hexa != "FFFF" && height?.hexa != "FFFF" && compareV?.hexa != "FFFF" {//设备参数符合标准
                                let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(deviceIDString)'").first
                                let userModel = UserAndCarModel()
                                if carModel == nil {//本地没有存储当前设备，添加到本地
                                    userModel.carNumber = ""
                                }else{//本地有存储当前设备，更新设备参数
                                    userModel.carNumber = carModel!.carNumber
                                }
                                userModel.deviceID = deviceIDString
                                userModel.fuelTankLength = OCByteManager.shared.integer(from: length!.hexa).float
                                userModel.fuelTankWidth = OCByteManager.shared.integer(from: width!.hexa).float
                                userModel.fuelTankHeight = OCByteManager.shared.integer(from: height!.hexa).float
                                userModel.voltage = OCByteManager.shared.integer(from: compareV!.hexa)
                                self.updateViewValues(userModel)

                            }else{
                                SVProgressHUD.showInfo(withStatus: "Set device parameters".localized())
                            }
                        }else{
                            SVProgressHUD.showInfo(withStatus: "Set device parameters".localized())
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "Set device parameters".localized())
                    }
                    
                }
                
                if cmd![0] == 0x84 {//参数设置应答
                    guard self.sendDataState == .RequestSettingDeviceParamers else {
                        return
                    }
                    let response = try? binary.readBytes(1)
                    if response?[0] == 0x00 {
                        self.saveToRealmDataBase()
                        SVProgressHUD.showInfo(withStatus: "set device info successfully, Please restart the device!".localized())
                        self.baby?.cancelAllPeripheralsConnection()
                        self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        SVProgressHUD.show(withStatus: "Failed to set device info".localized())
                    }
                }
            }
        })


        baby?.setBlockOnDidWriteValueForCharacteristicAtChannel(BabyChannelAddDeviceIdentifier, block: { characteristic, error in
            guard characteristic != nil else {
                return
            }
            logger.info("写入数据成功\(characteristic!.uuid.uuidString)")
        })
        
        baby?.setBlockOnDidUpdateNotificationStateForCharacteristic({ characteristic, error in
            guard characteristic != nil else {
                return
            }
            guard self.currentPeripheral != nil else {
                return
            }
            self.currentPeripheral!.readValue(for: characteristic!)
            if characteristic!.isNotifying {
                self.currentPeripheral!.readValue(for: characteristic!)
            }
        })
    }

    
    @objc
    func editButtonAction() {
        
    }
    
    @objc
    func saveButtonAction() {
        if bottomSaveButton.title(for: .normal) == "Edit".localized() {
            let alertView = UIAlertController.init(title: "Tips".localized(), message: "ChangeDeviceInfoTips".localized(), preferredStyle: .alert)

            let alert = UIAlertAction.init(title: "Confirm".localized(), style: .destructive) {[unowned self] (UIAlertAction) in
                allowEdit(true)
                bottomSaveButton.setTitle("Save".localized(), for: .normal)
            }
            let cancleAlert = UIAlertAction.init(title: "Cancle".localized(), style: .cancel) { (UIAlertAction) in
                
            }
            alertView.addAction(cancleAlert)
            alertView.addAction(alert);
            self.present(alertView, animated: true, completion: nil)
        }else{
            let deviceID = deviceIDInput.textfield.text
            let carNumberSting = carNumberInput.textfield.text
            let tankLength = fuelTankLengthInput.textfield.text
            let tankWitdh = fuelTankWitdhInput.textfield.text
            let tankHeight = fuelTankHeightInput.textfield.text
            let compareV = compareVoltageInput.textfield.text
            
            if !deviceID!.isEmpty && !carNumberSting!.isEmpty && !tankLength!.isEmpty && !tankWitdh!.isEmpty && !tankHeight!.isEmpty && !compareV!.isEmpty {
                sendDeviceInfo(deviceID!, tankLength!, tankWitdh!, tankHeight!, compareV!)
            }else{
                SVProgressHUD.showError(withStatus: "Please Enter Correctly".localized())
            }
        }
    }
    
    func updateViewValues(_ model: UserAndCarModel) {
        deviceIDInput.textfield.text = model.deviceID
        carNumberInput.textfield.text = model.carNumber
        fuelTankLengthInput.textfield.text = model.fuelTankLength.string
        fuelTankWitdhInput.textfield.text = model.fuelTankWidth.string
        fuelTankHeightInput.textfield.text = model.fuelTankHeight.string
        compareVoltageInput.textfield.text = model.voltage.string
        allowEdit(false)
        bottomSaveButton.setTitle("Edit".localized(), for: .normal)
    }
    
    func allowEdit(_ allowEdit: Bool)  {
        deviceIDInput.textfield.isUserInteractionEnabled = allowEdit
        carNumberInput.textfield.isUserInteractionEnabled = allowEdit
        fuelTankLengthInput.textfield.isUserInteractionEnabled = allowEdit
        fuelTankWitdhInput.textfield.isUserInteractionEnabled = allowEdit
        fuelTankHeightInput.textfield.isUserInteractionEnabled = allowEdit
        compareVoltageInput.textfield.isUserInteractionEnabled = allowEdit
    }
    
    func saveToRealmDataBase() {
        
        let deviceID = deviceIDInput.textfield.text
        let carNumberSting = carNumberInput.textfield.text
        let tankLength = fuelTankLengthInput.textfield.text
        let tankWitdh = fuelTankWitdhInput.textfield.text
        let tankHeight = fuelTankHeightInput.textfield.text
        let compareV = compareVoltageInput.textfield.text
        
        let userModel = UserAndCarModel()
        let localCacheData = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(deviceID!)'").first
        if localCacheData != nil {
            userModel.id = localCacheData!.id
        }
        userModel.deviceID = deviceID!
        userModel.carNumber = carNumberSting!
        userModel.fuelTankLength = tankLength!.float()!
        userModel.fuelTankWidth = tankWitdh!.float()!
        userModel.fuelTankHeight = tankHeight!.float()!
        userModel.createTime = NSDate.now
        userModel.voltage = compareV!.int!
        SettingManager.shared.updateUserCarInfo(userModel)
//        SVProgressHUD.showSuccess(withStatus: "Add Success".localized())
        self.navigationController?.popViewController(animated: true)
    }
    
    //设置设备信息
    func sendDeviceInfo(_ deviceID: String, _ length: String, _ width: String, _ height: String, _ compareV: String) {
        
        sendDataState = .RequestSettingDeviceParamers
        var datas: [UInt8] = []
        let defaultDeviceID: [UInt8] = OCByteManager.shared.integer(from: originalDeviceIDFromDevice).intTo2Bytes()//deviceID.hexa//DefualtDeviceID.intTo2Bytes()
        let deviceSettingID: [UInt8] = OCByteManager.shared.integer(from: deviceID).intTo2Bytes()//deviceID.double()!.int.intTo2Bytes()
        let deviceLength: [UInt8] = length.double()!.int.intTo2Bytes()
        let deviceWidth: [UInt8] = width.double()!.int.intTo2Bytes()
        let deviceHeight: [UInt8] = height.double()!.int.intTo2Bytes()
        let deviceCompareV: [UInt8] = compareV.double()!.int.intTo2Bytes()

        datas.append(0x02)//STX 1字节
        datas.append(0x0A)//数据长度  10字节
        datas.append(0xF6)//数据长补数 1字节
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
        
        var  bcc: UInt8 = 0x00
        bcc ^= 0x0A
        bcc ^= 0xF6
        bcc ^= defaultDeviceID[0]
        bcc ^= defaultDeviceID[1]
        bcc ^= 0x01
        bcc ^= 0x83
        bcc ^= deviceSettingID[0]
        bcc ^= deviceSettingID[1]
        bcc ^= deviceLength[0]
        bcc ^= deviceLength[1]
        bcc ^= deviceWidth[0]
        bcc ^= deviceWidth[1]
        bcc ^= deviceHeight[0]
        bcc ^= deviceHeight[1]
        bcc ^= deviceCompareV[0]
        bcc ^= deviceCompareV[1]

        datas.append(bcc)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showError(withStatus: "Please reconnect the device".localized())
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            logger.info("发送配置数据 + \(writeCBCharacteristic!.uuid.uuidString) + \(sendData.bytes.hexa)")
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
            SVProgressHUD.dismiss()
        }
    }
    
    func requestDeviceInfo() {
        sendDataState = .RequestDeviceParamers
        let defaultDeviceID: [UInt8] = DefualtDeviceID.intTo2Bytes()
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x01)//数据长度  1字节
        datas.append(0xFF)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x85)//CMD ID
        datas.append(0x11)
        
        var  bcc: UInt8 = 0x00
        bcc ^= 0x01
        bcc ^= 0xFF
        bcc ^= defaultDeviceID[0]
        bcc ^= defaultDeviceID[1]
        bcc ^= 0x01
        bcc ^= 0x85
        bcc ^= 0x11

        datas.append(bcc)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)
        if writeCBCharacteristic == nil {
            SVProgressHUD.showError(withStatus: "Please reconnect the device".localized())
        }else{
            logger.info("请求设备信息 + \(writeCBCharacteristic!.uuid.uuidString) + \(sendData.bytes.hexa)")
            currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
        }
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
        scrollView.addSubview(bottomSaveButton)
        
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
        }
        
        bottomSaveButton.snp.makeConstraints { make  in
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
    
    lazy var bottomSaveButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kThemeGreenColor
        btn.layer.cornerRadius = 10
        btn.setTitle("Save".localized(), for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k16Font
        btn.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return btn
    }()
    
//    private let editButton: UIButton = {
//        let btn = UIButton.init(type: .custom)
//        btn.backgroundColor = kThemeGreenColor
//        btn.layer.cornerRadius = 10
//        btn.setTitle("Edit".localized(), for: .normal)
//        btn.setTitleColor(kWhiteColor, for: .normal)
//        btn.titleLabel?.font = k16Font
//        btn.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
//        return btn
//    }()
    
    
    
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
        input.textfield.inputView = digitesKeyboardView
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
        input.textfield.text = "1551"
        input.unitsLabel.text = "v"
        return input
    }()
    
    lazy var digitesKeyboardView: KeyboardView = {
        let keyboard = KeyboardView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: DigtesKeyboardHeight))
        keyboard.delegate = self
        return keyboard
    }()

}

extension AddNewDeviceViewController: KeyboardViewDelegate{
    func keyboardViewDeleteText() {
        guard deviceIDInput.textfield.text != nil else {
            return
        }
        if deviceIDInput.textfield.text!.count > 0 {
            deviceIDInput.textfield.text?.removeLast()
        }
    }
    
    func keyboardEnterText(_ text: String) {
        if deviceIDInput.textfield.text == nil {
            deviceIDInput.textfield.text = text
        }else{
            if deviceIDInput.textfield.text!.count == 4 {
                return
            }else{
                deviceIDInput.textfield.text! += text
            }
        }
    }
    
    
}



