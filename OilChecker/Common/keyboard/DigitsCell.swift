//
//  DigitsCell.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/6/15.
//

import UIKit

class DigitsCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
          
    }
    
    func initUI() {
        self.addSubview(numbeLabel)
        numbeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    lazy var numbeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        label.font = k16Font
        label.textColor = kThemeGreenColor
        return label
    }()
    
    func updateCellValue(_ number: String) {
        numbeLabel.text = number
    }
}
