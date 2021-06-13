//
//  StatisticalViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults
import SwiftDate

class StatisticalViewController: UIViewController {

    let realm = try! Realm()
    var currentCarModel: UserAndCarModel?
    var userCarArray: [UserAndCarModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Statistical".localized()
        self.view.backgroundColor = kBackgroundColor
//        GlobalDataMananger.shared.fuelDataProcessor(Defaults[\.currentCarID]!)
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initData()
    }
    
    
    func initData()  {
        let models = realm.objects(UserAndCarModel.self)
        userCarArray = models.filter({ (model) -> Bool in
            !model.isDeleted
        })
        
        if userCarArray.count == 0 {
//            carNumberButton.setTitle("Add New Car", for: .normal)
//            carNumberButton.setImage(UIImage.init(named: "btn_addCar"), for: .normal)
//            carNumberButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: kMargin/2, bottom: 0, right: kMargin)

        }else{
            if Defaults[\.currentCarID]!.isEmpty {
                currentCarModel = userCarArray[0]
                Defaults[\.currentCarID] = currentCarModel!.deviceID
            }else{
                currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
                    model.deviceID == Defaults[\.currentCarID]
                }).first
                refuelLevelView.updateCurrentDevice(model: currentCarModel!)
                fuelConsumptionView.updateCurrentDevice(model: currentCarModel!)
            }
        }
    }
    
    
    @objc
    func showFuelConsumptionDetail() {
        self.navigationController?.pushViewController(FuelConsumptionDetailViewController())
    }
    
    @objc
    func showRefuelRecordDetail(){
        self.navigationController?.pushViewController(RefuelRecordDetailViewController())
    }
    
    func initUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(fuelConsumptionTitleLabel)
        scrollContentView.addSubview(fuelConsumptionView)
        scrollContentView.addSubview(refuelLevelTitleLabel)
        scrollContentView.addSubview(refuelLevelView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(1000)
        }
        
        fuelConsumptionTitleLabel.snp.makeConstraints { make  in
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(30)
            make.right.equalToSuperview()
        }
        fuelConsumptionView.snp.makeConstraints { (make) in
            make.top.equalTo(fuelConsumptionTitleLabel.snp.bottom).offset(kMargin/2)
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(400)
        }
        
        refuelLevelTitleLabel.snp.makeConstraints { make  in
            make.top.equalTo(fuelConsumptionView.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.height.equalTo(30)
            make.right.equalToSuperview()
        }
        
        refuelLevelView.snp.makeConstraints { (make) in
            make.top.equalTo(refuelLevelTitleLabel.snp.bottom).offset(kMargin/2)
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(400)
            make.bottom.equalToSuperview().offset(-kMargin)
        }
        
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        return scroll
    }()
    
    lazy var scrollContentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = kBackgroundColor
        return view
    }()
    
    lazy var fuelConsumptionTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k20Font
        label.text = "Fuel Consumption".localized()
        return label
    }()
    
    lazy var fuelConsumptionView: FuelConsumptionView = {
        let view = FuelConsumptionView.init()
        view.detailButton.addTarget(self, action: #selector(showFuelConsumptionDetail), for: .touchUpInside)
        return view
    }()
    
    lazy var refuelLevelTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = kSecondBlackColor
        label.font = k20Font
        label.text = "Refuel Record".localized()
        return label
    }()
    lazy var refuelLevelView: RefuelRecordView = {
        let view = RefuelRecordView.init()
        view.detailButton.addTarget(self, action: #selector(showRefuelRecordDetail), for: .touchUpInside)
        return view
    }()
}


