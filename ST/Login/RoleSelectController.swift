//
//  RoleSelectController.swift
//  ST
//
//  Created by taotao on 2019/9/10.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit

enum RoleType :String{
    case site = "0", center = "1", driver = "2",none="none"
}


class RoleSelectController: ContainerViewController,LoginViewControllerDelegate {
    
    //MARK:- properites
    @IBOutlet var btns: [UIButton]!
    

    //MARK:- override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:- setup ui
    func setupUI() -> Void {
        for btn in btns {
            btn.addCorner(radius: 5)
        }
    }
    
    //MARK:- selectors
    @IBAction func clickRoleBtn(_ sender: UIButton) {
        let roleType = sender.tag
        if roleType == Int(RoleType.site.rawValue){
            //网点
            self.selectSiteRole()
        }else if roleType == Int(RoleType.center.rawValue) {
           //中心
            self.selectCenterRole()
        }else{
            //司机
            self.selectDriveRole()
        }
    }

    //MARK:- private
    //网点
    func selectSiteRole() -> Void {
        let control = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        control.delegate = self
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    //中心
    func selectCenterRole() -> Void {
        let control = CenterLoginController(nibName: "CenterLoginController", bundle: nil)
//        control.delegate = self
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    //司机
    func selectDriveRole() -> Void {
        let control = DriverLoginController(nibName: "DriverLoginController", bundle: nil)
//        control.delegate = self
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    //MARK:- LoginViewControllerDelegate
    func loginViewControllerLoginSuccess(vc: UIViewController) {
        self.navigationController?.popViewController(animated: false)
        self.content = AppMainViewController()
    }
    
    
    
}
