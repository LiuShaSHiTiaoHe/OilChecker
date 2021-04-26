//
//  FuelConsumptionDetailViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit

class FuelConsumptionDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Fuel Consumption".localized()
        self.view.backgroundColor = kBackgroundColor
        
        initUI()
    }
    
    func initUI() {
        
    }
    
    lazy var backContentView: UIView = {
        let view = UIView.init()
        return view
    }()
    
    lazy var startLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .right
        label.textColor = kSecondBlackColor
        label.font = k13Font
        return label
    }()

    lazy var startTimeButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kSecondBlackColor, for: .normal)
        return btn
    }()
    
    lazy var endLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .right
        label.textColor = kSecondBlackColor
        label.font = k13Font
        return label
    }()

    lazy var endTimeButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kSecondBlackColor, for: .normal)
        return btn
    }()
    
    
}
