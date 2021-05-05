//
//  MalfunctionTableViewCell.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import SwiftDate
class MalfunctionTableViewCell: UITableViewCell {

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
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCellValue(_ value: MalfunctionModel) {
        titleLabel.text = value.mName
        codeLabel.text = value.mcode
        timeLabel.text = value.mtime.toString(.custom(BaseDateFormatString))
        
    }
    
    func setupUI(){
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(codeLabel)
        self.contentView.addSubview(timeLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/2)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-kMargin)
        }
        codeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.bottom.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(20)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kBlackColor
        label.textAlignment = .left
        label.font = k20Font
        return label
    }()
    
    lazy var codeLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kRedFontColor
        label.textAlignment = .left
        label.font = k14BoldFont
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kHeightGaryFontColor
        label.textAlignment = .right
        label.font = k12Font
        return label
    }()
    
 
}
