//
//  YuangongPickerViewController.swift
//  ST
//
//  Created by yunchou on 2016/11/20.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

protocol YuangongPickerViewControllerDelegate:NSObjectProtocol {
    func yuangongPickerViewControllerCancel(vc:YuangongPickerViewController)
    func yuangongPickerViewControllerSelect(vc:YuangongPickerViewController,item:Employee)
}

class YuangongPickerViewController: UIViewController {
    weak var delegate:YuangongPickerViewControllerDelegate? = nil
    var tableView:UITableView!
    var searchBar:UISearchBar!
    var empolees:[Employee] = []
    var allEmpolees:[Employee] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "速通M8"
        self.allEmpolees = DataManager.shared.employees.filter{
            $0.ownerSite == DataManager.shared.loginUser.siteName
        }
        self.searchBar = UISearchBar(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        
        self.tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.estimatedRowHeight = 30
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let cellNib = UINib(nibName: "YuangongCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "YuangongCell")
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.keyboardDismissMode = .onDrag
        self.searchBar.delegate = self
        self.empolees = self.allEmpolees
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }

}
extension YuangongPickerViewController:UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.empolees.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:YuangongCell = tableView.dequeueReusableCell(withIdentifier: "YuangongCell") as! YuangongCell
        cell.employee = self.empolees[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.empolees[indexPath.row]
        delegate?.yuangongPickerViewControllerSelect(vc: self, item: item)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.empolees = self.allEmpolees
        }else{
            self.empolees = self.allEmpolees.filter{
                $0.employeeName.contains(searchText) || $0.employeeCode.contains(searchText)
            }
        }
        self.tableView.reloadData()
    }
}
