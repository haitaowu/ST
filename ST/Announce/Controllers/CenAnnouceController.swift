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



class CenAnnouceController: BaseController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
  
  @IBOutlet weak var startField: UITextField!
  @IBOutlet weak var endTimeField: UITextField!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var queryBtn: UIButton!
  
  var startDate:Date?
  var endDate:Date?
  
  
  var dataAry:Array<AnnoModel>?

  
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
		self.tableView.emptyDataSetSource = self
		self.tableView.emptyDataSetDelegate = self
    let nibNotiCell = AnnounceCell.cellNib();
    self.tableView.register(nibNotiCell, forCellReuseIdentifier: AnnounceCell.cellID())
    self.tableView.es.addPullToRefresh {
      [unowned self] in
      let request = self.reqParams()
      guard let req = request else{return}
      self.fetchAnnoDatas(req: req)
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

	///显示查询结果界面(controller)
	func showQueryView(queryReq:STRequest?){
		let control: AnnouceQueryController = AnnouceQueryController()
		control.queryReq = queryReq
		control.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(control, animated: true)
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
		if let req = self.reqOfQuery(){
			self.showQueryView(queryReq: req)
		}
  }


  
  //MARK:- tableView datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataAry?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let  cell = tableView.dequeueReusableCell(withIdentifier: AnnounceCell.cellID()) as? AnnounceCell
    if let model = self.dataAry?[indexPath.row]{
      cell?.updateCellUI(model: model)
    }
    return cell!;
  }
  
  //MARK:- tableView delegate
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44;
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let control = CenAnnounceDetailController(nibName: "CenAnnounceDetailController", bundle: nil)
    if let model = self.dataAry?[indexPath.row]{
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
  
	
	//MARK:- empty data
	///emptyata button title
	func emptyBtnTitle() -> NSAttributedString {
		let title = "点我刷新试试"
		let attris = [NSAttributedString.Key.foregroundColor:UIColor.appBlue]
		let attriStr = NSAttributedString(string: title,attributes: attris)
		return attriStr
	}
	
	///是否第一次加载数据
	func firstLoadData()->Bool{
		if self.dataAry == nil{
			return true
		}else{
			return false
		}
	}
	
	///是否有公告信息
	func hasAnnData()->Bool{
		if self.firstLoadData() == false{
			if let data = self.dataAry{
				if data.count > 0{
					return true
				}else{
					return false
				}
			}else{
				return false
			}
		}else{
			return true
		}
	}
	
	
	//MARK:- override for DZNEmptyDataSetSource delegate
	override func titleForEmpty(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if self.hasAnnData() == false{
			let title = "暂无公告"
			let attriStr = NSAttributedString(string: title)
			return attriStr
		}else{
			return nil
		}
	}
	
	override func titleForEmptyBtn(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if self.hasAnnData() == false{
			return self.emptyBtnTitle()
		}else{
			return nil
		}
	}
	
	override func reloadViewData(scrollView: UIScrollView!) {
		self.tableView.es.startPullToRefresh()
	}
  
  //MARK:- params helper
	///无查询条件的公告列表的参数
  func reqParams() -> STRequest?{
    var request:STRequest?
    var params:[String:String] = [:]
    let manager = DataManager.shared
    if ((manager.roleType == .center) || (manager.roleType == .site)) {
      let accStr = manager.loginUser.siteName
      params["scanSite"] = accStr
      request = AnnounDataReq(params: params)
    }else{
      let truckNum = manager.loginDriver.truckNum
      params["truckNum"] = truckNum
      request = AnnoDriverDataReq(params: params)
    }
    return (request)
  }
	
	
	///条件查询的公告列表的参数
	func reqOfQuery() -> STRequest?{
    var request:STRequest?
    var params:[String:String] = [:]
    if self.queryBtn.isSelected{
      if let startD = self.startDate{
        let starTime = self.dateStrFrom(date: startD, formatStr: "yyyy-MM-dd HH:mm:ss")
        params["starTime"] = starTime
      }
      
      if let endD = self.startDate{
        let endTime = self.dateStrFrom(date: endD, formatStr: "yyyy-MM-dd HH:mm:ss")
        params["endTime"] = endTime
      }
      
      let searchTxt = self.searchBar.text
      if searchTxt?.isEmpty == false{
        params["findData"] = searchTxt
      }
    }

    let manager = DataManager.shared
    if ((manager.roleType == .center) || (manager.roleType == .site)) {
      let accStr = manager.loginUser.siteName
      params["scanSite"] = accStr
      request = AnnounDataReq(params: params)
    }else{
      let truckNum = manager.loginDriver.truckNum
      params["truckNum"] = truckNum
      request = AnnoDriverDataReq(params: params)
    }
    return request
  }
  

  
  //MARK:- request server
  ///请求公告数据
  func fetchAnnoDatas(req: STRequest) -> Void {
    STNetworking<[AnnoModel]>(stRequest:req) {
      [unowned self] resp in
      self.tableView.es.stopPullToRefresh()
			self.dataAry = []
      if resp.stauts == Status.Success.rawValue{
				self.dataAry = resp.data
      }else if resp.stauts == Status.NetworkTimeout.rawValue{
        self.remindUser(msg: "网络超时，请稍后尝试")
      }else{
        let msg = resp.msg
        self.remindUser(msg: msg)
      }
			self.tableView.reloadData()
      }?.resume()
  }
  
  
  
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
		if let req = self.reqOfQuery(){
			self.showQueryView(queryReq: req)
		}
    print("searchBarSearchButtonClicked")
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    print("searchBarCancelButtonClicked")
  }
  

  
}


