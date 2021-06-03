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
        self.addSubview(statusLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(20)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.bottom.equalToSuperview().offset(-kMargin/4)
            make.right.equalToSuperview().offset(-kMargin)
            make.top.equalTo(nameLabel.snp.bottom)
        }
        
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k16Font
        label.textAlignment = .left
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kThemeGreenColor
        label.font = k20Font
        label.textAlignment = .right
        return label
    }()
    

}
