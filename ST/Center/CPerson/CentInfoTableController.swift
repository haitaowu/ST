//
//  CentInfoTableController.swift
//  ST
//
//  Created by taotao on 2019/7/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class CentInfoTableController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pwdField: UITextField!
//    @IBOutlet weak var phoneField: UITextField!
    //所属中心
    @IBOutlet weak var ownerField: UITextField!

    //MARK:- Overrides
    override func viewDidLoad() {
        super.viewDidLoad();
        self.setupNavBar()
        self.setupViewUI()
    }
    
    //MARK:- setup ui
    private func setupNavBar()
    {
        self.title = "基础资料修改";
    }

    
    private func setupViewUI()
    {
        self.pwdField.addLeftSpaceView(width: 8)
        self.ownerField.addLeftSpaceView(width: 8)
        let centerStr = DataManager.shared.loginUser.deptName
        self.ownerField.text = centerStr
        let name = DataManager.shared.loginUser.empName
        self.nameLabel.text = name
        //所属中心是哪个字段
        self.view.addDismissGesture()
    }
    
    //MARK:- selectors
    //保存
    @IBAction func clickSaveBtn(_ sender: Any) {
        print("clickOwnerBtn")
			self.view.endEditing(true)
			if let params = self.paramsInfo(){
				self.showLoading(msg: "修改基础资料")
				self.reqModifyUserInfoWith(params: params)
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
		
		let user = DataManager.shared.loginUser
		if let newPassword = self.pwdField.text,newPassword.isEmpty==false{
			params["newPassword"] = newPassword
		}else{
			self.remindUser(msg: "请输入密码")
			return nil
		}

		params["employeeCode"] = user.empCode
		let manager = DataManager.shared
		if (manager.roleType == .center){
			let pwd = Defaults[Consts.pwdCenterKey].stringValue
			params["oldPassWord"] = pwd
		}else{
			let pwd = Defaults["password"].stringValue
			params["oldPassWord"] = pwd
		}
		return params
	}
	
    
    
	//MARK:- request server
	///修改基础资料的请求
	func reqModifyUserInfoWith(params: [String: String]) -> Void {
		let req = UserInfoModReq(params: params)
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


