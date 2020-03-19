//
//  ViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/24.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit



class ViewController: ContainerViewController,LoginViewControllerDelegate {
//    lazy var loginVc:LoginViewController = {
//        let login = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        login.delegate = self
//        return login
//    }()
		
    lazy var roleNav:UINavigationController = {
        let control = RoleSelectController(nibName: "RoleSelectController", bundle: nil)
        let nav = UINavigationController(rootViewController: control)
        nav.navigationBar.isHidden = true;
        return nav
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.content = loginVc
		if DataManager.shared.hasLogined(){
			self.content = AppMainViewController()
		}else{
			self.content = roleNav
		}
        //登出成功通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "logout"), object: nil, queue: OperationQueue.main){[unowned self]
            noti  in
            let address = String(format:">>>>>>>>>>>>>>>>>%p", self)
			DataManager.shared.roleType = nil
			
            print(address)
            self.content = self.roleNav
        }
        
        //登录成功通知
        NotificationCenter.default.addObserver(forName: NotiST.UserLoginSuccSucc, object: nil, queue: OperationQueue.main){[unowned self]
            noti  in
            self.roleNav.popToRootViewController(animated: false)
            self.content = AppMainViewController()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loginViewControllerLoginSuccess(vc: UIViewController) {
        self.content = AppMainViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

