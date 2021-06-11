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
            SVProgressHUD.showSuccess(withStatus: "连接设备成功")
//            SVProgressHUD.show()
        })
        
        baby?.setBlockOnFailToConnectAtChannel(BabyChannelAddDeviceIdentifier, block: { central, peripheral, error in
            SVProgressHUD.showError(withStatus: "连接设备失败")
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
            let characteristics = service?.characteristics as! Array<CBCharacteristic>
            for c in characteristics {
                logger.info("发现设service的Characteristics + \(c.uuid.uuidString)")
                if c.uuid.uuidString == CharacteristicNotifyUUIDString {
                    self.readCBCharacteristic = c
                    self.setNotify()
                }
                if c.uuid.uuidString == CharacteristicWriteUUIDString {
                    self.writeCBCharacteristic = c
                    self.requestDeviceInfo()
                }
            }
        })
        
        baby?.setBlockOnDiscoverDescriptorsForCharacteristicAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            
            if characteristic == nil {
                return
            }
            logger.info("Descriptors + \(characteristic!.uuid.uuidString)")

        })
        
        //读取characteristics
        baby?.setBlockOnReadValueForCharacteristicAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            logger.info("读取characteristics UUID + \(characteristic!.uuid.uuidString)")
            logger.info("读取characteristics Value + \(characteristic!.value)")
            if characteristic != nil {
                if let value = characteristic!.value {
                    var binary = Binary.init(bytes: value.bytes)
                    if binary.count < 10 {
                        return
                    }
                    let _ = try? binary.readBytes(1)//stx
                    let _ = try? binary.readBytes(1)//dataLength
                    let _ = try? binary.readBytes(1)//length comp
                    let dataDeviceID = try? binary.readBytes(2)//deviceID
                    let stringDID = dataDeviceID?.hexa
                    logger.info("\(String(describing: stringDID))")
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
                        SVProgressHUD.show(withStatus: "请求设备信息应答成功")
                        let deviceID = try? binary.readBytes(2)
                        let length = try? binary.readBytes(2)
                        let width = try? binary.readBytes(2)
                        let height = try? binary.readBytes(2)
                        let compareV = try? binary.readBytes(2)
                        if deviceID?.hexa !=  DefualtDeviceID.intTo2Bytes().hexa{//已经被设置过的设备
                            if length?.hexa != "FFFF" && width?.hexa != "FFFF" && height?.hexa != "FFFF" && compareV?.hexa != "FFFF" {//设备参数符合标准
                                let deviceIDString = deviceID?.hexa
                                let deviceIDIntValue = OCByteManager.shared.integer(from: deviceIDString!)
                                let carModel = RealmHelper.queryObject(objectClass: UserAndCarModel(), filter: "deviceID = '\(deviceIDIntValue.string)'").first
                                if carModel == nil {//本地没有存储当前设备，添加到本地
                                    let userModel = UserAndCarModel()
                                    userModel.deviceID = deviceIDIntValue.string
                                    userModel.carNumber = ""
                                    userModel.fuelTankLength = OCByteManager.shared.integer(from: length!.hexa).float
                                    userModel.fuelTankWidth = OCByteManager.shared.integer(from: width!.hexa).float
                                    userModel.fuelTankHeight = OCByteManager.shared.integer(from: height!.hexa).float
                                    userModel.createTime = NSDate.now
                                    userModel.voltage = OCByteManager.shared.integer(from: compareV!.hexa)
                                    self.updateViewValues(carModel!)
                                }else{//本地有存储当前设备，更新设备参数
                                    carModel!.fuelTankLength = (length?.hexa.float())!
                                    carModel!.fuelTankHeight = (height?.hexa.float())!
                                    carModel!.fuelTankWidth = (width?.hexa.float())!
                                    SettingManager.shared.updateUserCarInfo(carModel!)
                                    self.updateViewValues(carModel!)
                                }
                            }else{
                                SVProgressHUD.show(withStatus: "设置参数参数有误,请重新设置")
                            }
                        }else{
                            SVProgressHUD.show(withStatus: "新设备，请设置参数")
                        }
                    }
                    
                    if cmd![0] == 0x84 {//参数设置应答
                        let response = try? binary.readBytes(1)
                        if response?[0] == 0x00 {
                            self.saveToRealmDataBase()
                            SVProgressHUD.show(withStatus: "设备参数设置成功")
                        }else{
                            SVProgressHUD.show(withStatus: "设备参数设置失败")
                        }
                    }
                }
            }
        })

        baby?.setBlockOnReadValueForDescriptorsAtChannel(BabyChannelAddDeviceIdentifier, block: { peripheral, characteristic, error in
            logger.info("读取Descriptors + \(characteristic!.uuid.uuidString)")
        })
        
    }
    
    func setNotify() {
        guard readCBCharacteristic != nil else {
            return
        }
        if readCBCharacteristic?.isNotifying == false {
            logger.info("readCBCharacteristic?.isNotifying == false   setNotify")
            currentPeripheral.setNotifyValue(true, for: readCBCharacteristic!)
        }
   
    }
    
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
            sendDeviceInfo(deviceID!, tankLength!, tankWitdh!, tankHeight!, compareV!)
        }else{
            SVProgressHUD.showError(withStatus: "Please Enter Correctly".localized())
        }
    }
    
    func updateViewValues(_ model: UserAndCarModel) {
        deviceIDInput.textfield.text = model.deviceID
        carNumberInput.textfield.text = model.carNumber
        fuelTankLengthInput.textfield.text = model.fuelTankLength.string
        fuelTankWitdhInput.textfield.text = model.fuelTankWidth.string
        fuelTankHeightInput.textfield.text = model.fuelTankHeight.string
        compareVoltageInput.textfield.text = model.voltage.string
    }
    
    func saveToRealmDataBase() {
        
        let deviceID = deviceIDInput.textfield.text
        let carNumberSting = carNumberInput.textfield.text
        let tankLength = fuelTankLengthInput.textfield.text
        let tankWitdh = fuelTankWitdhInput.textfield.text
        let tankHeight = fuelTankHeightInput.textfield.text
        let compareV = compareVoltageInput.textfield.text
        
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
    }
    
    //设置设备信息
    func sendDeviceInfo(_ deviceID: String, _ length: String, _ width: String, _ height: String, _ compareV: String) {
        
        sendDataState = .RequestSettingDeviceParamers
        var datas: [UInt8] = []
        let defaultDeviceID: [UInt8] = DefualtDeviceID.intTo2Bytes()
        let deviceSettingID: [UInt8] = deviceID.hexa//OCByteManager.shared.bytes(from: deviceID)
        let deviceLength: [UInt8] = Int(length)!.intTo2Bytes()
        let deviceWidth: [UInt8] = Int(width)!.intTo2Bytes()
        let deviceHeight: [UInt8] = Int(height)!.intTo2Bytes()
        let deviceCompareV: [UInt8] = Int(compareV)!.intTo2Bytes()

        datas.append(0x02)//STX 1字节
        datas.append(0x0F)//数据长度  10字节
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
        
        var  checkSum: UInt8 = 0x00
        checkSum ^= 0x0F
        checkSum ^= 0xF6
        checkSum ^= defaultDeviceID[0]
        checkSum ^= defaultDeviceID[1]
        checkSum ^= 0x01
        checkSum ^= 0x83
        checkSum ^= deviceSettingID[0]
        checkSum ^= deviceSettingID[1]
        checkSum ^= deviceLength[0]
        checkSum ^= deviceLength[1]
        checkSum ^= deviceWidth[0]
        checkSum ^= deviceWidth[1]
        checkSum ^= deviceCompareV[0]
        checkSum ^= deviceCompareV[1]

        datas.append(checkSum)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
        SVProgressHUD.dismiss()
        SVProgressHUD.showSuccess(withStatus: "发送配置数据\(sendData.hexa)")
        logger.info("发送配置数据 + \(sendData)")
        logger.info("发送配置数据 + \(sendData.bytes.hexa)")
    }
    
    func requestDeviceInfo() {

        let defaultDeviceID: [UInt8] = DefualtDeviceID.intTo2Bytes()
        var datas: [UInt8] = []
        datas.append(0x02)//STX 1字节
        datas.append(0x02)//数据长度  1字节
        datas.append(0xFE)//数据长补数 1字节
        datas.append(defaultDeviceID[0])//设备ID
        datas.append(defaultDeviceID[1])
        datas.append(0x01)//帧标识 APP -> Hard 0x01
        datas.append(0x85)//CMD ID
        datas.append(0x11)
        
        var  checkSum: UInt8 = 0x00
        checkSum ^= 0x02
        checkSum ^= 0xFE
        checkSum ^= defaultDeviceID[0]
        checkSum ^= defaultDeviceID[1]
        checkSum ^= 0x01
        checkSum ^= 0x85
        checkSum ^= 0x11

        datas.append(checkSum)//BCC Lengh开始到数据区结尾数据和的异或
        datas.append(0x03)//ETX 0x03
        
        let sendData = Data.init(datas)//Data(bytes: datas)
        currentPeripheral.writeValue(sendData, for: writeCBCharacteristic!, type: .withoutResponse)
        SVProgressHUD.showSuccess(withStatus: "请求设备信息\(sendData.hexa)")
        logger.info("请求设备信息 + \(sendData)")
        logger.info("请求设备信息 + \(sendData.bytes.hexa)")
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



