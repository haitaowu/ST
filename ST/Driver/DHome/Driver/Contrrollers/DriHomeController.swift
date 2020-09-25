//
//  DriHomeController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh





class DriHomeController: BaseController,UITableViewDataSource,UITableViewDelegate {
	


	let kSectionNotiIdx = 0
	let kSectionCarSendInfoIdx = 1
	
	

	var msgAry:Array<AnnoModel>?
	var carInfoModel:UnFinishedModel?
	
	var hasReqCarInfo:Bool = false

	//MARK:-IBoutlets

	@IBOutlet weak var annTable: UITableView!
	@IBOutlet weak var carTable: UITableView!
  
	
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
		self.setupTable()
		self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
		self.setupNavBar()
	}
	
	//MARK:- setup tabbaritem navigationbar
	func setupTabBarItems() -> Void {
		self.tabBarItem = UITabBarItem.init(title: "首页", image: UIImage(named: "home_disselect"), selectedImage: UIImage(named:"home_select"))
	}
	
	func setupNavBar() -> Void {
		self.title = "首页";
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "菜单", style:.plain, target: self, action: #selector(DriHomeController.clickDriMenu))
    self.navigationController?.navigationBar.isTranslucent = false
	}
	
	
	private func setupTable(){
		
		self.annTable.emptyDataSetSource = self
		self.annTable.emptyDataSetDelegate = self
		self.carTable.emptyDataSetSource = self
		self.carTable.emptyDataSetDelegate = self
		
		self.carTable.register(ExceptionHeader.headerNib(), forHeaderFooterViewReuseIdentifier: ExceptionHeader.headerID())
		
		self.carTable.register(DNumFooter.footerNib(), forHeaderFooterViewReuseIdentifier: DNumFooter.footerID())
		
    self.carTable.register(DSendInfoHeader.headerNib(), forHeaderFooterViewReuseIdentifier: DSendInfoHeader.headerID())
    
    self.carTable.register(DSSignFooter.footerNib(), forHeaderFooterViewReuseIdentifier: DSSignFooter.footerID())
		
		
    self.annTable.register(DriHMsgCell.cellNib(), forCellReuseIdentifier: DriHMsgCell.cellID())
    
    self.carTable.register(DriCarInfoCell.cellNib(), forCellReuseIdentifier: DriCarInfoCell.cellID())
		
    
		self.annTable.es.addPullToRefresh {
			[unowned self] in
			self.fetchMsgsDatas()
		}
		self.annTable.es.startPullToRefresh()
    
		
		self.carTable.es.addPullToRefresh {
			[unowned self] in
			self.fetchUnFinishedDatas()
		}
    
		DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
			self.carTable.es.startPullToRefresh()
		}
	}
	
	
	//MARK:- 司机菜单栏 update view
	@objc func clickDriMenu() -> Void {
		let menuControl = DriMenuController.init(nibName: "DriMenuController", bundle: nil)
		menuControl.hidesBottomBarWhenPushed = true
		menuControl.carInfo = self.carInfoModel
		self.navigationController?.pushViewController(menuControl, animated: true)
	}
	
	///显示司机发车登记界面
	func showSignView(){
		let dateStr = Date.init().dateStringFrom(dateFormat: "yyyy-MM-dd HH:mm:ss")
		var params:[String:String] = [:]
		params["sendCode"] = self.carInfoModel?.sendCode
		params["deiverScanDate"] = dateStr
		
		let storyboard = UIStoryboard.init(name: "Driver", bundle: nil)
		let driSignControl = storyboard.instantiateViewController(withIdentifier:"DriSignController") as! DriSignController
		driSignControl.params = params
		driSignControl.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(driSignControl, animated: true)
		driSignControl.doneBlock = {
			[unowned self] (isSigned) in
			if isSigned {
				self.carInfoModel?.deiverStatus = "1"
			}else{
				self.carInfoModel?.deiverStatus = "0"
			}
			self.carTable.reloadData()
		}
		
		
	}
	
	
	//MARK:- tableView datasource
	func numberOfSections(in tableView: UITableView) -> Int {
		if tableView.tag == self.annTable.tag{
			return 1
		}else{
			return 2
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView.tag == self.annTable.tag{
			return self.msgAry?.count ?? 0
		}else{
			if section == kSectionNotiIdx {
				return 0
			}else{
				if self.carInfoModel != nil{
					return DriCarInfoCell.keysAry.count;
				}else{
					return 0
				}
			}
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView.tag == self.annTable.tag {
			let cell = tableView.dequeueReusableCell(withIdentifier: DriHMsgCell.cellID()) as! DriHMsgCell
			if let dataAry = self.msgAry{
				let model = dataAry[indexPath.row]
				cell.updateCellUI(model: model)
			}
			return cell
		}else{
			let cell = tableView.dequeueReusableCell(withIdentifier: DriCarInfoCell.cellID()) as! DriCarInfoCell
			if let model = self.carInfoModel{
				cell.updateUIBy(model: model, indexPath: indexPath)
			}
			return cell
		}

	}
	
	
	//MARK:- tableView delegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
		if tableView.tag == self.annTable.tag {
			let control = CenAnnounceDetailController(nibName: "CenAnnounceDetailController", bundle: nil)
			if let model = self.msgAry?[indexPath.row]{
				control.model = model
			}
			control.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(control, animated: true)
		}
  }
	
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == kSectionNotiIdx {
			return 40;
		}else if indexPath.section == kSectionCarSendInfoIdx {
			return DriCarInfoCell .cellHeight(data: nil)
		}else{
			return 40;
		}
	}
	
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if tableView.tag == self.carTable.tag{
			if section == kSectionNotiIdx {
				if let carInfo = self.carInfoModel,carInfo.bakNextStaTion.isEmpty==false{
					return ExceptionHeader.headerHeight()
				}else{
					return 0.001;
				}
			}else if section == kSectionCarSendInfoIdx {
				if ((self.firstLoadCarArriData()==false)&&(self.carInfoModel != nil)) {
					return DSendInfoHeader.headerHeight();
				}else{
					return 0.001
				}
			}else{
				return 0.001
			}
		}else{
			return 0.001
		}
		
	}
	
	
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if tableView.tag == self.carTable.tag{
			if section == kSectionNotiIdx {
				let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExceptionHeader.headerID()) as! ExceptionHeader
				return header
			}else if section == kSectionCarSendInfoIdx {
				if ((self.firstLoadCarArriData()==false)&&(self.carInfoModel != nil)) {
					let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DSendInfoHeader.headerID()) as! DSendInfoHeader
					return header
				}else{
					return nil
				}
			}else{
				return nil
			}
		}else{
			return nil
		}
	}
	
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		if tableView.tag == self.carTable.tag {
			if section == kSectionNotiIdx{
				return DNumFooter.footerHeight()
			}else{
				return DSSignFooter.footerHeight()
			}
		}else{
			return 0.001
		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		
		if tableView.tag == self.carTable.tag {
			if ((self.firstLoadCarArriData()==false)&&(self.carInfoModel != nil)) {
				if section == kSectionNotiIdx{
					let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: DNumFooter.footerID()) as! DNumFooter
					if let model = self.carInfoModel{
						footer.updateUIBy(model: model)
					}
					return footer
				}else{
					let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: DSSignFooter.footerID()) as! DSSignFooter
					footer.updateUI(model: self.carInfoModel){
						[unowned self] in
						self.reqSendSign()
					}
					return footer
				}
			}else{
				return nil
			}
		}else{
			return nil
		}

	}
	
	//MARK:- empty data
	///empty attributestring title
	
	
	///是否第一次加载公告数据
	func firstLoadAnnoData()->Bool{
		if self.msgAry == nil{
			return true
		}else{
			return false
		}
	}
	
	///是否有公告信息
	func hasAnnoData()->Bool{
		if self.firstLoadAnnoData() == false{
			if let data = self.msgAry{
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
	
	///是否第一次加载进行中任务数据
	func firstLoadCarArriData()->Bool{
		if self.hasReqCarInfo == false{
			return true
		}else{
			return false
		}
	}
	
	///是否有发车数据
	func hasCarData()->Bool{
		if self.firstLoadCarArriData() == false{
			if self.carInfoModel != nil{
				return true
			}else{
				return false
			}
		}else{
			return true
		}
	}

	
	//MARK:- override for DZNEmptyDataSetSource
	override func titleForEmpty(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if scrollView.tag == self.annTable.tag{
			if self.hasAnnoData() == false{
				let title = "暂无公告..."
				return self.attri(title: title)
			}else{
				return nil
			}
		}else if scrollView.tag == self.carTable.tag{
			if (self.hasCarData() == false){
				let title = "暂无进行中的任务..."
				return self.attri(title: title)
			}else{
				return nil
			}
		}else{
			return nil
		}
	}
	
	
	override func titleForEmptyBtn(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if scrollView.tag == self.annTable.tag{
			if self.hasAnnoData() == false{
				return self.emptyBtnTitle()
			}else{
				return nil
			}
		}else{
			if (self.hasCarData() == false){
				return self.emptyBtnTitle()
			}else{
				return nil
			}
		}
	}
	
	override func reloadViewData(scrollView: UIScrollView!) {
		if scrollView.tag == self.annTable.tag {
			self.annTable.es.startPullToRefresh()
		}else{
			self.carTable.es.startPullToRefresh()
		}
	}
	
	
	//MARK:- request server
	//公告数据
	func fetchMsgsDatas() -> Void {
		let carCode = DataManager.shared.loginDriver.truckNum
		let req = DriMsgReq(carCode: carCode)
		STNetworking<[AnnoModel]>(stRequest:req) {
			[unowned self] resp in
      self.annTable.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.msgAry = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
				self.annTable.reloadData()
			}?.resume()
	}
	
	
	//正在进行的数据
	func fetchUnFinishedDatas() -> Void {
		let carCode = DataManager.shared.loginDriver.truckNum
		let req = UnFinishedReq(carCode: carCode)
		STNetworking<UnFinishedModel>(stRequest:req) {
			[unowned self] resp in
      self.carTable.es.stopPullToRefresh()
			self.hasReqCarInfo = true
			if resp.stauts == Status.Success.rawValue{
				self.carInfoModel = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			self.carTable.reloadData()
			}?.resume()
	}
	
	//请求发车登记
	func reqSendSign()->Void{
//		self.showSignView()
//		return;
		let dateStr = Date.init().dateStringFrom(dateFormat: "yyyy-MM-dd HH:mm:ss")
		var params:[String:String] = [:]
		params["sendCode"] = self.carInfoModel?.sendCode
		params["deiverScanDate"] = dateStr
		let req: DriSendSignReq = DriSendSignReq(params: params)
		STNetworking<ReqResult>(stRequest:req) {
		[unowned self] resp in
		if resp.stauts == Status.Success.rawValue{
			self.carInfoModel?.deiverStatus = "1"
			self.carTable.reloadData()
		}else if resp.stauts == Status.NetworkTimeout.rawValue{
			self.remindUser(msg: "网络超时，请稍后尝试")
		}else{
			let msg = resp.msg
			self.remindUser(msg: msg)
		}
		}?.resume()
	}
	
}


