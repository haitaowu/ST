//
//  ProfileViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/26.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gridContainerView: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var gridView: GridView!
    var items:[ProfileLineInfo] = []
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupTabbarItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupTabbarItem()
    }
    
    private func setupTabbarItem(){
        self.tabBarItem = UITabBarItem(title: "个人资料", image:UIImage(named:"individual_disselect") , selectedImage: UIImage(named:"individual_select"))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "个人资料"
        self.view.backgroundColor = UIColor.appBgColor
        self.topContainer.borderColor = UIColor.appLineColor
        self.topContainer.bottomBorderWidth = 0.5
        self.gridContainerView.cornerRadius = 6
        self.gridContainerView.borderColor = UIColor.appLineColor
        self.gridContainerView.borderWidth = 0.5
        self.gridView.numOfColsPerRow = 1
        self.gridView.preferRowHeight = 30
        self.reloadData()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadMoney()
    }
    func loadMoney(){
        let req = AccountMoneySearchRequest(siteName: DataManager.shared.loginUser.siteName)
        self.showLoading(msg: "")
        STNetworking<AccountMoney>(stRequest: req){
            [unowned self]resp in
            self.hideLoading()
            var userInfo = DataManager.shared.loginUser
            userInfo.confirmMoney = resp.data.ConfirmMoney
            DataManager.shared.loginUser = userInfo
            self.reloadData()
        }?.resume()
    }
    func reloadData(){
        let userInfo = DataManager.shared.loginUser
        self.items = [
            (title:"姓名",value:userInfo.empName),
            (title:"手机",value:userInfo.phone),
            (title:"编号",value:userInfo.empCode),
            (title:"所属网点",value:userInfo.siteName),
            (title:"部门",value:userInfo.deptName),
            (title:"地址",value:userInfo.address),
            (title:"余额",value:"\(userInfo.confirmMoney)"),
            (title:"注册时间",value:userInfo.createDate)
        ]
        self.gridView.setupWith(infos: self.items)
        self.nameLabel.text = userInfo.empName
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
