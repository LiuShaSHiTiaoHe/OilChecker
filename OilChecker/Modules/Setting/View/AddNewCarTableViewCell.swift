//
//  AddNewCarTableViewCell.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/23.
//

import UIKit

class AddNewCarTableViewCell: UITableViewCell {

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
        
        self.contentView.addSubview(bgView)
        self.contentView.addSubview(bigAddImage)
        self.contentView.addSubview(tipsLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/4)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.bottom.equalToSuperview().offset(-kMargin/4)
        }
        
        bigAddImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(32)
            make.right.equalToSuperview().dividedBy(2.5)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bigAddImage.snp.right).offset(kMargin/2)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-kMargin)
            make.centerY.equalToSuperview()
        }

    }
    
    lazy var bgView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: 0xE6E7FD)
        view.shadowOffset = CGSize.init(width: 0, height: 2)
        view.shadowRadius = 5
        view.shadowColor = .black
        view.shadowOpacity = 0.2
        view.layer.masksToBounds = false
//        view.cornerRadius = 10
        return view
    }()
    
    lazy var bigAddImage : UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "btn_bigadd"))
        return imageView
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel.init()
        label.text = "Add New Device".localized()
        label.textColor = kSecondBlackColor
        label.font = k12Font
        label.textAlignment = .left
        return label
    }()
}
