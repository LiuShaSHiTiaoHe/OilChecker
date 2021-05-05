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
    let dropDown = DropDown()

    
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

    }
    
    @objc
    func addButtonAction() {
        self.navigationController?.pushViewController(AddNewDeviceViewController())
        logger.info("addButtonAction")
    }
    
    @objc
    func carNumberButtonAction() {
        if userCarArray.count > 1 {
            setUpDropDownView()
            dropDown.show()
        }
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
            carNumberLabel.text = "- -"

        }else{
            if Defaults[\.currentCarID]!.isEmpty {
                currentCarModel = userCarArray[0]
                Defaults[\.currentCarID] = currentCarModel!.id
            }else{
                currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
                    model.id == Defaults[\.currentCarID]
                }).first
                chartView.updateCurrentDevice(model: currentCarModel!)

            }
//            carNumberButton.setImage(nil, for: .normal)
//            carNumberButton.setTitle(currentCarModel?.carNumber, for: .normal)
            carNumberLabel.text = currentCarModel?.carNumber
            updateLatestFuelCapacityAndConsumption(deviceID: currentCarModel?.deviceID)

        }
    }
    
    func updateLatestFuelCapacityAndConsumption(deviceID: String?) {
        guard let _ = deviceID else {
            return
        }
        let startDate = getDataRegion().dateAt(.startOfDay).date
        let endDate = getDataRegion().dateAt(.endOfDay).date
        let capacity = realm.objects(BaseFuelDataModel.self).filter("rTime BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, deviceID!).sorted(byKeyPath: "rTime").last
        capacityView.numberLabel.text = capacity?.fuelLevel.string
        
        let consumption = realm.objects(FuelConsumptionModel.self).filter("time BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, deviceID!).sorted(byKeyPath: "time").last
        consumptionView.numberLabel.text = consumption?.consumption.string
    }
    
    func setUpDropDownView() {
//        dropDown.anchorView = carNumberButton
        dropDown.anchorView = carNumberLabel
        var titles:[String] = []
        for item in userCarArray {
            titles.append(item.carNumber)
        }
        dropDown.dataSource = titles
        dropDown.backgroundColor = kBackgroundColor
        dropDown.bottomOffset = CGPoint.init(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        dropDown.width = 100
        dropDown.setupCornerRadius(10)
        dropDown.textColor = kSecondBlackColor
        dropDown.selectedTextColor = kGreenFontColor
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            let model = userCarArray[index]
//            carNumberButton.setTitle(model.carNumber, for: .normal)
            carNumberLabel.text = model.carNumber
            Defaults[\.currentCarID] = model.id
            chartView.updateCurrentDevice(model: model)
            updateLatestFuelCapacityAndConsumption(deviceID: model.deviceID)
        }
    }
    
    func initUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
//        scrollContentView.addSubview(carNumberButton)
        scrollContentView.addSubview(carNumberLabel)
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
        
//        carNumberButton.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(kMargin/2)
//            make.top.equalToSuperview().offset(kMargin)
//            make.right.equalTo(scrollContentView.snp.centerX).offset(-kMargin/2)
//            make.height.equalTo(60)
//        }
        
        carNumberLabel.snp.makeConstraints { (make) in
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
            make.top.equalTo(carNumberLabel.snp.bottom).offset(kMargin)
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
        btn.backgroundColor = kThemeGreenColor
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
    
//    lazy var carNumberButton: UIButton = {
//        let btn = UIButton.init(type: .custom)
//        btn.setTitle("Add New Car", for: .normal)
//        btn.setTitleColor(kGreenFontColor, for: .normal)
//        btn.titleLabel?.font = k15Font
//        btn.backgroundColor = kWhiteColor
//        btn.layer.cornerRadius = 10
//        btn.addTarget(self, action: #selector(carNumberButtonAction), for: .touchUpInside)
//        return btn
//    }()
    
    lazy var carNumberLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = kWhiteColor
        label.font = UIFont.systemFont(ofSize: 30)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.textColor = kSecondBlackColor
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(carNumberButtonAction)))
        return label
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
        view.numberLabel.textColor = kThemeGreenColor
        view.unitsLabel.text = "L"
        return view
    }()
    
    lazy var consumptionView: FuelCapacityView = {
        let view = FuelCapacityView()
        view.nameLabel.text = "Fuel Consumption"
        view.numberLabel.textColor = kRedFontColor
        view.unitsLabel.text = "L"
        return view
    }()
    
    lazy var chartView: HomeChartView = {
        let view = HomeChartView.init()
        return view
    }()
    


}



