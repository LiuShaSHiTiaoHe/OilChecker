//
//  BaseTabBarItemContentView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/20.
//

import UIKit
import ESTabBarController_swift
import SwifterSwift

class BaseTabBarItemContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
//        textColor = UIColor.init(hex: 0x333333)!
//        highlightTextColor = UIColor.init(hex: 0x5944DD)!

//        iconColor = UIColor.init(hex: 0x333333)!
//        highlightIconColor = UIColor.init(hex: 0x5944DD)!
    
        textColor = kSecondBlackColor
        highlightTextColor = kThemeGreenColor
        
        iconColor = kSecondBlackColor
        highlightIconColor = kThemeGreenColor

    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
