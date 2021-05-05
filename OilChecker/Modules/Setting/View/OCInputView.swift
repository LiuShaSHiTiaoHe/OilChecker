//
//  OCInputView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/6.
//

import UIKit

class OCInputView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI(){
        self.backgroundColor = kWhiteColor
//        self.layer.cornerRadius = 10
        
        self.addSubview(titleLabel)
        self.addSubview(contentBG)
        
        contentBG.addSubview(textfield)
        contentBG.addSubview(unitsLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(20)
        }
        
        contentBG.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kMargin/2)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        textfield.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-kMargin*3)
        }
        unitsLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(textfield.snp.centerY)
            make.right.equalToSuperview().offset(-kMargin/4)
            make.left.equalTo(textfield.snp.right)
            make.height.equalTo(30)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kGaryFontColor
        label.textAlignment = .left
        label.font = k18Font
        return label
    }()
    
    lazy var contentBG: UIView = {
        let view = UIView.init()
        view.backgroundColor = kBackgroundColor
        view.layer.cornerRadius = 6
        return view
    }()
    
    lazy var textfield: UITextField = {
        let tf = UITextField.init()
        tf.textColor = kSecondBlackColor
        tf.font = k15Font
        return tf
    }()
    
    lazy var unitsLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kGaryFontColor
        label.textAlignment = .left
        label.font = k12Font
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
}
