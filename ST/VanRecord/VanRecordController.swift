//
//  VanRecordController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ESPullToRefresh



class VanRecordController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
	
	@IBOutlet weak var searchField: UITextField!
	
//	发车或到车标示 1为发车 2 为到车
	@IBOutlet var timeTypesBtn: [UIButton]!
	
	@IBOutlet weak var startDate: UITextField!
	
	@IBOutlet weak var endDate: UITextField!
	
	@IBOutlet weak var filterView: UIView!
	
	@IBOutlet weak var tableView: UITableView!
	

	@IBOutlet weak var containerView: UIView!
	
	@IBOutlet weak var titlesLabelContainer: UIView!
	@IBOutlet var titlesAry: [UILabel]!

	
	var recsAry:Array<SARecModel>?
//	var searchRecsAry:Array<SARecModel>?
	
	//MARK:- Overrides
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
		self.setupTabBarItems();
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		self.setupTabBarItems();
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.basicSetupUI()
		self.setupTable()
		
	}
	
	//MARK:- setup ui
	func basicSetupUI() -> Void {
		self.title = "记录"
		self.navigationController?.navigationBar.isTranslucent = false
		self.searchField.layer.cornerRadius = 15
		self.searchField.layer.borderColor = UIColor.gray.cgColor
		self.searchField.layer.borderWidth = 1
		self.searchField.layer.masksToBounds = true
		self.searchField.addLeftSpaceView(width: 8)
		self.searchField.addRightView(imgName: "search",width: 40,height: 40)
		self.searchField.returnKeyType = .search
		self.searchField.delegate = self
		
		let screenSize = UIScreen.main.bounds.size
		let titleSpace:CGFloat = 16
		let titlesWith = screenSize.width - CGFloat(self.titlesAry.count + 1) * titleSpace
		let titleLabelW = titlesWith / CGFloat(self.titlesAry.count)
		let titleLabelH = self.titlesLabelContainer.vHeight()
		for (idx,label) in self.titlesAry.enumerated(){
			let x = titleSpace + CGFloat(idx) * (titleLabelW + titleSpace)
			let frame = CGRect(x: x, y: 0, width: titleLabelW, height: titleLabelH)
			label.frame = frame
		}
	}
	
	//setup tableView
	func setupTable() -> Void {
		let nibNotiCell = VanRecCell.cellNib()
		self.tableView.register(nibNotiCell, forCellReuseIdentifier: VanRecCell.cellID())
		let animator = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
		self.tableView.es.addPullToRefresh(animator: animator) {
			[unowned self] in
			let result = self.paramsRec()
			let request:STRequest? = result.req
      let params = result.params
			guard let req = request else{return}
			self.fetchVanRecDatas(params: params, req: req)
		}
		self.tableView.es.startPullToRefresh()
		
	}

	
	
	
	//MARK:- setup tabbaritem
	func setupTabBarItems() -> Void {
		self.tabBarItem = UITabBarItem(title: "记录", image:UIImage(named:"more_disselect") , selectedImage: UIImage(named:"more_select"));
	}
	
	
  //MARK:- SELECTORS
	//点击开始查询
	@IBAction func clickToQuery(_ sender: UIButton) {
		self.view.endEditing(true)
		let control = VanRecordResController()
		control.hidesBottomBarWhenPushed = true
		control.paramsQuery = self.paramsRec()
		self.navigationController?.pushViewController(control, animated: true)
	}
	
	
  @IBAction func clickTimeTypeBtn(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    for typeBtn in self.timeTypesBtn {
      if typeBtn.tag != sender.tag{
        typeBtn.isSelected = !sender.isSelected
        break
      }
    }
  }
  
  //更多
  @IBAction func clickMoreFilterBtn(_ sender: UIButton) {
    self.view.endEditing(true)
    sender.isSelected = !sender.isSelected
    let distance = self.filterView.vHeight()
    var containerY:CGFloat
    var containerH:CGFloat
    if sender.isSelected{
      containerY  = self.containerView.y() + distance
			containerH = self.view.vHeight() - 190
    }else{
      containerY  = self.containerView.y() - distance
			containerH = self.view.vHeight() - 50
    }
    let x = self.containerView.x()
    let width = self.containerView.vWidth()
    let frame = CGRect(x: x, y: containerY, width: width, height: containerH)
    UIView.animate(withDuration: 0.3) {
      self.containerView.frame = frame
    }
  }
  
  
	
	///重置查询条件
	@IBAction func clickResetFilter(_ sender: UIButton) {
		for typeBtn in self.timeTypesBtn {
			typeBtn.isSelected = false
    }
		self.searchField.text = ""
		self.startDate.text = ""
		self.endDate.text = ""
	}
	
	
	//选择起始时间
	@IBAction func clickStartTimeBtn(_ sender: Any) {
		ActionSheetDatePicker.show(withTitle: "起始时间", datePickerMode: .dateAndTime, selectedDate: Date.init(), doneBlock: {[unowned self] (picker, selectedDate, values) in
			if let date = selectedDate as? Date{
				let dateStr = date.dateStringFrom(dateFormat: "yyyy-MM-dd")
				self.startDate.text = dateStr;
			}
			}, cancel: { (picker) in
				
		}, origin: self.view);
		print("start ");
	}
	
	
	//选择结束时间
	@IBAction func clickEndTimeBtn(_ sender: Any) {
		ActionSheetDatePicker.show(withTitle: "结束时间", datePickerMode: .dateAndTime, selectedDate: Date.init(), doneBlock: { [unowned self] (picker, selectedDate, values) in
			if let date = selectedDate as? Date{
				let dateStr = date.dateStringFrom(dateFormat: "yyyy-MM-dd")
				self.endDate.text = dateStr;
			}
			}, cancel: { (picker) in
				
		}, origin: self.view);
	}
	
	
	
	//MARK:- UITextFieldDelegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return true;
	}
	
	
	//MARK:- tableView datasource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.recsAry?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:VanRecCell? = tableView.dequeueReusableCell(withIdentifier: VanRecCell.cellID()) as? VanRecCell
		if let model = self.recsAry?[indexPath.row]{
			cell?.updateCellUI(model: model)
		}
		return cell!
	}
	
	//MARK:- tableView delegate
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40;
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let storyboard = UIStoryboard.init(name: "BaseUI", bundle: nil)
		let control = storyboard.instantiateViewController(withIdentifier: "VanRecordDetailControl")
		control.hidesBottomBarWhenPushed = true
		if let model = self.recsAry?[indexPath.row] , let recControl = control as? VanRecordDetailControl{
			recControl.vanRecModel = model
		}
		self.navigationController?.pushViewController(control, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	
	
	//MARK:- params helper
  private func paramsRec() -> (params:[String: String], req:STRequest?){
		var params:[String:String] = [:]
		
		let manager = DataManager.shared
    var request:STRequest?
		if ((manager.roleType == .center) || (manager.roleType == .site)) {
			let accStr = manager.loginUser.siteName
			params["scanSite"] = accStr
      request = EmpSARecReq(params: params)
		}else{
			let truckNum = manager.loginDriver.truckNum
			params["truckNum"] = truckNum
      request = DriSARecReq(params: params)
		}

		let searchTxt = self.searchField.text
		if let txt = searchTxt,txt.isEmpty==false{
			params["findData"] = txt
		}
		
		if let starTime = self.startDate.text,starTime.isEmpty==false{
			params["starTime"] = starTime
		}
		
		if let endTime = self.endDate.text,endTime.isEmpty==false{
			params["endTime"] = endTime
		}
		var typeBtn:UIButton?
		for item in self.timeTypesBtn{
			if item.isSelected{
				typeBtn = item
				break
			}
		}
		
		if let btn = typeBtn{
				params["starOrEnd"] = String(btn.tag)
			}
		return (params,request)
	}
	
	
	//MARK:- request server
	///列表数据的请求
	func fetchVanRecDatas(params: [String: String], req: STRequest) -> Void {
		STNetworking<[SARecModel]>(stRequest:req) {
			[unowned self] resp in
			self.tableView.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.recsAry = resp.data
				self.tableView.reloadData()
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}

	
}


