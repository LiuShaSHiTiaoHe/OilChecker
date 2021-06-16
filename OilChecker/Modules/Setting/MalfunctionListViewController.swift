//
//  MalfunctionListViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/24.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults
let MalfunctionTableViewCellIdentifier = "MalfunctionTableViewCellIdentifier"


class MalfunctionListViewController: UIViewController {

    let realm = try! Realm()
    var dataArray: [MalfunctionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    func initUI(){
        self.navigationItem.title = "Malfuntion".localized()
        self.view.backgroundColor = kWhiteColor
        self.view.addSubview(tableView)
        tableView.register(MalfunctionTableViewCell.self, forCellReuseIdentifier: MalfunctionTableViewCellIdentifier)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initData()
    }
    
    func initData(){
        let currentCarModel = realm.objects(UserAndCarModel.self).filter({ (model) -> Bool in
            model.id == Defaults[\.currentCarDeviceID]
        }).first
        guard let _ = currentCarModel else {
            return
        }
        let models = realm.objects(MalfunctionModel.self).filter("deviceID ==  %@", currentCarModel!.deviceID)
        dataArray = models.filter({ (model) -> Bool in
            !model.isDeleted
        })
        tableView.reloadData()
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView()
        table.backgroundColor = kWhiteColor
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .singleLine
        return table
    }()

    
}
extension MalfunctionListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MalfunctionTableViewCellIdentifier, for: indexPath) as! MalfunctionTableViewCell
        let model = dataArray[indexPath.row]
        cell.updateCellValue(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}
