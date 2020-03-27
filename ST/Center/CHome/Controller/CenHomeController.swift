//
//  CenHomeController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh




class CenHomeController: UIViewController,UITableViewDataSource,UITableViewDelegate {
	
//	let kNumOfSection = 4
//
//	let kSectionNotiIdx = 0
//	let kSectionMissionTitleIdx = 1
//	let kSectionNumIdx = 2
//	let kSectionCarSendInfoIdx = 3
	
	//MARK:-IBoutlets
//	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var annTable: UITableView!
	@IBOutlet weak var carTable: UITableView!
	
	var carInfoModel:EmpHomeSendModel?
	var announcesAry:[AnnoModel]?
	let group = DispatchGroup()
	
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
		super.viewDidLoad()
		self.edgesForExtendedLayout = [.bottom]
		self.setupNavBarUI()
		self.setupTable()
		self.setupRefreshTable()
	}
	
	//MARK:- setup view
	func setupTabBarItems() -> Void {
		self.tabBarItem = UITabBarItem.init(title: "首页", image: UIImage(named: "home_disselect"), selectedImage: UIImage(named:"home_select"));
	}
	
	private func setupNavBarUI(){
		self.title = "首页";
    self.navigationController?.navigationBar.isTranslucent = false
	}
	
	func setupTable(){
//		let nibHeader = CenNotiHeader.headerNib();
//		self.tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: CenNotiHeader.headerID());
//
//		let sendArriHeader = SendArriHeader.headerNib();
//		self.tableView.register(sendArriHeader, forHeaderFooterViewReuseIdentifier: SendArriHeader.headerID());
//

//		let numHeader = EmpCarsTitleHeader.headerNib();
//		self.tableView.register(numHeader, forHeaderFooterViewReuseIdentifier: EmpCarsTitleHeader.headerID())
//
		
		let sendHeader = CarCountHeader.headerNib();
//		self.tableView.register(sendHeader, forHeaderFooterViewReuseIdentifier: CarCountHeader.headerID())
		
		//car info table header
		self.carTable.register(sendHeader, forHeaderFooterViewReuseIdentifier: CarCountHeader.headerID())
		
		let nibNotiCell = CenterAnnoCell.cellNib();
//		self.tableView.register(nibNotiCell, forCellReuseIdentifier: CenterAnnoCell.cellID())
		
		//announce table cell
		self.annTable.register(nibNotiCell, forCellReuseIdentifier: CenterAnnoCell.cellID())
		
		let sendInfoCell = SendCarInfoCell.cellNib();
//		self.tableView.register(sendInfoCell, forCellReuseIdentifier: SendCarInfoCell.cellID())
		
		//car info table cell
		self.carTable.register(sendInfoCell, forCellReuseIdentifier: SendCarInfoCell.cellID())
	}
	
	///给tableView添加下拉刷新功能
	func setupRefreshTable(){
		self.annTable.es.addPullToRefresh {
			[unowned self] in
      let siteName = DataManager.shared.loginUser.siteName
      let req = EmpHomAnnoReq(siteName: siteName)
			self.fetchAnnouncesData(req: req)
		}
		self.annTable.es.startPullToRefresh()
    
    
    self.carTable.es.addPullToRefresh {
      [unowned self] in
      let siteName = DataManager.shared.loginUser.siteName
      let req = EmpHomSendReq(siteName: siteName)
      self.fetchCarInfos(req: req)
    }
		
		DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
			self.carTable.es.startPullToRefresh()
		}
		
	}
	
	
	//显示到车、发车登录
	func showSign(type: ArriverSendType){
		if type == ArriverSendType.arrive {
			let storyboard = UIStoryboard.init(name: "STCenter", bundle: nil)
			let control = storyboard.instantiateViewController(withIdentifier: "CenArriSignController")
			control.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(control, animated: true)
		}else if type == ArriverSendType.send {
			let storyboard = UIStoryboard.init(name: "STCenter", bundle: nil)
			let control = storyboard.instantiateViewController(withIdentifier: "CenSendSignController")
			control.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(control, animated: true)
		}else{
			
		}
	}
	
	//MARK:- tableView datasource
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return kNumOfSection;
//	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView.tag == self.annTable.tag {
			let count = self.announcesAry?.count ?? 0
			return count
		}else{
			let count = self.carInfoModel?.homeInfo.count ?? 0
			return count;
		}
		
//		if section == kSectionNotiIdx {
//			let count = self.announcesAry?.count ?? 0
//			return count
//		}else if section == kSectionMissionTitleIdx {
//			return 0;
//		}else if section == kSectionNumIdx {
//			return 0;
//		}else if section == kSectionCarSendInfoIdx {
//			let count = self.carInfoModel?.homeInfo.count ?? 0
//			return count;
//		}else{
//			return 0;
//		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView.tag == self.annTable.tag {
			let cell = tableView.dequeueReusableCell(withIdentifier: CenterAnnoCell.cellID()) as! CenterAnnoCell
			if let ary = self.announcesAry{
				let model = ary[indexPath.row]
				cell.updateCellUI(model: model)
			}
			return cell
		}else{
			let cell = tableView.dequeueReusableCell(withIdentifier: SendCarInfoCell.cellID()) as!SendCarInfoCell
			return cell
		}
		
//		if indexPath.section == kSectionNotiIdx {
//			let cell = tableView.dequeueReusableCell(withIdentifier: CenterAnnoCell.cellID()) as! CenterAnnoCell
//			if let ary = self.announcesAry{
//				let model = ary[indexPath.row]
//				cell.updateCellUI(model: model)
//			}
//			return cell
//		}else if indexPath.section == kSectionCarSendInfoIdx {
//			let cell = tableView.dequeueReusableCell(withIdentifier: SendCarInfoCell.cellID()) as!SendCarInfoCell
//			if let infoAry = self.carInfoModel?.homeInfo{
//				let model = infoAry[indexPath.row]
//				cell.updateUIBy(model: model)
//			}
//			return cell;
//		}else{
//			let cell = tableView.dequeueReusableCell(withIdentifier: SendCarInfoCell.cellID())
//			return cell!;
//		}
	}
	
	
	//MARK:- tableView delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.tag == self.annTable.tag {
			let control = CenAnnounceDetailController(nibName: "CenAnnounceDetailController", bundle: nil)
			if let model = self.announcesAry?[indexPath.row]{
				control.model = model
			}
			control.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(control, animated: true)
		}
		
//
//   if indexPath.section == kSectionNotiIdx {
//    let control = CenAnnounceDetailController(nibName: "CenAnnounceDetailController", bundle: nil)
//    if let model = self.announcesAry?[indexPath.row]{
//      control.model = model
//    }
//    control.hidesBottomBarWhenPushed = true
//    self.navigationController?.pushViewController(control, animated: true)
//   }
  }
  
  
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag == self.annTable.tag {
			return 44
		}else{
			if let infoAry = self.carInfoModel?.homeInfo{
				let model = infoAry[indexPath.row]
				return SendCarInfoCell.cellHeight(data: model)
			}else{
				return 40
			}
		}
//
//		if indexPath.section == kSectionCarSendInfoIdx {
//			if let infoAry = self.carInfoModel?.homeInfo{
//				let model = infoAry[indexPath.row]
//				return SendCarInfoCell.cellHeight(data: model)
//			}else{
//				return 40
//			}
//		}else{
//			return 40
//		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if tableView.tag == self.carTable.tag {
			return CarCountHeader.headerHeight();
		}else{
			return 0.001
		}
		
//		if section == kSectionNotiIdx {
//			return CenNotiHeader.headerHeight();
//		}else if section == kSectionMissionTitleIdx {
//			return SendArriHeader.headerHeight();
//		}else if section == kSectionNumIdx {
//			return EmpCarsTitleHeader.headerHeight();
//		}else{
//			return 40;
//		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if tableView.tag == self.carTable.tag {
			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CarCountHeader.headerID()) as! CarCountHeader
			if let model = self.carInfoModel{
				header.updateUIBy(model: model)
			}
			return header
		}else{
			return nil
		}
		
//
//		if section == kSectionNotiIdx {
//			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CenNotiHeader.headerID())
//			return header
//		}else if section == kSectionMissionTitleIdx {
//			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SendArriHeader.headerID())
//			if let typeHeader = header as?SendArriHeader{
//				typeHeader.typeBlock = {
//					[unowned self] (type:ArriverSendType) in
//					self.showSign(type:type)
//				}
//			}
//			return header
//		}else if section == kSectionNumIdx {
//			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: EmpCarsTitleHeader.headerID())
//			return header
//		}else if section == kSectionCarSendInfoIdx {
//			let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CarCountHeader.headerID()) as! CarCountHeader
//			if let model = self.carInfoModel{
//				header.updateUIBy(model: model)
//			}
//			return header
//		}else{
//			return nil;
//		}
	}
	
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.001;
	}
	
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil;
	}
	
	//MARK:- request servers
  /*
	func fetchDatas(){
		let siteName = DataManager.shared.loginUser.siteName
		let req = EmpHomAnnoReq(siteName: siteName)
		
		group.enter()
		self.fetchAnnouncesData(req: req)
		
		let recReq = EmpHomSendReq(siteName: siteName)
		group.enter()
		self.fetchCarInfos(req: recReq)
		
		group.notify(queue: .main) {
			[unowned self] in
			self.tableView.es.stopPullToRefresh()
			self.tableView.reloadData()
		}
	}
  */
	
	///货车当前状态数据
	func fetchCarInfos(req:STRequest) -> Void {
		STNetworking<EmpHomeSendModel>(stRequest:req) {
			[unowned self] resp in
//			self.group.leave()
      self.carTable.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.carInfoModel = resp.data
        self.carTable.reloadData()
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
	
	///公告的数据
	func fetchAnnouncesData(req: STRequest) -> Void{
		STNetworking<[AnnoModel]>(stRequest:req) {
			[unowned self] resp in
//			self.group.leave()
      self.annTable.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.announcesAry = resp.data
        self.annTable.reloadData()
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
	
	
}


