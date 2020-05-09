//
//  DriverInfoTableController.swift
//  ST
//
//  Created by taotao on 2019/7/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation




class DriverInfoTableController: UITableViewController {
    
  @IBOutlet weak var phoneField: UITextField!
  @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var pwdAgainField: UITextField!
    @IBOutlet weak var ownerField: UITextField!
    @IBOutlet weak var carNumField: UITextField!
    @IBOutlet weak var carShapeField: UITextField!
  @IBOutlet weak var codeBtn: UIButton!
  @IBOutlet weak var codeField: UITextField!
  
  var countTimer:Timer?
  let countTimes:Int = 6
  var countNum:Int = 0;
    
    //MARK:- Overrides
    override func viewDidLoad() {
        super.viewDidLoad();
      countNum = countTimes
		self.setupUI()
    }
	
	//MARK:- setup ui
	private func setupUI(){
		self.title = "基础资料修改";
		self.view.addDismissGesture()
		
		let driver = DataManager.shared.loginDriver
		self.nameLabel.text = driver.truckOwer
		self.carNumField.text = driver.truckNum
		self.phoneField.text = driver.phone
		self.ownerField.text = driver.truckOwer
	}
	
    
    //MARK:- selectors
    //保存
	@IBAction func clickSaveBtn(_ sender: Any) {
		print("clickOwnerBtn")
		self.view.endEditing(true)
		if let params = self.paramsInfo(){
			self.showLoading(msg: "修改基础资料")
			self.reqModifyInfoWith(params: params)
		}
	}
	
    
    //选择车主
    @objc func clickOwnerBtn() -> Void {
        print("clickOwnerBtn")
    }
  
  
  //获取验证码
  @IBAction func clickCodeBtn(_ sender: UIButton) {
    let phone = self.phoneField.text ?? ""
    if phone.isEmpty {
      self.remindUser(msg: "请输入手机号")
      return;
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
    
    func tapEndViewEdit() -> Void {
        self.view.endEditing(true)
    }
    
  
    //MARK:- private
  //计时器
  func countTime() -> Void {
    self.codeBtn.isEnabled = false
    self.codeBtn.backgroundColor = UIColor.gray
    self.countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(beginCounting), userInfo: nil, repeats: true)
    self.countTimer?.fire()
  
  }
    //MARK:- tableview delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
	
	//MARK:- params helper
  private func paramsInfo() -> [String: String]?{
    var params:[String: String] = [:]
    let phone = self.phoneField.text ?? ""
    if phone.isEmpty{
      self.remindUser(msg: "请输入手机号")
      return nil;
    }else{
      params["phone"] = phone
    }
    
    let passWord = self.pwdField.text ?? ""
    if passWord.isEmpty{
      self.remindUser(msg: "请输入密码")
      return nil;
    }
    
    let pwdAgain = self.pwdAgainField.text ?? ""
    if pwdAgain.isEmpty{
      self.remindUser(msg: "请输再次入密码")
      return nil;
    }
    
    if pwdAgain != passWord{
      self.remindUser(msg: "两次入密码不一致")
      return nil;
    }
    
    params["passWord"] = passWord
    let code = self.codeField.text ?? ""
    if code.isEmpty {
      self.remindUser(msg: "请输入验证码")
      return nil;
    }else{
      params["authCode"] = code
    }
		return params
	}
  
	
    
    
	//MARK:- request server
	///修改基础资料的请求
  func reqModifyInfoWith(params: [String: String]) -> Void {
    let req = ResetPwdReq(params:params , roleType: RoleType.driver)
    STNetworking<RespMsg>(stRequest:req) {
      [unowned self] resp in
      self.hideLoading()
      if resp.stauts == Status.Success.rawValue{
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
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

  ///请求验证码
  func reqAuthCodeBy(phone:String) -> Void {
    let req = AuthCodeReq(phone: phone, roleType: RoleType.driver)
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


