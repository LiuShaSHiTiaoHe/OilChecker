//
//  AppParamatersSettingViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/7/4.
//

import UIKit
import SwiftyUserDefaults
import SVProgressHUD

class AppParamatersSettingViewController: UIViewController {

    @objc
    func saveButtonAction() {
        if let newValue = thresholdsInput.textfield.text?.double() {
            Defaults[\.kThresholds] = newValue
            
            self.navigationController?.popViewController(animated: true, {
                SVProgressHUD.showSuccess(withStatus: "setAppParamatersSuccess".localized())
            })
        }else{
            SVProgressHUD.showError(withStatus: "inputErrorData".localized())
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        scroll.backgroundColor = kWhiteColor
        scroll.contentSize = .init(width: kScreenWidth, height: kScreenHeight)
        return scroll
    }()
    
    lazy var thresholdsInput: OCInputView = {
        let input = OCInputView.init()
        input.titleLabel.text = "setting_threshold".localized()
        input.textfield.placeholder = ""
        input.textfield.keyboardType = .numberPad
        input.unitsLabel.text = "L"
        return input
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kWhiteColor
        self.navigationItem.title = "setting_threshold".localized()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    func initUI() {
        self.view.backgroundColor = kWhiteColor

        self.view.addSubview(scrollView)
        let scrollBackView = UIView.init()
        scrollView.addSubview(scrollBackView)
        scrollView.addSubview(thresholdsInput)
        scrollView.addSubview(bottomSaveButton)

        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollBackView.snp.makeConstraints({ (make) in
           make.edges.equalToSuperview()
           make.width.equalTo(kScreenWidth)
           make.height.greaterThanOrEqualTo(scrollView).offset(1)
        })
        
        thresholdsInput.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(80)
            make.width.equalTo(kScreenWidth - kMargin*2)
        }
        
        bottomSaveButton.snp.makeConstraints { make  in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(kScreenWidth - kMargin*2)
            make.height.equalTo(50)
            make.top.equalTo(thresholdsInput.snp.bottom).offset(kMargin*5)
//            make.bottom.equalToSuperview().offset(-kMargin*2)
            make.bottom.lessThanOrEqualTo(scrollView.snp.bottom).offset(-kMargin)

        }
        
        let thresHolds = Defaults[\.kThresholds]
        thresholdsInput.textfield.text = thresHolds.string
        
    }
}
