//
//  SettingViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/21.
//

import UIKit
import RealmSwift
import SVProgressHUD

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
    
    lazy var rightAddButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 80, height: 30)
        btn.backgroundColor = kThemeGreenColor
        btn.layer.cornerRadius = 15
        btn.setTitle("Add".localized(), for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        return btn
    }()
    
    @objc
    func addButtonAction() {
        self.navigationController?.pushViewController(ScanBleDeviceViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Setting".localized()
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
            return 1
        case 1:
            return 3
        default:
            return 0
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if dataArray.count == 0 {
                return 100
            }else{
                return 70
            }
        default:
            return 70
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
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCellIdentifier, for: indexPath) as! SettingTableViewCell
                cell.updateCellValue(text: "Device List".localized(), imageName: "icon_list")
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCellIdentifier, for: indexPath) as! SettingTableViewCell
            if indexPath.row == 0 {
                cell.updateCellValue(text: "Equipment Malfunction Record".localized(), imageName: "icon_error")
            }else if indexPath.row == 1{
                cell.updateCellValue(text: "Search Device".localized(), imageName: "icon_findble")
            }else{
                cell.updateCellValue(text: "setting_threshold".localized(), imageName: "icon_appsetting")
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
                addButtonAction()
            }else{
                self.navigationController?.pushViewController(MyDeviceListViewController(), animated: true)
            }
        case 1:
            if indexPath.row == 0 {
                self.navigationController?.pushViewController(MalfunctionListViewController())
            }else if indexPath.row == 1{
                self.navigationController?.pushViewController(ScanBleDeviceViewController(), animated: true)
            }else{
                self.navigationController?.pushViewController(AppParamatersSettingViewController(), animated: true)

            }
        default:
            fatalError()
        }
    }
    
    
}
