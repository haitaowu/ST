//
//  CenAnnouceController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh
import ActionSheetPicker_3_0



class CenAnnouceController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
  
  @IBOutlet weak var startField: UITextField!
  @IBOutlet weak var endTimeField: UITextField!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var queryBtn: UIButton!
  
  var startDate:Date?
  var endDate:Date?
  
  
  var msgAry:Array<AnnoModel>?
  var searchMsgAry:Array<AnnoModel>?
  
  
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
    self.basicInitUI()
    self.basicInitTable()
  }
  
  //MARK:- setup tabbaritem
  private func setupTabBarItems() -> Void {
    self.tabBarItem = UITabBarItem(title: "公告", image:UIImage(named:"notification_disselected") , selectedImage: UIImage(named:"notification_selected"));
  }
  
  //init tableView
  private func basicInitTable(){
    let nibNotiCell = AnnounceCell.cellNib();
    self.tableView.register(nibNotiCell, forCellReuseIdentifier: AnnounceCell.cellID())
    self.tableView.es.addPullToRefresh {
      [unowned self] in
      let result = self.reqParams()
      let request = result.req
      let params = result.params
      guard let req = request else{return}
      self.fetchAnnoDatas(params: params, req: req)
    }
    self.tableView.es.startPullToRefresh()
  }
  
  //init base ui
  private func basicInitUI(){
    self.searchBar.delegate = self
    self.title = "公告";
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  //MARK:- private helper func
  ///把日期Date转换为String
  private func dateStrFrom(date: Date, formatStr: String) ->String{
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = formatStr
    let dateStr = dateFormat.string(from: date)
    return dateStr
  }
  
  ///是否compareDate日期是fromDate之后的日期
  private func isDate(compareDate: Date, after fromDate:Date) ->Bool{
    let intervaleCompare = compareDate.timeIntervalSince1970
    let interFrom = fromDate.timeIntervalSince1970
    if intervaleCompare > interFrom {
      return true
    }else{
      return false
    }
  }

  //MARK:- SELECTORS
  //选择起始时间
  @IBAction func clickStartTimeBtn(_ sender: Any) {
    ActionSheetDatePicker.show(withTitle: "起始时间", datePickerMode: .dateAndTime, selectedDate: Date.init(), doneBlock: {[unowned self] (picker, selectedDate, values) in
      
      if let date = selectedDate as? Date{
        var isRightDate = true
        if let endD = self.endDate{
          isRightDate = self.isDate(compareDate:endD , after: date)
        }
        if isRightDate{
          let dateStr = self.dateStrFrom(date: date, formatStr: "yyyy-MM-dd HH:mm:ss")
          self.startField.text = dateStr
          self.startDate = date
        }else{
          self.remindUser(msg: "请选择起始时间之前的日期日期区间不对")
        }
      }
      }, cancel: { (picker) in
        
    }, origin: self.view);
    print("start ");
  }
  
  
  //选择结束时间
  @IBAction func clickEndTimeBtn(_ sender: Any) {
    ActionSheetDatePicker.show(withTitle: "结束时间", datePickerMode: .dateAndTime, selectedDate: Date.init(), doneBlock: {[unowned self] (picker, selectedDate, values) in
      if let  date = selectedDate as? Date{
        var isRightDate = true
        if let startD = self.startDate{
          isRightDate = self.isDate(compareDate:date , after: startD)
        }
        if isRightDate{
          let dateStr = self.dateStrFrom(date: date, formatStr: "yyyy-MM-dd HH:mm:ss")
          print("date::::\(date)>>>Str:\(dateStr)")
          self.endTimeField.text = dateStr;
          self.endDate = date
        }else{
          self.remindUser(msg: "请选择起始时间之后的日期")
        }
      }
      }, cancel: { (picker) in
        
    }, origin: self.view);
  }
  
 //点击开始查询
  @IBAction func clickToQuery(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    if sender.isSelected{
      self.tableView.es.startPullToRefresh()
    }else{
      self.tableView.reloadData()
    }
  }

  
  //MARK:- tableView datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.queryBtn.isSelected{
      return self.searchMsgAry?.count ?? 0
    }else{
      return self.msgAry?.count ?? 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellModel:AnnoModel?
    if self.queryBtn.isSelected{
      cellModel = self.searchMsgAry?[indexPath.row]
    }else{
      cellModel = self.msgAry?[indexPath.row]
    }
    let  cell = tableView.dequeueReusableCell(withIdentifier: AnnounceCell.cellID()) as? AnnounceCell
    if let model = cellModel{
      cell?.updateCellUI(model: model)
    }
    return cell!;
  }
  
  //MARK:- tableView delegate
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40;
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let control = CenAnnounceDetailController(nibName: "CenAnnounceDetailController", bundle: nil)
    let cellModel:AnnoModel?
    if self.queryBtn.isSelected{
      cellModel = self.searchMsgAry?[indexPath.row]
    }else{
      cellModel = self.msgAry?[indexPath.row]
    }
    if let model = cellModel{
      control.model = model
    }
    control.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(control, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.001
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.001
  }
  
  
  //MARK:- params helper
  func reqParams() -> (params:[String: String],req:STRequest?){
    var request:STRequest?
    var reqParams:[String:String] = [:]
    if self.queryBtn.isSelected{
      if let startD = self.startDate{
        let starTime = self.dateStrFrom(date: startD, formatStr: "yyyy-MM-dd HH:mm:ss")
        reqParams["starTime"] = starTime
      }
      
      if let endD = self.startDate{
        let endTime = self.dateStrFrom(date: endD, formatStr: "yyyy-MM-dd HH:mm:ss")
        reqParams["endTime"] = endTime
      }
      
      let searchTxt = self.searchBar.text
      if searchTxt?.isEmpty == false{
        reqParams["findData"] = searchTxt
      }
    }

    let manager = DataManager.shared
    if ((manager.roleType == .center) || (manager.roleType == .site)) {
      let accStr = manager.loginUser.siteName
      reqParams["scanSite"] = accStr
      request = AnnounDataReq(params: reqParams)
    }else{
      let truckNum = manager.loginDriver.truckNum
      reqParams["truckNum"] = truckNum
      request = AnnoDriverDataReq(params: reqParams)
    }
    return (reqParams,request)
  }
  

  
  //MARK:- request server
  ///请求公告数据
  func fetchAnnoDatas(params: [String: String],req: STRequest) -> Void {
    STNetworking<[AnnoModel]>(stRequest:req) {
      [unowned self] resp in
      self.tableView.es.stopPullToRefresh()
      if resp.stauts == Status.Success.rawValue{
        if self.queryBtn.isSelected{
          self.msgAry = resp.data
        }else{
          self.searchMsgAry = resp.data
        }
        self.tableView.reloadData()
      }else if resp.stauts == Status.NetworkTimeout.rawValue{
        self.remindUser(msg: "网络超时，请稍后尝试")
      }else{
        let msg = resp.msg
        self.remindUser(msg: msg)
      }
      }?.resume()
  }
  
  ///按条件查询数据
  /*func fetchSearchAnnoDatasBy(params: [String:String],req: STRequest) -> Void {
    STNetworking<[AnnoModel]>(stRequest:req) {
      [unowned self] resp in
      self.tableView.es.stopPullToRefresh()
      if resp.stauts == Status.Success.rawValue{
        self.searchMsgAry = resp.data
        self.tableView.reloadData()
      }else if resp.stauts == Status.NetworkTimeout.rawValue{
        self.remindUser(msg: "网络超时，请稍后尝试")
      }else{
        let msg = resp.msg
        self.remindUser(msg: msg)
      }
      }?.resume()
  }
 */
  
  
  //MARK:- UISearchBarDelegate
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    print("searchBarTextDidEndEditing")
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    print("searchBarSearchButtonClicked")
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    print("searchBarCancelButtonClicked")
  }
  

  
}


