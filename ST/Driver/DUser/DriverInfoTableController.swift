//
//  DriverInfoTableController.swift
//  ST
//
//  Created by taotao on 2019/7/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class DriverInfoTableController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pwdField: UITextField!
//    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var ownerField: UITextField!
    @IBOutlet weak var carNumField: UITextField!
    @IBOutlet weak var carShapeField: UITextField!
    
    //MARK:- Overrides
    override func viewDidLoad() {
        super.viewDidLoad();
		self.setupUI()
    }
	
	//MARK:- setup ui
	private func setupUI(){
		self.title = "基础资料修改";
//		let typeImg = UIImage(named: "arrow");
//		let rightViewF = CGRect(x: 0, y: 0, width: 44, height: 44)
//		let ownerRigthVeiw = UIButton.init(frame: rightViewF)
//		ownerRigthVeiw.setImage(typeImg, for: .normal)
//		ownerRigthVeiw.addTarget(self, action: #selector(DriverInfoTableController.clickOwnerBtn), for: .touchUpInside)
//		self.ownerField.rightView = ownerRigthVeiw
//		self.ownerField.rightViewMode = .always
		self.view.addDismissGesture()
		
		let driver = DataManager.shared.loginDriver
		self.nameLabel.text = driver.truckOwer
		self.carNumField.text = driver.truckNum
//		self.phoneField.text = driver.phone
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
    
    func tapEndViewEdit() -> Void {
        self.view.endEditing(true)
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
		var params:[String:String] = [:]
		
		let driver = DataManager.shared.loginDriver
		if let newPassword = self.pwdField.text,newPassword.isEmpty==false{
			params["newPassword"] = newPassword
		}else{
			self.remindUser(msg: "请输入密码")
			return nil
		}

		params["truckNum"] = driver.truckNum
		let pwd = Defaults[Consts.DriverPwdKey].stringValue
		params["oldPassWord"] = pwd
		return params
	}
	
    
    
	//MARK:- request server
	///修改基础资料的请求
	func reqModifyInfoWith(params: [String: String]) -> Void {
		let req = DriInfoModReq(params: params)
		STNetworking<RespMsg>(stRequest:req) {
			[unowned self] resp in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}

	
    
    
}


