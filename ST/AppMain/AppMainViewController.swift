//
//  AppMainViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/27.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import Dispatch
class AppMainViewController: ContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var home:UIViewController
        var message:UIViewController
        var v3:UIViewController
        var user:UIViewController
        
        if DataManager.shared.roleType == RoleType.site{
            home = HomeViewController(nibName: "HomeViewController", bundle: nil)
            message = MessageViewController(nibName: "MessageViewController", bundle: nil)
            v3 = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
            user = SettingViewController(nibName: "SettingViewController", bundle: nil)
        }else if DataManager.shared.roleType == RoleType.driver{
            home = DriHomeController(nibName: "DriHomeController", bundle: nil)
            message = CenAnnouceController(nibName: "CenAnnouceController", bundle: nil)
            v3 = VanRecordController(nibName: "VanRecordController", bundle: nil)
            user = DriverPersonController.DriverUserControl()
        }else{
            home = CenHomeController(nibName: "CenHomeController", bundle: nil)
            message = CenAnnouceController(nibName: "CenAnnouceController", bundle: nil)
            v3 = VanRecordController(nibName: "VanRecordController", bundle: nil)
            user = CentPersonController.CenterUserControl()
        }
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [
            UINavigationController(rootViewController: home),
            UINavigationController(rootViewController: message),
            UINavigationController(rootViewController: v3),
            UINavigationController(rootViewController: user)
        ]
        self.content = tabBar
    }
    
    
}
