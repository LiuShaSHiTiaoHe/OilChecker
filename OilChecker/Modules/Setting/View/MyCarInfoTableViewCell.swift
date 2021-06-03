//
//  MyCarInfoTableViewCell.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import SwiftDate

class MyCarInfoTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//#E6E7FD
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCellValue(_ value: UserAndCarModel) {
        carNumberLabel.text = value.carNumber
        userName.text = value.deviceID
        timeLabel.text = value.createTime.toString(.custom(BaseDateFormatString))
        fuelTankVolumeLabel.text = NSDecimalNumber.init(value: value.fuelTankHeight).multiplying(by: NSDecimalNumber.init(value: value.fuelTankLength)).multiplying(by: NSDecimalNumber.init(value: value.fuelTankWidth)).stringValue + "L"
    }
    
    func setupUI(){
        self.contentView.addSubview(bgView)
        bgView.addSubview(carNumberLabel)
        bgView.addSubview(userName)
        bgView.addSubview(fuelTankVolumeLabel)
        bgView.addSubview(timeLabel)
        fuelTankVolumeLabel.isHidden = true
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/4)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.bottom.equalToSuperview().offset(-kMargin/4)
        }
        
        carNumberLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.top.equalToSuperview().offset(kMargin)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-kMargin*2-100)
        }
        
        userName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.top.equalTo(carNumberLabel.snp.bottom).offset(kMargin/4)
            make.height.equalTo(20)
            make.width.equalTo(150)
        }
        
        fuelTankVolumeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin)
            make.height.equalTo(30)
            make.width.equalTo(100)
            make.top.equalToSuperview().offset(kMargin)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin)
            make.top.equalTo(fuelTankVolumeLabel.snp.bottom).offset(kMargin/4)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
    }
    
    lazy var bgView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: 0xE6E7FD)
        view.layer.cornerRadius = 10
        view.shadowOffset = CGSize.init(width: 2, height: 2)
        view.shadowRadius = 5
        view.shadowColor = kBlackColor
        view.shadowOpacity = 0.2
//        view.layer.masksToBounds = false
        
        return view
    }()
    
    lazy var carNumberLabel: UILabel = {
        let label = UILabel.init()
        label.font = k20BoldFont
        label.textColor = kSecondBlackColor
        label.textAlignment = .left
        return label
    }()
    
    lazy var userName: UILabel = {
        let label = UILabel.init()
        label.font = k13Font
        label.textColor = kSecondBlackColor
        label.textAlignment = .left
        return label
    }()
    
    lazy var fuelTankVolumeLabel: UILabel = {
        let label = UILabel.init()
        label.font = k13Font
        label.textColor = kThemeColor
        label.textAlignment = .right
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel.init()
        label.font = k12Font
        label.textColor = kSecondBlackColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
}
