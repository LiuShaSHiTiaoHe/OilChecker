//
//  RefuelRecordDetailViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults
import SwiftDate
import BetterSegmentedControl

class RefuelRecordDetailViewController: UIViewController {

    let realm = try! Realm()
    var dataArray: [RefuelRecordModel] = []
    var currentDevice: UserAndCarModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Refuel Record".localized()
        self.view.backgroundColor = kBackgroundColor
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentDevice = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
            model.deviceID == Defaults[\.currentCarID]
        }).first
        initData()
    }
    
    func initData() {
        
        guard let _ =  currentDevice else {
            return
        }
        let dataSource = RealmHelper.queryObject(objectClass: RefuelRecordModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(20)
        updateTableDataSource(Array(dataSource))
    }
    
    func initUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    

    // MARK: - Action handlers
    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        guard currentDevice != nil else {
            return
        }
        if sender.index == 0{
            let dataSource = RealmHelper.queryObject(objectClass: RefuelRecordModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(20)
            updateTableDataSource(Array(dataSource))
        }else if sender.index == 1{
            let dataSource = RealmHelper.queryObject(objectClass: RefuelRecordModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(40)
            updateTableDataSource(Array(dataSource))
        }else {
            let dataSource = RealmHelper.queryObject(objectClass: RefuelRecordModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(60)
            updateTableDataSource(Array(dataSource))
        }
    }
    
    func updateTableDataSource(_ data: [RefuelRecordModel]) {
        dataArray = data
        tableView.reloadData()
    }
    
    lazy var backContentView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 40))
        view.addSubview(segment)
        segment.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kMargin)
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        return view
    }()

    lazy var segment: BetterSegmentedControl = {
        let segmentedControl = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: ["Week".localized(), "Month".localized(),"Year".localized()],
                                            normalTextColor: kWhiteColor,
                                            selectedTextColor: kThemeGreenColor),
            options:[.backgroundColor(kThemeGreenColor),
                     .indicatorViewBackgroundColor(kWhiteColor),
                     .cornerRadius(15.0),
                     .animationSpringDamping(1.0)])
        segmentedControl.addTarget(self,action: #selector(segmentedControlValueChanged(_:)),for: .valueChanged)
        segmentedControl.alwaysAnnouncesValue = true
        return segmentedControl
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView()
        table.backgroundColor = kWhiteColor
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .singleLine
        table.tableHeaderView = backContentView
        table.register(RecordTableViewCell.self, forCellReuseIdentifier: "RecordTableViewCell")
        return table
    }()
    
}

extension RefuelRecordDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        cell.contentTitle.text = "Refuel".localized()
        cell.dateLabel.text = model.deviceID
        cell.recordDateLabel.text = model.recordIDFromDevice.string
        cell.contentMessage.text = model.refuelLevel.string + "  L"
        cell.contentMessage.textColor = kThemeGreenColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}
