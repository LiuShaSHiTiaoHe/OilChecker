//
//  StatisticalViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import RealmSwift
import DropDown
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
                Defaults[\.currentCarID] = currentCarModel!.id
            }else{
                currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
                    model.id == Defaults[\.currentCarID]
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
        scrollContentView.addSubview(fuelConsumptionView)
        scrollContentView.addSubview(refuelLevelView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(900)
        }
        
        fuelConsumptionView.snp.makeConstraints { (make) in
//            make.top.equalTo(carNumberButton.snp.bottom).offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(400)
        }
        
        refuelLevelView.snp.makeConstraints { (make) in
            make.top.equalTo(fuelConsumptionView.snp.bottom).offset(kMargin)
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
    
    
    lazy var fuelConsumptionView: FuelConsumptionView = {
        let view = FuelConsumptionView.init()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showFuelConsumptionDetail)))
        return view
    }()
    
    lazy var refuelLevelView: RefuelRecordView = {
        let view = RefuelRecordView.init()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showRefuelRecordDetail)))
        return view
    }()
}


