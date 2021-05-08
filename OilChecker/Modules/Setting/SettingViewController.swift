//
//  SettingViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/21.
//

import UIKit
import RealmSwift

let SettingTableViewCellIdentifier = "SettingTableViewCellIdentifier"
let AddNewCarTableViewCellIdentifier = "AddNewCarTableViewCellIdentifier"
let MyCarInfoTableViewCellIdentifier = "MyCarInfoTableViewCellIdentifier"

class SettingViewController: UIViewController {

    let realm = try! Realm()
    var dataArray: [UserAndCarModel] = []
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView()
        table.backgroundColor = kWhiteColor
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Mine".localized()
        self.view.backgroundColor = kBackgroundColor
        self.view.addSubview(tableView)
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCellIdentifier)
        tableView.register(AddNewCarTableViewCell.self, forCellReuseIdentifier: AddNewCarTableViewCellIdentifier)
        tableView.register(MyCarInfoTableViewCell.self, forCellReuseIdentifier: MyCarInfoTableViewCellIdentifier)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initData()
    }
    
    func initData(){
        let models = realm.objects(UserAndCarModel.self)
        dataArray = models.filter({ (model) -> Bool in
            !model.isDeleted
        })
        if dataArray.count > 0 {
            tableView.tableHeaderView = AddSectionHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 40))
        }else{
            tableView.tableHeaderView = UIView()
        }
        tableView.reloadData()
    }

}


extension SettingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if dataArray.count == 0 {
                return 1
            }else{
                return dataArray.count
            }
        case 1:
            return 2
        default:
            return 0
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        default:
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if dataArray.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: AddNewCarTableViewCellIdentifier, for: indexPath) as! AddNewCarTableViewCell
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: MyCarInfoTableViewCellIdentifier, for: indexPath) as! MyCarInfoTableViewCell
                let model = dataArray[indexPath.row]
                cell.updateCellValue(model)
                cell.selectionStyle = .none
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCellIdentifier, for: indexPath) as! SettingTableViewCell
            if indexPath.row == 0 {
                cell.updateCellValue(text: "Equipment Malfunction", imageName: "icon_error")
            }else{
                cell.updateCellValue(text: "Search Device", imageName: "icon_findble")
            }
            return cell
            
         
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "table", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
                
        switch indexPath.section {
        case 0:
            if dataArray.count == 0 {
                self.navigationController?.pushViewController(AddNewDeviceViewController(), animated: true)
            }else{
                
            }
        case 1:
            if indexPath.row == 0 {
                self.navigationController?.pushViewController(MalfunctionListViewController())
            }else{
                self.navigationController?.pushViewController(ScanBleDeviceViewController(), animated: true)
            }
        default:
            fatalError()
        }
    }
    
    
}
