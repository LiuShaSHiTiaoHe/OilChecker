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
        textColor = UIColor.init(hex: 0x333333)!
//        highlightTextColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(hex: 0x5944DD)!

        iconColor = UIColor.init(hex: 0x333333)!
//        highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(hex: 0x5944DD)!

    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
