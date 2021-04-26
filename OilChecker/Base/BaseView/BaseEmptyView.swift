//
//  BaseEmptyView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit

class BaseEmptyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.addSubview(emptyImageView)
        
        emptyImageView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
//            make.left.right.equalToSuperview()
            make.width.height.equalTo(120)
        }
    }
    
    lazy var emptyImageView: UIImageView = {
        let view = UIImageView.init()
        return view
    }()

}
