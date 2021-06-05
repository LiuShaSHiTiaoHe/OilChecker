//
//  ExpandButton.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/3.
//

import UIKit

class ExpandButton: UIButton {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 15
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }

}

