//
//  MyDeviceListViewController.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/5/31.
//

import UIKit
import RealmSwift

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
        cell?.textLabel?.text = userCar.carNumber
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userCar = dataSource[indexPath.row]
        delegate?.selectedCarInfo(userCar)
    }
}
