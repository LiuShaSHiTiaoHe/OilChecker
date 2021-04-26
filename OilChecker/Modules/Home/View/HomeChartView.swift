//
//  HomeChartView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/26.
//

import UIKit

class HomeChartView: UIView {

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
        
    }

}
