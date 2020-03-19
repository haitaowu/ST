//
//  PwdResetSuccController.swift
//  ST
//
//  Created by taotao on 2019/9/10.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//


import UIKit


class PwdResetSuccController: UIViewController{
    //MARK:- properites
    @IBOutlet weak var backBtn: UIButton!
    
    var roleType:RoleType = RoleType.center


    //MARK:- override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK:- setup ui
    func setupUI() -> Void {
        self.title = "密码修改成功"
        self.navigationController?.navigationBar.isTranslucent = false
        self.backBtn.addCorner(radius: 5)
    }
    
    private func setupNavBar(){
        let leftItem = UIBarButtonItem(customView: UIView())
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    //MARK:- selectors
    //确认
    @IBAction func clickBackBtn(_ sender: UIButton) {
        self.backToLoginView()
    }
    
    //MARK:- private
    func backToLoginView() -> Void {
        if self.roleType == RoleType.driver{
            NotificationCenter.default.post(name: NotiST.DriverResetPwdSucc, object: nil)
        }else{
            NotificationCenter.default.post(name: NotiST.UserResetPwdSucc, object: nil)
        }
    }
    
    
    
    
}
