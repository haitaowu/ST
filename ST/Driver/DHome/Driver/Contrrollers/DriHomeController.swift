//
//  DriHomeController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh





class DriHomeController: UIViewController,UITableViewDataSource,UITableViewDelegate {
	
	let kNumOfSection = 4
	
	let kSectionNotiIdx = 0
	let kSectionMissionTitleIdx = 1
	let kSectionNumIdx = 2
	let kSectionCarSendInfoIdx = 3
	
	var msgAry:Array<DriMsgModel>?
	var carInfoModel:UnFinishedModel?
	let group = DispatchGroup()
	
	//MARK:-IBoutlets
	@IBOutlet weak var tableView: UITableView!
	
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
		//		self.fetchUnFinishedDatas()
		self.setupNavBar()
	}
	
	//MARK:- setup tabbaritem navigationbar
	func setupTabBarItems() -> Void {
		self.tabBarItem = UITabBarItem.init(title: "首页", image: UIImage(named: "home_disselect"), selectedImage: UIImage(named:"home_select"))
	}
	
	func setupNavBar() -> Void {
		self.title = "首页";
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "菜单", style:.plain, target: self, action: #selector(DriHomeController.clickDriMenu))
	}
	
	
	private func setupTable(){
		
		self.edgesForExtendedLayout = [.bottom]
		
		let nibHeader = DriverNotiHeader.headerNib()
		self.tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: DriverNotiHeader.headerID())
		
		let missionHeader = DMissionHeader.headerNib()
		self.tableView.register(missionHeader, forHeaderFooterViewReuseIdentifier: DMissionHeader.headerID())
		
		let missionFooter = DMissionFooter.footerNib();
		self.tableView.register(missionFooter, forHeaderFooterViewReuseIdentifier: DMissionFooter.footerID());
		
		let numHeader = DNumHeader.headerNib();
		self.tableView.register(numHeader, forHeaderFooterViewReuseIdentifier: DNumHeader.headerID())
		
		let sendHeader = DSendInfoHeader.headerNib();
		self.tableView.register(sendHeader, forHeaderFooterViewReuseIdentifier: DSendInfoHeader.headerID())
		
		let signFooter = DSSignFooter.footerNib();
		self.tableView.register(signFooter, forHeaderFooterViewReuseIdentifier: DSSignFooter.footerID())
		
		let nibNotiCell = DriHMsgCell.cellNib();
		self.tableView.register(nibNotiCell, forCellReuseIdentifier: DriHMsgCell.cellID())
		
		let sendInfoCell = DriCarInfoCell.cellNib();
		self.tableView.register(sendInfoCell, forCellReuseIdentifier: DriCarInfoCell.cellID())
		
		self.tableView.es.addPullToRefresh {
			[unowned self] in
			self.fetchDatas()
		}
		
		self.tableView.es.startPullToRefresh()
	}
	
	
	//MARK:- 司机菜单栏
	@objc func clickDriMenu() -> Void {
		let menuControl = DriMenuController.init(nibName: "DriMenuController", bundle: nil)
		menuControl.hidesBottomBarWhenPushed = true
		menuControl.carInfo = self.carInfoModel
		self.navigationController?.pushViewController(menuControl, animated: true)
	}
	
	//MARK:- tableView datasource
	func numberOfSections(in tableView: UITableView) -> Int {
		return kNumOfSection;
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == kSectionNotiIdx {
			return self.msgAry?.count ?? 0
		}else if section == kSectionMissionTitleIdx {
			return 0;
		}else if section == kSectionNumIdx {
			return 0;
		}else if section == kSectionCarSendInfoIdx {
			if self.carInfoModel != nil{
				return DriCarInfoCell.keysAry.count;
			}else{
				return 0
			}
		}else{
			return 0;
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == kSectionNotiIdx {
			let cell = tableView.dequeueReusableCell(withIdentifier: DriHMsgCell.cellID()) as! DriHMsgCell
			if let dataAry = self.msgAry{
				let model = dataAry[indexPath.row]
				cell.updateCellUI(model: model)
			}
			return cell;
		}else if indexPath.section == kSectionCarSendInfoIdx {
			let cell = tableView.dequeueReusableCell(withIdentifier: DriCarInfoCell.cellID()) as! DriCarInfoCell
			if let model = self.carInfoModel{
				cell.updateUIBy(model: model, indexPath: indexPath)
			}
			return cell
		}else{
			let cell = tableView.dequeueReusableCell(withIdentifier: DriCarInfoCell.cellID())
			return cell!;
		}
	}
	
	
	//MARK:- tableView delegate
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
		if section == kSectionNotiIdx {
			return DriverNotiHeader.headerHeight();
		}else if section == kSectionMissionTitleIdx {
			return DMissionHeader.headerHeight();
		}else if section == kSectionNumIdx {
			return DNumHeader.headerHeight();
		}else{
			return 40;
		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == kSectionNotiIdx {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DriverNotiHeader.headerID())
			return header
		}else if section == kSectionMissionTitleIdx {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DMissionHeader.headerID()) as! DMissionHeader
			
			return header
		}else if section == kSectionNumIdx {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DNumHeader.headerID()) as! DNumHeader
			if let model = self.carInfoModel{
				header.updateUIBy(model: model)
			}
			return header
		}else if section == kSectionCarSendInfoIdx {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DSendInfoHeader.headerID())
			return header
		}else{
			return nil;
		}
	}
	
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == kSectionMissionTitleIdx {
			if let carInfo = self.carInfoModel,carInfo.bakNextStaTion.isEmpty==false{
				return DMissionFooter.footerHeight()
			}else{
				return 0.001;
			}
		}else if section == kSectionCarSendInfoIdx {
			return DSSignFooter.footerHeight()
		}else{
			return 0.001;
		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if section == kSectionMissionTitleIdx {
			if let carInfo = self.carInfoModel,carInfo.bakNextStaTion.isEmpty==false{
				let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: DMissionFooter.footerID()) as! DMissionFooter
				footer.updateUI(model: carInfo)
				return footer
			}else{
				return nil;
			}
		}else if section == kSectionCarSendInfoIdx {
			let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: DSSignFooter.footerID()) as! DSSignFooter
			footer.updateUI(model: self.carInfoModel){
				[unowned self] in
				self.reqSendSign()
				}
			return footer
		}else{
			return nil;
		}
	}
	
	//MARK:- request server
	//公告数据
	func fetchDatas() -> Void {
		group.enter()
		self.fetchMsgsDatas()
		
		group.enter()
		self.fetchUnFinishedDatas()
		
		group.notify(queue: .main) {
			[unowned self] in
			print("leave the goup thread.")
			self.tableView.es.stopPullToRefresh()
			self.tableView.reloadData()
		}
		
	}
	
	//公告数据
	func fetchMsgsDatas() -> Void {
		let carCode = DataManager.shared.loginDriver.truckNum
		let req = DriMsgReq(carCode: carCode)
		STNetworking<[DriMsgModel]>(stRequest:req) {
			[unowned self] resp in
			self.group.leave()
			if resp.stauts == Status.Success.rawValue{
				self.msgAry = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
	
	//正在进行的数据
	func fetchUnFinishedDatas() -> Void {
		let carCode = DataManager.shared.loginDriver.truckNum
		let req = UnFinishedReq(carCode: carCode)
		STNetworking<UnFinishedModel>(stRequest:req) {
			[unowned self] resp in
			self.group.leave()
			if resp.stauts == Status.Success.rawValue{
				self.carInfoModel = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
	//请求发车登记
	func reqSendSign()->Void{
		let dateStr = Date.init().dateStringFrom(dateFormat: "yyyy-MM-dd HH:mm:ss")
		var params:[String:String] = [:]
		params["sendCode"] = self.carInfoModel?.sendCode
		params["deiverScanDate"] = dateStr
		let req: DriSendSignReq = DriSendSignReq(params: params)
		STNetworking<ReqResult>(stRequest:req) {
		[unowned self] resp in
		if resp.stauts == Status.Success.rawValue{
			self.carInfoModel?.deiverStatus = "1"
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


