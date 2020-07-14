//
//  DeliverForeCastControl.swift
//  ST
//
//  Created by taotao on 2020/7/5.
//  Copyright © 2020 HTT. All rights reserved.
//

import UIKit
import BRPickerView


class DeliverForeCastControl: BaseController,UITableViewDelegate,UITableViewDataSource{
	@IBOutlet weak var tableView: UITableView!
//	@IBOutlet weak var dateField: UITextField!
	@IBOutlet weak var startDateField: UITextField!
	@IBOutlet weak var endDateField: UITextField!
	@IBOutlet weak var searchBtn: UIButton!
	
	var datePicker: BRDatePickerView?
	var billsAry: Array<[String: Any]>?

	
	enum DeliveryType: String {
		case send = "1",arrive = "2" ,record = "3"
	}
	
	
	var deliType: DeliveryType = .send
	
	//MARK: - overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		self.basicInitTable()
		
//		self.dateField.addRightBtn(imgName: "date",margin: 8,  action: #selector(showDatePicker), target: self)
		if deliType == .arrive{
			self.title = "网点到件预报"
		}else if deliType == .record{
			self.title = "网点录单预报"
		}else{
			self.title = "中心发件预报"
		}
		self.tableView.allowsSelection = false
		self.tableView.register(ForecastCell.cellNib(), forCellReuseIdentifier: ForecastCell.cellID())
	}
	
	
	//MARK: - selectors
	@objc func showDatePicker(by sender: UIButton){
		var selDateField: UITextField?
		if sender.tag == 11 {
			selDateField = self.startDateField
		}else{
			selDateField = self.endDateField
		}
		let today = Date()
		let datePicker = BRDatePickerView(pickerMode: .YMD)
		self.datePicker = datePicker
    
//		let resetBtn = UIButton(frame: CGRect(x: 80, y: 0, width: 40, height: 44))
//		resetBtn.addTarget(self, action: #selector(resetDate), for: .touchUpInside)
//		resetBtn.setTitle("重置", for: .normal)
//		resetBtn.setTitleColor(UIColor.appBlue, for: .normal)
//		resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//		datePicker.addSubView(toTitleBar: resetBtn)
		
		
		datePicker.title = "请选择日期"
		datePicker.pickerStyle = BRPickerStyle(themeColor: UIColor.appBlue)
		datePicker.selectDate = today
		datePicker.maxDate = today
		datePicker.resultBlock = {
			[unowned self] (date, dateStr) in
			selDateField?.text = dateStr
			print("picker date \(dateStr)")
		}
		datePicker.show()
	}
	
	@objc func resetDate(){
//		self.dateField.text = ""
		self.datePicker?.dismiss()
	}
	
	@IBAction func showStartDatePicker(sender: UIButton){
    self.showDatePicker(by: sender)
	}
	
	@IBAction func showEndDatePicker(sender: UIButton){
    self.showDatePicker(by: sender)
	}
	
  @IBAction func toSearch(_ sender: Any) {
    self.tableView.es.startPullToRefresh()
  }
  
	//MARK:-  setupUI
	//init tableView
	private func basicInitTable(){
		self.searchBtn.addBorder(width: 1, color: UIColor.appBlue)
		self.searchBtn.addCorner(radius: 5)
		self.tableView.emptyDataSetSource = self
		self.tableView.emptyDataSetDelegate = self
		self.tableView.es.addPullToRefresh {
			[unowned self] in
			let params = self.reqParams()
			guard let p = params else{return}
			self.fetchBillDetailInfo(params: p)
		}
		self.tableView.es.startPullToRefresh()
	}
	
	//MARK:- table data
	func hasBillsData() -> Bool{
		if self.billsAry?.count ?? 0 > 0 {
			return true
		}else{
			return false
		}
	}
	
	
	//MARK:- UITextFieldDelegate
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		print("textFieldShouldBeginEditing....")
		return false
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
	
	//MARK: - UITableViewDelegate
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	//MARK: - UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.billsAry?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return ForecastCell.cellHeight(data: nil)
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.cellID())
		if let fCell = cell as? ForecastCell,let billInfo = self.billsAry?[indexPath.row]{
			fCell.updateUI(bill: billInfo)
			fCell.printBlock = {
				[unowned self] (billInfo) in
				print("click print clock baby!!!")
				let control = DeliverBillDetailControl.make()
				let detail = control as! DeliverBillDetailControl
				detail.billInfo = billInfo
				self.navigationController?.pushViewController(control, animated: true)
			}
		}
		return cell!
	}
	
  //MARK:- override for DZNEmptyDataSetSource delegate
  override func titleForEmpty(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
    if self.hasBillsData() == false{
      let title = "暂无公告"
		return self.attri(title: title)
    }else{
      return nil
    }
  }
  
  override func titleForEmptyBtn(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
    if self.hasBillsData() == false{
      return self.emptyBtnTitle()
    }else{
      return nil
    }
  }
  
  override func reloadViewData(scrollView: UIScrollView!) {
    self.tableView.es.startPullToRefresh()
  }
	
	
	//MARK:-  request servers
	func reqParams() -> [String: Any]?{
		var params:[String: Any] = [:]
		var startDateTime: String = ""
		var endDateTime: String = ""
    let startStr = self.startDateField.text!
    let endStr = self.endDateField.text!
    if ((startStr.isEmpty == false) && (endStr.isEmpty == false)){
			startDateTime = startStr + "00:00:00"
			endDateTime = endStr + " 23:59:59"
		}else{
		//			startDateTime  =  "2020-07-01 00:00:00"
			let todayStr = Date().dateStringFrom()
			startDateTime  = todayStr + " 00:00:00"
			endDateTime = todayStr + " 23:59:59"
		}
		params["startTime"] = startDateTime
		params["endTime"] = endDateTime
		params["findType"] = self.deliType.rawValue
		params["siteName"] = DataManager.shared.loginUser.siteName
		return params;
	}
	
	//pai jian
	func fetchBillDetailInfo(params: [String: Any]){
		let reqUrl = Consts.Server + Consts.BaseUrl + "m8/dispPredictionBill.do"
		STHelper.POST(url: reqUrl, params: params) {
			[unowned self](result, data) in
			self.tableView.es.stopPullToRefresh()
			if (result == .reqSucc) {
				if let bills = data as? Array<[String: Any]>{
					self.billsAry = bills
				}else{
					self.billsAry = []
				}
			}else{
				self.billsAry = []
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
			self.tableView.reloadData()
		}
	}
	
	
	
}
