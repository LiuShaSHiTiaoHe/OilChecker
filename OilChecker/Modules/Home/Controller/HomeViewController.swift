//
//  HomeViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/20.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults
import DropDown

class HomeViewController: UIViewController {

    let realm = try! Realm()
    var userCarArray: [UserAndCarModel] = []
    var currentCarModel: UserAndCarModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = kBackgroundColor
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Home".localized()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightAddButton)
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()

        if userCarArray.count == 0 {
            carNumberButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
            carNumberButton.setTitle("Add New Car", for: .normal)
            carNumberButton.setImage(UIImage.init(named: "btn_addCar"), for: .normal)
            carNumberButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: kMargin)

        }else{
            if Defaults[\.currentCarID]!.isEmpty {
                currentCarModel = userCarArray[0]
                Defaults[\.currentCarID] = currentCarModel!.id
            }else{
                currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
                    model.id == Defaults[\.currentCarID]
                }).first
            }
            carNumberButton.setImage(UIImage.init(named: ""), for: .normal)
            carNumberButton.setTitle(currentCarModel?.carNumber, for: .normal)
            setUpDropDownView()
        }
        
    }
    
    @objc
    func addButtonAction() {
        logger.info("addButtonAction")
    }
    
    func initData()  {
        let models = realm.objects(UserAndCarModel.self)
        userCarArray = models.filter({ (model) -> Bool in
            !model.isDeleted
        })
    }
    
    func setUpDropDownView() {
        let dropDown = DropDown()
        dropDown.anchorView = carNumberButton
        var titles:[String] = []
        for item in userCarArray {
            titles.append(item.carNumber)
        }
        dropDown.dataSource = titles
        dropDown.offsetFromWindowBottom = 60
        dropDown.direction = .bottom
        dropDown.width = 100
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        }
    }
    
    func initUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(carNumberButton)
        scrollContentView.addSubview(deviceSwitchButton)
        scrollContentView.addSubview(capacityView)
        scrollContentView.addSubview(consumptionView)
        scrollContentView.addSubview(chartView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.height.greaterThanOrEqualTo(scrollView).offset(1)
        }
        
        carNumberButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalToSuperview().offset(kMargin)
            make.right.equalTo(scrollContentView.snp.centerX).offset(-kMargin/2)
            make.height.equalTo(60)
        }
        
        deviceSwitchButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin/2)
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalTo(scrollContentView.snp.centerX).offset(kMargin/2)
            make.height.equalTo(60)
        }
        
        capacityView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.top.equalTo(carNumberButton.snp.bottom).offset(kMargin)
            make.right.equalTo(scrollContentView.snp.centerX).offset(-kMargin/2)
            make.height.equalTo(100)
        }
        
        consumptionView.snp.makeConstraints { (make) in
            make.centerY.equalTo(capacityView.snp.centerY)
            make.height.equalTo(100)
            make.left.equalTo(scrollContentView.snp.centerX).offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.top.equalTo(capacityView.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.height.equalTo(400)
        }
    }
    
    lazy var rightAddButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 80, height: 30)
        btn.backgroundColor = kThemeColor
        btn.layer.cornerRadius = 15
        btn.setTitle("Add", for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        return btn
    }()
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        return scroll
    }()
    
    lazy var scrollContentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = kBackgroundColor
        return view
    }()
    
    lazy var carNumberButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("Add New Car", for: .normal)
        btn.setTitleColor(kGreenFontColor, for: .normal)
        btn.titleLabel?.font = k15BoldFont
        btn.backgroundColor = kWhiteColor
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var deviceSwitchButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("Off", for: .normal)
        btn.setTitle("On", for: .selected)
        btn.setTitleColor(kRedFontColor, for: .normal)
        btn.setTitleColor(kGreenFontColor, for: .selected)
        btn.setImage(UIImage.init(named: "btn_off_red"), for: .normal)
        btn.setImage(UIImage.init(named: "btn_on_green"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: kMargin)
        btn.backgroundColor = kWhiteColor
        btn.titleLabel?.font = k15BoldFont
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var capacityView: FuelCapacityView = {
        let view = FuelCapacityView()
        view.nameLabel.text = "Fuel Capacity"
        view.unitsLabel.text = "L"
        return view
    }()
    
    lazy var consumptionView: FuelCapacityView = {
        let view = FuelCapacityView()
        view.nameLabel.text = "Fuel Consumption"
        view.unitsLabel.text = "L"
        return view
    }()
    
    lazy var chartView: HomeChartView = {
        let view = HomeChartView.init()
        return view
    }()
    


}



