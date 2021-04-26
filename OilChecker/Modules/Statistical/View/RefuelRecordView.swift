//
//  RefuelRecord.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit

class RefuelRecordView: UIView {

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
        
        self.addSubview(titleLabel)
        self.addSubview(detailButton)
        self.addSubview(lineView)
        self.addSubview(emptyView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin/2)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-100)
        }
        
        detailButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin/2)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(kMargin/4)
        }
        
        emptyView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kBlackColor
        label.font = k15Font
        label.text = "Refuel Record"
        return label
    }()
    
    lazy var detailButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_arrow"), for: .normal)
        btn.setTitleColor(kBlackColor, for: .normal)
        btn.titleLabel?.font = k13BoldFont
        return btn
    }()
    
    lazy var lineView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: 0x515151, transparency: 0.2)
        return view
    }()
    
    lazy var emptyView: BaseEmptyView = {
        let view = BaseEmptyView.init()
        view.emptyImageView.image = UIImage.init(named: "em_charts")
        return  view
    }()

}
