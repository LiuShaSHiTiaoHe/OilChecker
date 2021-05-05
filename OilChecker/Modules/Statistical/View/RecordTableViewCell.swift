//
//  RecordTableViewCell.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/5.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

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
    
    func setupUI(){
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(recordDateLabel)
        self.contentView.addSubview(contentBackView)
        contentBackView.addSubview(contentTitle)
        contentBackView.addSubview(contentMessage)
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        recordDateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalTo(dateLabel.snp.bottom).offset(kMargin/2)
            make.width.equalTo(100)
            make.bottom.equalToSuperview().offset(-kMargin)
        }
        
        contentBackView.snp.makeConstraints { (make) in
            make.left.equalTo(dateLabel.snp.right).offset(kMargin)
            make.right.equalToSuperview().offset(-kMargin)
            make.top.equalToSuperview().offset(kMargin)
            make.bottom.equalToSuperview().offset(-kMargin)
            
        }
        
        contentTitle.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.left.equalToSuperview().offset(kMargin/2)
            make.height.equalTo(30)
        }
        
        contentMessage.snp.makeConstraints { (make) in
            make.top.equalTo(contentTitle.snp.bottom).offset(kMargin/2)
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.bottom.equalToSuperview()
        }
        

    }
    
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kGaryFontColor
        label.textAlignment = .left
        label.font = k12Font
        return label
    }()
    
    lazy var recordDateLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kOrangeColor
        label.textAlignment = .left
        label.font = k20Font
        return label
    }()
    
    lazy var contentBackView: UIView = {
        let view = UIView.init()
        view.backgroundColor = kWhiteColor
        view.layer.cornerRadius = 10.0
        view.shadowRadius = 10
        view.shadowOpacity = 0.5
        view.shadowColor = kLightGaryFontColor
        view.shadowOffset = CGSize.init(width: 2, height: 2)
        return view
    }()
    
    lazy var contentTitle: UILabel = {
        let label = UILabel.init()
        label.textColor = kGaryFontColor
        label.textAlignment = .left
        label.font = k12Font
        return label
    }()

    lazy var contentMessage: UILabel = {
        let label = UILabel.init()
        label.textColor = kBlackFontColor
        label.textAlignment = .left
        label.font = k20Font
        return label
    }()
}
