//
//  MyDeviceListViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/31.
//

import UIKit
import RealmSwift
import SwiftyUserDefaults

protocol MyDeviceListViewControllerDelegate: NSObjectProtocol {
    func selectedCarInfo(_ data: UserAndCarModel)
}


class MyDeviceListViewController: UIViewController {

    let realm = try! Realm()
    var dataSource: Array<UserAndCarModel> = []
    weak var delegate: MyDeviceListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select A Car".localized()
        // Do any additional setup after loading the view.
        initUI()
        initData()
    }
    
    
    func initUI() {
        self.view.backgroundColor = kBackgroundColor
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make  in
            make.edges.equalToSuperview()
        }
    }
    
    func initData() {
        let models = realm.objects(UserAndCarModel.self)
        dataSource = models.filter({ (model) -> Bool in
            !model.isDeleted
        })
        tableView.reloadData()
    }
    
    
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        return table
    }()
    
    lazy var rightAddButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kThemeGreenColor
        btn.layer.cornerRadius = 15
        btn.setTitle("Close".localized(), for: .normal)
        btn.setTitleColor(kWhiteColor, for: .normal)
        btn.titleLabel?.font = k13Font
        btn.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return btn
    }()
    
    @objc
    func closeButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension MyDeviceListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "MyDeviceListCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell==nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        }
        let userCar = dataSource[indexPath.row]
        cell?.textLabel?.text = userCar.carNumber + "(BT-\(userCar.deviceID))"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userCar = dataSource[indexPath.row]
        Defaults[\.currentCarDeviceID] = userCar.deviceID
        delegate?.selectedCarInfo(userCar)
        self.navigationController?.popViewController()
    }
}
