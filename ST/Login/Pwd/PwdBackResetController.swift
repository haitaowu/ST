//
//  PwdBackResetController.swift
//  ST
//
//  Created by taotao on 2019/9/10.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//


import UIKit



class PwdBackResetController: UIViewController{
    //MARK:- properites
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var pwdAgainField: UITextField!

    
	var params:[String: String] = [:]
    var roleType:RoleType = RoleType.center
    

    //MARK:- override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK:- setup ui
    func setupUI() -> Void {
        self.title = "密码修改"
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.addDismissGesture()
        self.sureBtn.addCorner(radius: 5)
        self.pwdField.addLeftSpaceView(width: 8)
        self.pwdAgainField.addLeftSpaceView(width: 8)
        self.pwdField.addBorder(width: 0.8, color: UIColor.gray)
        self.pwdAgainField.addBorder(width: 0.8, color: UIColor.gray)
    }
    
    //MARK:- selectors
    //确认
    @IBAction func clickSureBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let pwd = self.pwdField.text ?? ""
        if pwd.isEmpty {
            self.remindUser(msg: "请输入新密码")
            return;
        }else{
            params["passWord"] = pwd
        }
        
        let pwdAgain = self.pwdAgainField.text ?? ""
        if pwdAgain.isEmpty {
            self.remindUser(msg: "请再次输入新密码")
            return;
        }
        
        if pwdAgain != pwd {
            self.remindUser(msg: "两次输入新密码不一致")
            return;
        }
        
//        self.showResetPwdSuccView()
//        return
        
        self.reqResetPwd(params: params)
    }
    
    
    //MARK:- private
    func selectSiteRole() -> Void {
        let control = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    
    //显示找回密码成功p界面
    func showResetPwdSuccView() -> Void{
        let succControl = PwdResetSuccController()
        succControl.roleType = self.roleType
        self.navigationController?.pushViewController(succControl, animated: true)
    }
    
    
    //MARK:- request server
	func reqResetPwd(params:[String: String]) -> Void {
		let req = ResetPwdReq(params:params , roleType: self.roleType)
		STNetworking<RespMsg>(stRequest:req) {
			[unowned self] resp in
			if resp.stauts == Status.Success.rawValue{
				self.showResetPwdSuccView()
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				var msg = resp.msg
				if resp.stauts == Status.PasswordWrong.rawValue{
					msg = "密码错误"
				}
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
    
	
}
