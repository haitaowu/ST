//
//  DriDamgeQueryController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ESPullToRefresh



class DriDamgeQueryController: UIViewController,UITableViewDelegate,UITableViewDataSource{
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var searchField: UITextField!
  @IBOutlet weak var stateField: UITextField!
  @IBOutlet weak var startDate: UITextField!
  @IBOutlet weak var endDate: UITextField!
  
  @IBOutlet weak var filterView: UIView!
  @IBOutlet weak var containerView: UIView!
	@IBOutlet weak var titlesLabelContainer: UIView!
	@IBOutlet var titlesAry: [UILabel]!
  
  ///状态
  var stateStr:String?
  
  
  var dataAry:Array<DamRecModel>?
  
  
  static func DamgeQueryControl()-> UIViewController{
    let control = DriDamgeQueryController(nibName: "DriDamgeQueryController", bundle: nil)
    control.hidesBottomBarWhenPushed = true;
    return control
  }
  
  //MARK:- Overrides
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupBaseUI()
    self.setupNavBar()
    self.setupTable()
  }
  
  //MARK:- setup  navitaionbar tableview
  private func setupBaseUI(){
    self.searchField.layer.cornerRadius = 15
    self.searchField.layer.borderColor = UIColor.gray.cgColor
    self.searchField.layer.borderWidth = 1
    self.searchField.layer.masksToBounds = true
    self.searchField.addLeftSpaceView(width: 8)
		self.searchField.addRightView(imgName: "search",width: 30,height: 30)
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
  
  private func setupNavBar(){
    self.title = "车损报备查询";
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  private func setupTable() -> Void {
    let nibNotiCell = DriHeavQueryCell.cellNib();
    self.tableView.register(nibNotiCell, forCellReuseIdentifier: DriHeavQueryCell.cellID())
    self.tableView.es.addPullToRefresh {
      [unowned self] in
      if let params = self.paramsQuery(){
        self.fetchDamageDatas(params:params)
      }
    }
    self.tableView.es.startPullToRefresh()
  }
  
  //MARK:- SELECTORS
   //点击开始查询
   @IBAction func clickToQuery(_ sender: UIButton) {
     self.view.endEditing(true)
     if let params = self.paramsQuery(){
       let control = DriDamQueryResController()
       control.paramsQuery = params
       self.navigationController?.pushViewController(control, animated: true)
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
     self.stateStr = nil
     self.stateField.text = ""
     self.searchField.text = ""
     self.startDate.text = ""
     self.endDate.text = ""
   }
   
   
   @IBAction func clickState(){
     let rows = ["未处理","审核通过","审核驳回"]
     ActionSheetStringPicker.show(withTitle: "选择状态", rows: rows, initialSelection: 0, doneBlock: { [unowned self] (picker, indexex, values) in
       print("indexes :\(indexex)")
       self.stateStr = String(indexex)
       if let state = values as? String{
         self.stateField.text = state
       }
       }, cancel: { picker in
         
     }, origin: self.view)
   }
   
   
   //选择起始时间
   @IBAction func clickStartTimeBtn(_ sender: Any) {
     ActionSheetDatePicker.show(withTitle: "起始时间", datePickerMode: .dateAndTime, selectedDate: Date.init(), doneBlock: {[unowned self] (picker, selectedDate, values) in
       if let date = selectedDate as? Date{
         let dateStr = date.dateStringFrom(dateFormat: "yyyy-MM-dd hh:mm:ss")
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
         let dateStr = date.dateStringFrom(dateFormat: "yyyy-MM-dd hh:mm:ss")
         self.endDate.text = dateStr;
       }
       }, cancel: { (picker) in
         
     }, origin: self.view);
   }
   
  
  
  //MARK:- tableView datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataAry?.count ?? 0
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DriHeavQueryCell.cellID()) as! DriHeavQueryCell
    if let recModel = self.dataAry?[indexPath.row]{
      cell.updateUI(model: recModel)
    }
    return cell
  }
  
  
  //MARK:- tableView delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
    if let recModel = self.dataAry?[indexPath.row]{
      let control = DriDamQueryDetailController.DetailControl() as! DriDamQueryDetailController
      control.recModel = recModel
      self.navigationController?.pushViewController(control, animated: true)
    }
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40;
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.001
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     return 0.001
   }
  
  
  //MARK:- request params helper
  private func paramsQuery() -> [String: String]?{
    var params:[String: String] = [:]
    if let state = self.stateStr{
      params["blStatus"] = state
    }
    params["findData"] = self.searchField.text
    params["starTime"] = self.startDate.text
    params["endTime"] = self.endDate.text
    return params
  }
  
  
  
  //MARK:- request server
  func fetchDamageDatas(params: [String: String]) -> Void {
//    let carCode = DataManager.shared.loginDriver.truckNum
    let req = DamageRecReq(params: params)
    STNetworking<[DamRecModel]>(stRequest:req) {
      [unowned self] resp in
      self.tableView.es.stopPullToRefresh()
      if resp.stauts == Status.Success.rawValue{
        self.dataAry = resp.data
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


