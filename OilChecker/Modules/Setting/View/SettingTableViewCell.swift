//
//  SettingTableViewCell.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/21.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.backgroundColor = kWhiteColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(contentTextLabel)
        self.contentView.addSubview(bootomLine)
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kMargin)
            make.width.height.equalTo(30)
        }
        
        contentTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(kMargin)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-kMargin*2)
        }
        
        bootomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin*2)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-kMargin*2)
            make.height.equalTo(1)
        }
        
    }

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    lazy var contentTextLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .left
        label.textColor = kSecondBlackColor
        label.font = k14Font
        return label
    }()
    
    lazy var bootomLine: UIView = {
        let line = UIView.init()
        line.backgroundColor = kGrayLineColor
        return line
    }()
    
    func updateCellValue(text: String, imageName: String) {
        iconImageView.image = UIImage(named: imageName)
        contentTextLabel.text = text
    }
}
