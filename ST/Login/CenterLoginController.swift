//
//  CenterLoginController.swift
//  ST
//
//  Created by taotao on 2019/9/10.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire
import Typist


class CenterLoginController: UIViewController {
	@IBOutlet weak var enterForm: UIView!
	@IBOutlet weak var siteNameField: UITextField!
	@IBOutlet weak var accField: UITextField!
	@IBOutlet weak var pwdField: UITextField!
	@IBOutlet weak var remberBtn: UIButton!
	
	
	let siteNameKey:String = "siteNameKey"
	let accCenterKey:String = "accCenterKey"
	
	let keyboard = Typist.shared
	
	//MARK:- override
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
	}
	
	deinit {
		keyboard.clear()
		print(">>>>>>>>deinit")
	}
	
	//MARK:- init UI
	func setupUI() -> Void {
		self.title = "中心登录"
		self.navigationController?.navigationBar.isHidden = false
		self.view.addDismissGesture()
		self.siteNameField.addLeftSpaceView(width: 16)
		self.accField.addLeftSpaceView(width: 16)
		self.pwdField.addLeftSpaceView(width: 16)
		self.setupPwdField(field: self.pwdField)
		
		NotificationCenter.default.addObserver(self, selector: #selector(resetPwdSucc), name: NotiST.UserResetPwdSucc, object: nil)
		
		let siteName = Defaults[siteNameKey].stringValue
		if siteName.isEmpty == false{
			self.siteNameField.text = siteName
		}
		
		let acc = Defaults[accCenterKey].stringValue
		if acc.isEmpty == false{
			self.accField.text = acc
		}
		
		let pwd = Defaults[Consts.pwdCenterKey].stringValue
		if pwd.isEmpty == false{
			self.pwdField.text = pwd
		}
		
		keyboard.on(event: Typist.KeyboardEvent.willChangeFrame) { [unowned self](option) in
			self.enterForm.snp.remakeConstraints({ (make) in
				make.leading.trailing.equalToSuperview().offset(16)
				make.height.equalTo(220)
				make.centerY.equalToSuperview().offset(-20)
			})
			
			UIView.animate(withDuration: option.animationDuration, animations: {
				self.view.layoutSubviews()
			})
			
		}.on(event: Typist.KeyboardEvent.willHide, do: { [unowned self](option) in
			self.enterForm.snp.remakeConstraints({ (make) in
				make.leading.trailing.equalToSuperview().offset(16)
				make.height.equalTo(220)
				make.centerY.equalToSuperview().offset(0)
			})
			UIView.animate(withDuration: option.animationDuration, animations: {
				self.view.layoutSubviews()
			})
		}).start()
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
		btn.addTarget(self, action: #selector(CenterLoginController.pwdState), for: .touchUpInside)
		btn.frame = frame
		rView.addSubview(btn)
		field.rightView = rView
	}
	
	//MARK:- selectors
	@IBAction func clickLoginBtn(_ sender: Any) {
		self.view.endEditing(true)
		
//		#warning ("test")
//		NotificationCenter.default.post(name: NotiST.UserLoginSuccSucc, object: nil)
//		return
		

		
		
		
		var params:Parameters = [:]
		let siteName = self.siteNameField.text ?? ""
		if siteName.isEmpty {
			self.remindUser(msg: "请输入网点")
			return;
		}else{
			params["siteName"] = siteName
		}
		
		let acc = self.accField.text ?? ""
		if acc.isEmpty {
			self.remindUser(msg: "请输入账号")
			return;
		}else{
			params["employeeCode"] = acc
		}
		
		let pwd = self.pwdField.text ?? ""
		if pwd.isEmpty {
			self.remindUser(msg: "请输入密码")
			return;
		}else{
			params["passWord"] = pwd
		}
		
		self.saveUserAcc(siteName: siteName, acc: acc, pwd: pwd)
		let model = CenterModel(siteName: siteName, acc: acc, pwd: pwd)
		self.reqLogin(model: model)
	}
	
	//记住密码
	@IBAction func clickRemberBtn(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
	}
	
	//忘记密码
	@IBAction func clickForgotPwdBtn(_ sender: Any) {
		let pwdControl = PwdBackCodeController()
		pwdControl.roleType = RoleType.center
		self.navigationController?.pushViewController(pwdControl, animated: true)
	}
	
	
	
	//MARK:- selectors notification
	@objc func resetPwdSucc(){
		self.navigationController?.popToViewController(self, animated: true)
	}
	
	@objc private func pwdState(sender: UIButton){
		sender.isSelected = !sender.isSelected
		self.pwdField.isSecureTextEntry = !sender.isSelected
	}
	
	
	
	//MARK:- private
	func saveUserAcc(siteName:String,acc:String,pwd:String) -> Void {
		if self.remberBtn.isSelected {
			Defaults[siteNameKey] = siteName
			Defaults[accCenterKey] = acc
			Defaults[Consts.pwdCenterKey] = pwd
		}else{
			Defaults[siteNameKey] = ""
			Defaults[accCenterKey] = ""
			Defaults[Consts.pwdCenterKey] = ""
		}
		Defaults.synchronize()
	}
	
	//MARK:- request server
	func reqLogin(model:CenterModel) -> Void {
		let req = CenterLoginReq(user: model)
		
		self.remindUser(msg: "登录中...")
		STNetworking<User>(stRequest:req) {
			[unowned self] resp in
			if resp.stauts == Status.Success.rawValue{
				self.remindUser(msg: "登录成功")
				DataManager.shared.loginUser = resp.data
				DataManager.shared.roleType = RoleType.center
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
	
}
