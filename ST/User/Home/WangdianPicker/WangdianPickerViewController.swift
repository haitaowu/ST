//
//  WangdianPickerViewController.swift
//  ST
//
//  Created by yunchou on 2016/11/15.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

protocol WangdianPickerInterface:WangdianPickerViewControllerDelegate{
    func showWangdianPicker()
    func onWangdianPicked(item:SiteInfo)
}

extension WangdianPickerInterface where Self:UIViewController{
    func wangdianPickerViewControllerCancel(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    func wangdianPickerViewControllerSelect(item:SiteInfo){
        self.onWangdianPicked(item: item)
        _ = self.navigationController?.popViewController(animated: true)
    }
    func showWangdianPicker(){
        let picker = WangdianPickerViewController(nibName: "WangdianPickerViewController", bundle: nil)
        picker.hidesBottomBarWhenPushed = true
        picker.delegate = self
        self.navigationController?.pushViewController(picker, animated: true)
    }
}

protocol WangdianPickerViewControllerDelegate:NSObjectProtocol {
    func wangdianPickerViewControllerCancel()
    func wangdianPickerViewControllerSelect(item:SiteInfo)
}

class WangdianPickerViewController: UIViewController {
    weak var delegate:WangdianPickerViewControllerDelegate?
    var tableView:UITableView!
    var searchBar:UISearchBar!
    var wangdian:[SiteInfo] = []
    var allWangdian:[SiteInfo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "网点"
        self.allWangdian = DataManager.shared.sites
        self.searchBar = UISearchBar(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        self.tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.estimatedRowHeight = 30
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let cellNib = UINib(nibName: "WangdianCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "WangdianCell")
        self.tableView.tableHeaderView = self.searchBar
        self.searchBar.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        self.wangdian = self.allWangdian
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }

}

extension WangdianPickerViewController:UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wangdian.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WangdianCell = tableView.dequeueReusableCell(withIdentifier: "WangdianCell") as! WangdianCell
        cell.wangdian = self.wangdian[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.wangdian[indexPath.row]
        self.delegate?.wangdianPickerViewControllerSelect(item: item)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            self.wangdian = self.allWangdian
        }else{
            self.wangdian = self.allWangdian.filter{
                $0.siteName.contains(searchText) || $0.siteCode.contains(searchText)
            }
        }
        self.tableView.reloadData()
    }
}

