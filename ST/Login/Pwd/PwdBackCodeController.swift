//
//  PwdBackCodeController.swift
//  ST
//
//  Created by taotao on 2019/9/10.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit


class PwdBackCodeController: UIViewController{
	//MARK:- properites
	@IBOutlet weak var nextBtn: UIButton!
	@IBOutlet weak var codeBtn: UIButton!
	@IBOutlet weak var phoneField: UITextField!
	@IBOutlet weak var codeField: UITextField!
	var roleType:RoleType = RoleType.center
	var countTimer:Timer?
	let countTimes:Int = 6
	var countNum:Int = 0;
	
	//MARK:- override
	override func viewDidLoad() {
		super.viewDidLoad()
		countNum = countTimes
		self.setupUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	//MARK:- setup ui
	func setupUI() -> Void {
		self.title = "密码修改"
		self.navigationController?.navigationBar.isTranslucent = false
		self.nextBtn.addCorner(radius: 5)
		self.codeBtn.addCorner(radius: 5)
		self.view.addDismissGesture()
		self.phoneField.addLeftSpaceView(width: 8)
		self.codeField.addLeftSpaceView(width: 8)
		self.phoneField.addBorder(width: 0.8, color: UIColor.gray)
		self.codeField.addBorder(width: 0.8, color: UIColor.gray)
		
	}
	
	//MARK:- selectors
	//下一步
	@IBAction func clickNextBtn(_ sender: UIButton) {
		var params:[String: String] = [:]
		let phone = self.phoneField.text ?? ""
		if phone.isEmpty{
			self.remindUser(msg: "请输入手机号")
			return;
		}else{
			params["phone"] = phone
		}
		
		let code = self.codeField.text ?? ""
		if code.isEmpty {
			self.remindUser(msg: "请输入验证码")
			return;
		}else{
			params["authCode"] = code
		}
		
		self.showResetPwdView(params:params)
		
	}
	
	//获取验证码
	@IBAction func clickCodeBtn(_ sender: UIButton) {
		var params:[String: String] = [:]
		let phone = self.phoneField.text ?? ""
		if phone.isEmpty {
			self.remindUser(msg: "请输入手机号")
			return;
		}else{
			params["phone"] = phone
		}
		
		if phone.isPhoneNum() == false{
			self.remindUser(msg: "请输入正确的手机号")
			return;
		}
		self.countTime()
		self.reqAuthCodeBy(phone: phone)
	}
	
	//倒计时
	@objc func beginCounting() -> Void {
		countNum = countNum - 1
		let title = "\(countNum)" + "S"
		self.codeBtn.setTitle(title, for: .normal)
		if countNum == 0 {
			countNum = countTimes
			self.countTimer?.invalidate()
			self.codeBtn.isEnabled = true
			self.codeBtn.backgroundColor = UIColor.red
			self.codeBtn.setTitle("获取验证码", for: .normal)
		}
		
	}
	
	//MARK:- private
	//输入密码界面
	func showResetPwdView(params:[String: String]) -> Void {
		let control = PwdBackResetController(nibName: "PwdBackResetController", bundle: nil)
		control.roleType = self.roleType
		control.params = params
		self.navigationController?.pushViewController(control, animated: true)
	}
	
	//计时器
	func countTime() -> Void {
		self.codeBtn.isEnabled = false
		self.codeBtn.backgroundColor = UIColor.gray
		self.countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(beginCounting), userInfo: nil, repeats: true)
		self.countTimer?.fire()
	}
	
	//MARK:- request server
	func reqAuthCodeBy(phone:String) -> Void {
		let req = AuthCodeReq(phone: phone, roleType: self.roleType)
		STNetworking<RespMsg>(stRequest:req) {
			[unowned self] resp in
			if resp.stauts == Status.Success.rawValue{
				self.remindUser(msg: "发送成功")
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
