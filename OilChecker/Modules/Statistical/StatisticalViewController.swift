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
    let dropDown = DropDown()
//    var fuelLeveData :[FuelLevelModel] = []
    
    
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
            carNumberButton.setTitle("Add New Car", for: .normal)
            carNumberButton.setImage(UIImage.init(named: "btn_addCar"), for: .normal)
            carNumberButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: kMargin/2, bottom: 0, right: kMargin)

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
            carNumberButton.setImage(nil, for: .normal)
            carNumberButton.setTitle(currentCarModel?.carNumber, for: .normal)
        }
    }
    
    
    func setUpDropDownView() {
        dropDown.anchorView = carNumberButton
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
            carNumberButton.setTitle(model.carNumber, for: .normal)
            Defaults[\.currentCarID] = model.id
            refuelLevelView.updateCurrentDevice(model: model)
            fuelConsumptionView.updateCurrentDevice(model: model)
        }
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
        scrollContentView.addSubview(carNumberButton)
        scrollContentView.addSubview(fuelConsumptionView)
        scrollContentView.addSubview(refuelLevelView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.height.greaterThanOrEqualTo(scrollView).offset(1)
        }
        
        carNumberButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(120)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(kMargin)
        }
        
        fuelConsumptionView.snp.makeConstraints { (make) in
            make.top.equalTo(carNumberButton.snp.bottom).offset(kMargin/2)
            make.left.equalToSuperview().offset(kMargin)
            make.right.equalToSuperview().offset(-kMargin)
            make.height.equalTo(400)
        }
        
        refuelLevelView.snp.makeConstraints { (make) in
            make.top.equalTo(fuelConsumptionView.snp.bottom).offset(kMargin)
            make.left.equalToSuperview().offset(kMargin)
            make.right.equalToSuperview().offset(-kMargin)
            make.height.equalTo(400)
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
    
    lazy var carNumberButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("", for: .normal)
        btn.setTitleColor(kSecondBlackColor, for: .normal)
        btn.titleLabel?.font = k20BoldFont
        btn.addTarget(self, action: #selector(carNumberButtonAction), for: .touchUpInside)
//        btn.semanticContentAttribute = .forceRightToLeft
        return btn
    }()
    
    lazy var fuelConsumptionView: FuelConsumptionView = {
        let view = FuelConsumptionView.init()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showFuelConsumptionDetail)))
//        view.detailButton.addTarget(self, action: #selector(showFuelConsumptionDetail), for: .touchUpInside)
        return view
    }()
    
    lazy var refuelLevelView: RefuelRecordView = {
        let view = RefuelRecordView.init()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showRefuelRecordDetail)))
//        view.detailButton.addTarget(self, action: #selector(showRefuelRecordDetail), for: .touchUpInside)
        return view
    }()
}


