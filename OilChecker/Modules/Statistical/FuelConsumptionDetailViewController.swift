//
//  FuelConsumptionDetailViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults
import SwiftDate
import DatePickerDialog

class FuelConsumptionDetailViewController: UIViewController {

    let realm = try! Realm()
    var dataArray: [FuelConsumptionModel] = []
    var currentCarModel: UserAndCarModel!
    
    var startDate: Date = getDataRegion().dateAt(.startOfWeek).date
    var endDate: Date = getDataRegion().dateAt(.endOfWeek).date
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Fuel Consumption".localized()
        self.view.backgroundColor = kBackgroundColor
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
            model.id == Defaults[\.currentCarID]
        }).first
        initData()
    }
    
    func initData() {
        
        guard let _ = currentCarModel else {
            return
        }
        startTimeButton.setTitle(startDate.string(withFormat: "yyyy-MM-dd"), for: .normal)
        endTimeButton.setTitle(endDate.string(withFormat: "yyyy-MM-dd"), for: .normal)
        let dataSource = realm.objects(FuelConsumptionModel.self).filter("time BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, currentCarModel!.deviceID).sorted(byKeyPath: "time")
        dataArray = Array(dataSource)
        tableView.reloadData()
    }
    
    func initUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc
    func selectStartTime() {
        DatePickerDialog.init().show("pick start time", doneButtonTitle: "Done", cancelButtonTitle: "Cancle", defaultDate: Date(), minimumDate: nil, maximumDate: getDataRegion().dateAt(.endOfWeek).date, datePickerMode: .date) {[self] (selectedDate) in
            guard let _ = selectedDate else{
                return
            }
            startDate = selectedDate!
            startTimeButton.setTitle(startDate.string(withFormat: "yyyy-MM-dd"), for: .normal)
            queryDataWithSelectedDate()
        }
    }
    
    @objc
    func selectEndTime() {
        DatePickerDialog.init().show("pick start time", doneButtonTitle: "Done", cancelButtonTitle: "Cancle", defaultDate: Date(), minimumDate: nil, maximumDate: getDataRegion().dateAt(.endOfWeek).date, datePickerMode: .date) {[self]  (selectedDate) in
            
            guard let _ = selectedDate else{
                return
            }
            
            endDate = selectedDate!
            endTimeButton.setTitle(endDate.string(withFormat: "yyyy-MM-dd"), for: .normal)
            queryDataWithSelectedDate()
        }
    }
    
    func queryDataWithSelectedDate() {
        let dataSource = realm.objects(FuelConsumptionModel.self).filter("time BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, currentCarModel!.deviceID).sorted(byKeyPath: "time")
        dataArray = Array(dataSource)
        tableView.reloadData()
    }
    
    lazy var backContentView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 40))
        view.addSubview(startTimeButton)
        view.addSubview(toLabel)
        view.addSubview(endTimeButton)
        startTimeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kMargin)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }

        toLabel.snp.makeConstraints { (make) in
            make.left.equalTo(startTimeButton.snp.right).offset(kMargin/2)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        endTimeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(toLabel.snp.right).offset(kMargin/2)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        return view
    }()

    lazy var startTimeButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kSecondBlackColor, for: .normal)
        btn.backgroundColor = kBackgroundColor
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(selectStartTime), for: .touchUpInside)
        return btn
    }()

    lazy var toLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        label.textColor = kSecondBlackColor
        label.font = k13Font
        label.text = "to"
        return label
    }()

    lazy var endTimeButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = k13Font
        btn.setTitleColor(kSecondBlackColor, for: .normal)
        btn.backgroundColor = kBackgroundColor
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(selectEndTime), for: .touchUpInside)
        return btn
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView()
        table.backgroundColor = kWhiteColor
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.tableHeaderView = backContentView
        table.register(RecordTableViewCell.self, forCellReuseIdentifier: "RecordTableViewCell")
        return table
    }()
    
}

extension FuelConsumptionDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell") as! RecordTableViewCell
        let model = dataArray[indexPath.row]
        cell.contentTitle.text = "Consumption"
        cell.dateLabel.text = model.time.string(withFormat: "yyyy")
        cell.recordDateLabel.text = model.time.string(withFormat: "MM-dd")
        cell.contentMessage.text = model.consumption.string + "  L"
        cell.contentMessage.textColor = kRedFontColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}
