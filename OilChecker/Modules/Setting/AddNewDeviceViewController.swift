//
//  AddNewDeviceViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import SkyFloatingLabelTextField
import GMStepper
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
        btn.backgroundColor = kThemeColor
        btn.layer.cornerRadius = 15
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var userNameTextfield: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField.init()
        tf.placeholder = "Enter Your Name"
        tf.title = "Name"
        tf.placeholderFont = k14Font
        tf.titleFont = k12Font
        tf.font = k14Font
        
        tf.tintColor = kThemeColor
        tf.selectedLineColor = kThemeColor
        tf.selectedTitleColor = kThemeColor
        return tf
    }()
    
    lazy var carNumberTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField.init()
        tf.placeholder = "Enter Your Car Number"
        tf.title = "Car Number"
        tf.placeholderFont = k14Font
        tf.titleFont = k12Font
        tf.font = k14Font
        
        tf.tintColor = kThemeColor
        tf.selectedLineColor = kThemeColor
        tf.selectedTitleColor = kThemeColor
        return tf
    }()

    
    lazy var tankTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField.init()
        tf.placeholder = "Volume"
        tf.title = "Volume"
        tf.placeholderFont = k12Font
        tf.titleFont = k12Font
        tf.font = k14Font
        
        tf.tintColor = kThemeColor
        tf.selectedLineColor = kThemeColor
        tf.selectedTitleColor = kThemeColor
        tf.keyboardType = .numberPad
        tf.delegate = self

        return tf
    }()
    
    lazy var tankVolumeUnits: UILabel = {
        let label = UILabel()
        label.text = " = "
        label.textColor = kThemeColor
        label.textAlignment = .left
        label.font = k12Font
        return label
    }()
    
    
    lazy var tankAreaField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField.init()
        tf.placeholder = "Area"
        tf.title = "Area"
        tf.placeholderFont = k12Font
        tf.titleFont = k12Font
        tf.font = k14Font
        
        tf.tintColor = kThemeColor
        tf.selectedLineColor = kThemeColor
        tf.selectedTitleColor = kThemeColor
        tf.keyboardType = .numberPad
        tf.delegate = self

        return tf
    }()
    
    lazy var tankAreaUnits: UILabel = {
        let label = UILabel()
        label.text = " X "
        label.textColor = kThemeColor
        label.textAlignment = .left
        label.font = k12Font

        return label
    }()
    
    
    lazy var tankHeightField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField.init()
        tf.placeholder = "Height"
        tf.title = "Height"
        tf.placeholderFont = k12Font
        tf.titleFont = k12Font
        tf.font = k14Font
        
        tf.tintColor = kThemeColor
        tf.selectedLineColor = kThemeColor
        tf.selectedTitleColor = kThemeColor
        tf.keyboardType = .numberPad
        tf.delegate = self
        return tf
    }()
    
    lazy var tankHeightUnits: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = kThemeColor
        label.textAlignment = .left
        label.font = k12Font
        return label
    }()
    
    
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
        scrollView.addSubview(userNameTextfield)
        scrollView.addSubview(carNumberTextField)
        scrollView.addSubview(tankTextField)
        
        scrollView.addSubview(tankVolumeUnits)
        scrollView.addSubview(tankAreaField)
        scrollView.addSubview(tankAreaUnits)
        scrollView.addSubview(tankHeightField)
        scrollView.addSubview(tankHeightUnits)

        
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        userNameTextfield.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(200)
            make.height.equalTo(TextFieldHeight)
            make.top.equalToSuperview().offset(kMargin)
        }
        
        carNumberTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(200)
            make.height.equalTo(TextFieldHeight)
            make.top.equalTo(userNameTextfield.snp.bottom).offset(kMargin*2)
        }
        
        
        tankTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(80)
            make.height.equalTo(TextFieldHeight)
            make.top.equalTo(carNumberTextField.snp.bottom).offset(kMargin*2)
        }
        
        tankVolumeUnits.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.left.equalTo(tankTextField.snp.right).offset(kMargin/2)
            make.bottom.equalTo(tankTextField.snp.bottom)
        }
        
        tankAreaField.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(TextFieldHeight)
            make.left.equalTo(tankVolumeUnits.snp.right)
            make.bottom.equalTo(tankTextField.snp.bottom)

        }
        
        tankAreaUnits.snp.makeConstraints { (make) in
            make.bottom.equalTo(tankTextField.snp.bottom)
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.left.equalTo(tankAreaField.snp.right).offset(kMargin/2)
        }
        
        tankHeightField.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(TextFieldHeight)
            make.bottom.equalTo(tankTextField.snp.bottom)
            make.left.equalTo(tankAreaUnits.snp.right)
        }
        
        tankHeightUnits.snp.makeConstraints { (make) in
            make.bottom.equalTo(tankTextField.snp.bottom)
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.left.equalTo(tankHeightField.snp.right)
        }
    }

    
    @objc
    func saveButtonAction() {
        logger.info("saveButtonAction")
        let nameString = userNameTextfield.text
        let carNumberSting = carNumberTextField.text
        let volumeString = tankTextField.text
        let tankBottomArea = tankAreaField.text
        let tankHeight = tankHeightField.text
        
        if !nameString!.isEmpty && !carNumberSting!.isEmpty && !volumeString!.isEmpty && !tankBottomArea!.isEmpty && !tankHeight!.isEmpty {
            let userModel = UserAndCarModel()
            userModel.carNumber = carNumberSting!
            userModel.fuelTankHeight = tankHeight!.float()!
            userModel.fuelTankBottomArea = tankBottomArea!.float()!
            userModel.fuelTankVolume = volumeString!.float()!
            userModel.time = NSDate.now.string(withFormat: "yyyy-MM-dd HH:mm:ss")
            userModel.name = nameString!
            SettingManager.shared.updateUserCarInfo(userModel)
            SVProgressHUD.showSuccess(withStatus: "Add Success")
            self.navigationController?.popViewController(animated: true)
        }else{
            SVProgressHUD.showError(withStatus: "Please Enter Correctly")
        }
        
        
        
        
    }
}

extension AddNewDeviceViewController: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var updatedText = ""
        if let text = textField.text,let textRange = Range(range, in: text) {
                updatedText = text.replacingCharacters(in: textRange,with: string)
        }
        if updatedText.isEmpty || updatedText == "0"{
            return true
        }
        
        if textField == tankTextField {

            if !tankAreaField.text!.isEmpty{
                let height = NSDecimalNumber.init(string: updatedText).dividing(by: NSDecimalNumber.init(string: tankAreaField.text)).stringValue
                tankHeightField.text = height
            }
        }
        
        if textField == tankAreaField {
            
            if !tankTextField.text!.isEmpty {
                let height = NSDecimalNumber.init(string: tankTextField.text).dividing(by: NSDecimalNumber.init(string: updatedText)).stringValue
                tankHeightField.text = height
            }else{
                if !tankHeightField.text!.isEmpty {
                    let height = NSDecimalNumber.init(string: tankHeightField.text).multiplying(by: NSDecimalNumber.init(string: updatedText)).stringValue
                    tankTextField.text = height
                }
            }
        }
        if textField == tankHeightField {
            if !tankAreaField.text!.isEmpty {
                let height = NSDecimalNumber.init(string: tankAreaField.text).multiplying(by: NSDecimalNumber.init(string: updatedText)).stringValue
                tankTextField.text = height
            }else{
                if !tankTextField.text!.isEmpty {
                    let height = NSDecimalNumber.init(string: tankTextField.text).dividing(by: NSDecimalNumber.init(string: updatedText)).stringValue
                    tankAreaField.text = height
                }
            }
        }
        return true
    }
}
