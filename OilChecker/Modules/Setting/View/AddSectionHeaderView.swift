//
//  AddSectionHeaderView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/23.
//

import UIKit

class AddSectionHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.addSubview(titleLabel)
        self.addSubview(addNewCarButton)
//        self.addSubview(arrowImageView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        
        addNewCarButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin/2)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
//        arrowImageView.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-kMargin/2)
//            make.width.height.equalTo(15)
//            make.centerY.equalToSuperview()
//        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.font = k15Font
        label.textColor = kSecondBlackColor
        label.text = "My Car".localized()
        label.textAlignment = .left
        return label
    }()
    
    lazy var addNewCarButton: UIButton = {
        let btn = UIButton.init(type: .custom)
//        btn.setTitle("Add New Car", for: .normal)
//        btn.setTitleColor(kGaryFontColor, for: .normal)
//        btn.titleLabel?.font = k12Font
        btn.setImage(UIImage.init(named: "btn_add"), for: .normal)
        btn.addTarget(self, action: #selector(addNewCarAction), for: .touchUpInside)
        return btn
    }()
    
//    lazy var arrowImageView: UIImageView = {
//        let imageView = UIImageView.init(image: UIImage.init(named: "icon_arrow"))
//        return imageView
//    }()
    
    @objc
    func addNewCarAction() {
        self.viewContainingController()?.navigationController?.pushViewController(AddNewDeviceViewController())
//        self.navigationController?.pushViewController(AddNewDeviceViewController(), animated: true)

    }
}
