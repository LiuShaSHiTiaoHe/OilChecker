//
//  StatisticalViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import RealmSwift

class StatisticalViewController: UIViewController {

    let realm = try! Realm()
    var currentCarModel: UserAndCarModel?
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        return scroll
    }()
    
    lazy var scrollContentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = kBackgroundColor
        return view
    }()
    
    lazy var carNumberSelectButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("", for: .normal)
        btn.setTitleColor(kSecondBlackColor, for: .normal)
        btn.titleLabel?.font = k15BoldFont
        return btn
    }()
    
    lazy var fuelConsumptionView: FuelConsumptionView = {
        let view = FuelConsumptionView.init()
        view.detailButton.addTarget(self, action: #selector(showFuelConsumptionDetail), for: .touchUpInside)
        return view
    }()
    
    lazy var refuelRecordView: RefuelRecordView = {
        let view = RefuelRecordView.init()
        view.detailButton.addTarget(self, action: #selector(showRefuelRecordDetail), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Statistical".localized()
        self.view.backgroundColor = kBackgroundColor
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(carNumberSelectButton)
        scrollContentView.addSubview(fuelConsumptionView)
        scrollContentView.addSubview(refuelRecordView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.height.greaterThanOrEqualTo(scrollView).offset(1)
        }
        
        carNumberSelectButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(120)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(kMargin)
        }
        
        fuelConsumptionView.snp.makeConstraints { (make) in
            make.top.equalTo(carNumberSelectButton.snp.bottom).offset(kMargin/2)
            make.left.equalToSuperview().offset(kMargin)
            make.right.equalToSuperview().offset(-kMargin)
            make.height.equalTo(300)
        }
        
        refuelRecordView.snp.makeConstraints { (make) in
            make.top.equalTo(fuelConsumptionView.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.right.equalToSuperview().offset(-kMargin)
            make.height.equalTo(300)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initData()
    }
    
    func initData(){
        if currentCarModel != nil {
            carNumberSelectButton.setTitle(currentCarModel?.carNumber, for: .normal)
        }else{
            let models = realm.objects(UserAndCarModel.self)
            let carArray = models.filter({ (model) -> Bool in
                !model.isDeleted
            })
            if carArray.count > 0 {
                currentCarModel = carArray[0]
                carNumberSelectButton.setTitle(currentCarModel?.carNumber, for: .normal)
            }else{
                carNumberSelectButton.setTitle("Add New Car", for: .normal)
            }
        }
//        carNumberSelectButton.setupButtonImageAndTitlePossitionWith(padding: 5, style: .imageIsRight)
    }
    
    
    @objc
    func showFuelConsumptionDetail() {
        self.navigationController?.pushViewController(FuelConsumptionDetailViewController())
    }
    
    @objc
    func showRefuelRecordDetail(){
        self.navigationController?.pushViewController(RefuelRecordDetailViewController())
    }
}


