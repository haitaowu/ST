//
//  LoginViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/26.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import Typist

protocol LoginViewControllerDelegate:NSObjectProtocol{
	func loginViewControllerLoginSuccess(vc:UIViewController)
}

class LoginViewController: UIViewController {
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var siteField: UITextField!
	let keyboard = Typist.shared
	@IBOutlet weak var loginForm: UIView!
	
	
	
	//MARK:- overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupNavBar()
		self.setupBaseUI()
		self.setupPwdField(field: self.passwordField)
		// Do any additional setup after loading the view.
	}
	
	deinit {
		keyboard.clear()
		print(">>>>>>>>deinit")
	}
	
	//MARK:- setup ui
	private func setupNavBar(){
		self.title = "网点登录"
		self.navigationController?.navigationBar.isHidden = false
	}
	
	private func setupBaseUI(){
		self.view.addDismissGesture()
		self.appendSpaceInTextField(field: self.siteField)
		self.appendSpaceInTextField(field: self.usernameField)
		self.appendSpaceInTextField(field: self.passwordField)

		keyboard.on(event: Typist.KeyboardEvent.willChangeFrame) { [unowned self](option) in
			self.loginForm.snp.remakeConstraints({ (make) in
				make.leading.trailing.equalToSuperview().offset(20)
				make.height.equalTo(220)
				make.centerY.equalToSuperview().offset(-20)
			})
			UIView.animate(withDuration: option.animationDuration, animations: {
				self.view.layoutSubviews()
			})
		}.on(event: Typist.KeyboardEvent.willHide, do: { [unowned self](option) in
			self.loginForm.snp.remakeConstraints({ (make) in
				make.leading.trailing.equalToSuperview().offset(20)
				make.height.equalTo(220)
				make.centerY.equalToSuperview().offset(44)
			})
			UIView.animate(withDuration: option.animationDuration, animations: {
				self.view.layoutSubviews()
			})
		}).start()
		self.usernameField.text = Defaults["username"].stringValue
		self.passwordField.text = Defaults["password"].stringValue
		self.siteField.text = Defaults["sitecode"].stringValue
		self.loginForm.alpha = 1
	}
	
	///设置密码field可见、不可见
	private func setupPwdField(field: UITextField){
		field.rightViewMode = .always
		let rViewWidth = 50
		let frame = CGRect(x: 0, y: 0, width: rViewWidth, height: 40)
		let rView = UIView.init(frame: frame)
		let btn = UIButton.init(frame: frame)
		btn.setImage(UIImage(named: "pwd_close"), for: .normal)
		btn.setImage(UIImage(named: "pwd_open"), for: .selected)
		btn.addTarget(self, action: #selector(LoginViewController.pwdState), for: .touchUpInside)
		btn.frame = frame
		rView.addSubview(btn)
		field.rightView = rView
	}
	
	
	
	//MARK:- selectors
	@objc private func pwdState(sender: UIButton){
		sender.isSelected = !sender.isSelected
		self.passwordField.isSecureTextEntry = !sender.isSelected
	}
	
	
	
	@IBAction func loginBtnClicked(_ sender: AnyObject) {
		//        self.delegate?.loginViewControllerLoginSuccess(vc: self)
		//        #warning("test ")
		//        DataManager.shared.roleType = RoleType.site
		//        NotificationCenter.default.post(name: NotiST.UserLoginSuccSucc, object: nil)
		//        return;
		
		
		
		let userName = self.usernameField.text ?? ""
		let password = self.passwordField.text ?? ""
		let siteCode = self.siteField.text ?? ""
		if siteCode.isEmpty{
			self.remindUser(msg: "请输入站点名称")
			return
		}
		if userName.isEmpty{
			self.remindUser(msg: "请输入员工姓名")
			return
		}
		if password.isEmpty{
			self.remindUser(msg: "请输入登陆密码")
			return
		}
		Defaults["username"] = userName
		Defaults["password"] = password
		Defaults["sitecode"] = siteCode
		Defaults.synchronize()
		let user = User(siteCode:siteCode, empCode: userName, barPassword:password)
		let loginReq = UserLogin(user: user)
		self.showLoading(msg: "登陆中...")
		STNetworking<User>(stRequest: loginReq){
			[unowned self]resp in
			self.hideLoading()
			NSLog("\(resp)")
			if resp.stauts == Status.Success.rawValue{
				DataManager.shared.loginUser = resp.data
				DataManager.shared.roleType = RoleType.site
				NotificationCenter.default.post(name: NotiST.UserLoginSuccSucc, object: nil)
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
	
	
	//MARK:- private
	private func appendSpaceInTextField(field:UITextField){
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
		field.leftView = view
		field.leftViewMode = .always
	}
	
}
