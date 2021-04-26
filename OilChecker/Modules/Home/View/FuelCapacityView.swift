//
//  FuelCapacityView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit

class FuelCapacityView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.layer.cornerRadius = 10
        self.backgroundColor = kWhiteColor
        
        self.addSubview(nameLabel)
        self.addSubview(numberLabel)
        self.addSubview(unitsLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(20)
        }
        
        numberLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
//            make.top.equalTo(nameLabel.snp.bottom).offset(kMargin/4)
            make.bottom.equalToSuperview().offset(-kMargin/4)
            make.right.equalToSuperview().offset(-kMargin*1.5)
            make.height.equalTo(30)
        }
        
        unitsLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(numberLabel.snp.right)
            make.centerY.equalTo(numberLabel.snp.centerY)
            make.height.equalTo(30)
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k12Font
        label.textAlignment = .left
        return label
    }()

    lazy var numberLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k14Font
        label.textAlignment = .right
        return label
    }()
    
    lazy var unitsLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k12Font
        label.textAlignment = .left
        return label
    }()
}
