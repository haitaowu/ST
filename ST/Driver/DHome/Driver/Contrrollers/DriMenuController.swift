//
//  DriMenuController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0





class DriMenuController: UIViewController,UITableViewDataSource,UITableViewDelegate,BNNaviRoutePlanDelegate,BNNaviUIManagerDelegate,BMKLocationAuthDelegate{
	
	var menuAry:Array<Any>?
	var locationManager:BMKLocationManager?
	
	var carInfo:UnFinishedModel?
	
	//MARK:-IBoutlets
	@IBOutlet weak var tableView: UITableView!
	
	///当前经度
	var currentLongitude:Double?
	///当前纬度
	var currentLatitude:Double?
	
	///提醒时间
	var alertDuration:String?
	
	var nextSiteLoc:NexSiteLocModel?
	
	let group = DispatchGroup()
	
	
	
	//MARK:- Overrides
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.setupTableView()
		self.setupController()
		initMenuCell()
	}
	
	//MARK:- setup
	func setupController() -> Void {
		self.title = "菜单";
	}
	
	func setupTableView() -> Void {
		let menuCell = STMenuCell.cellNib();
		self.tableView.register(menuCell, forCellReuseIdentifier: STMenuCell.cellID())
	}
	
	func initMenuCell(){
		self.menuAry = Array()
		let navStr = CellMenuType.nav.rawValue + ",导航";
		self.menuAry?.append(navStr)
		let alertStr = CellMenuType.alert.rawValue + ",到车提醒";
		self.menuAry?.append(alertStr)
		let heavyStr = CellMenuType.heavy.rawValue + ",堵车报备";
		self.menuAry?.append(heavyStr)
		let damgeStr = CellMenuType.damge.rawValue + ",车损报备";
		self.menuAry?.append(damgeStr)
	}
	
	//MARK:- private methods
	func showMenu(menuStr: String) -> Void {
		if menuStr == CellMenuType.nav.rawValue {
			
//			guard self.carInfo != nil else {
//				self.remindUser(msg: "没有到车信息")
//				return
//			}
			self.showLoading(msg: "请求站点...")
			self.initLocationService()
			self.fetchNextStationLoc()
			self.group.notify(queue: .main) {
				[unowned self] in
				self.hideLoading()
				if let longitude = self.currentLongitude,let latitude = self.currentLatitude{
					self.startNavi(latitude: latitude, longitude: longitude)
				}
			}
		}else if menuStr == CellMenuType.alert.rawValue {
			self.alertDurationPicker()
		}else if menuStr == CellMenuType.heavy.rawValue {
			let storyboard = UIStoryboard.init(name: "Driver", bundle: nil)
			let control = storyboard.instantiateViewController(withIdentifier: "DriHeavyController")
			self.navigationController?.pushViewController(control, animated: true)
		}else if menuStr == CellMenuType.damge.rawValue {
			let storyboard = UIStoryboard.init(name: "Driver", bundle: nil)
			let control = storyboard.instantiateViewController(withIdentifier: "DriDamgeController")
			self.navigationController?.pushViewController(control, animated: true)
		}else{
		}
	}
	
	//到车提醒时间
	func alertDurationPicker(){
		let rows = ["15分钟","30分钟","40分钟"]
		ActionSheetStringPicker.show(withTitle: "提醒时间", rows: rows, initialSelection: 0, doneBlock: { [unowned self] (picker, indexex, values) in
			if let durationStr = values as? String{
				self.alertDuration = durationStr
				self.tableView.reloadData()
				self.submitArriCarAlert()
			}
			
			}, cancel: { picker in
				
		}, origin: self.view)
	}
	
	///选择提醒时间之后r提交服务器。
	func submitArriCarAlert(){
		if let params = self.paramsAlert(){
			self.submitArriAlertData(param: params)
		}
	}
	
	//开始导航
	func startNavi(latitude: Double,longitude: Double){
		guard let nexLoc = self.nextSiteLoc else{return}
		
		var nodes = [BNRoutePlanNode]()
		let startNode = BNRoutePlanNode()
		startNode.pos = BNPosition()
		startNode.pos.x = longitude
		startNode.pos.y = latitude
		startNode.pos.eType = BNCoordinate_BaiduMapSDK
		nodes.append(startNode)
		
		let nexLongitude = Double(nexLoc.longitude)
		let nexLatitude = Double(nexLoc.latitude)
		let endNode = BNRoutePlanNode()
		endNode.pos = BNPosition()
		endNode.pos.x = nexLongitude!
		endNode.pos.y = nexLatitude!
		endNode.pos.eType = BNCoordinate_BaiduMapSDK
		nodes.append(endNode)
		
		BNaviService.getInstance()?.routePlanManager()?.startNaviRoutePlan(BNRoutePlanMode_Recommend, naviNodes: nodes, time: nil, delegete: self, userInfo: nil)
		
	}
	
	
	//获取当前经纬度
	func initLocationService(){
		
		BMKLocationAuth.sharedInstance()?.checkPermision(withKey: Consts.BDNaviAK, authDelegate: self)
		
		self.locationManager = BMKLocationManager.init()
		if let locManager = self.locationManager{
			locManager.coordinateType = BMKLocationCoordinateType.BMK09LL
			locManager.desiredAccuracy = kCLLocationAccuracyBest
			//设置是否自动停止位置更新
			locManager.pausesLocationUpdatesAutomatically = false
			self.group.enter()
			locManager.requestLocation(withReGeocode: true, withNetworkState: true) { [unowned self] (location, state, error) in
				if (error != nil){
//						 print(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
					print("error>>>>>>>>>>>>>")
				 }
				if let loc = location{//得到定位信息，添加annotation
					print ("cclLocation????????????????????????????:\(loc.location)")
					if let longitude = loc.location?.coordinate.longitude,let latitude = loc.location?.coordinate.latitude{
						self.currentLongitude = longitude
						self.currentLatitude = latitude
						self.group.leave()
					}
				}
			}
		}
	}
	

	
	//MARK:- BMKLocationAuthDelegate
	/**
	*@brief 返回授权验证错误
	*@param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
	*/
	func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
		
	}

	
	//MARK:- BNNaviRoutePlanDelegate
	func routePlanDidFinished(_ userInfo: [AnyHashable : Any]!) {
		print("算路成功回调。。。")
		BNaviService.getInstance()?.uiManager()?.showPage(BNaviUI_NormalNavi, delegate: self, extParams: nil)
	}
	
	func routePlanDidUserCanceled(_ userInfo: [AnyHashable : Any]!) {
		print("算路取消。。。")
	}
	
	func routePlanDidFailedWithError(_ error: Error!, andUserInfo userInfo: [AnyHashable : Any]! = [:]) {
		print("算路失败回调。。。")
	}
	
	func searchDidFinished(_ userInfo: [AnyHashable : Any]!) {
		print("检索成功。。。")
	}
	

	//MARK:- BNNaviUIManagerDelegate
	
	func willExitPage(_ pageType: BNaviUIType, extraInfo: [AnyHashable : Any]!) {
		print("willExitPage...")
	}
	
	func onExitPage(_ pageType: BNaviUIType, extraInfo: [AnyHashable : Any]!) {
		print("onExitPage...")
	}
	
	//MARK:- tableView datasource
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let ary = self.menuAry{
			return ary.count
		}else{
			return 0
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: STMenuCell.cellID()) as! STMenuCell
		if let ary = self.menuAry{
			let cellData = ary[indexPath.row] as! String
			var subTitle:String?
			if let type = cellData.components(separatedBy: ",").first,type == CellMenuType.alert.rawValue{
				subTitle = self.alertDuration
			}
			cell.setupCell(dataStr: cellData,subTitle: subTitle)
				
		}
		return cell;
	}
	
	
	//MARK:- tableView delegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let ary = self.menuAry{
			let cellData = ary[indexPath.row] as! String
			if let type = cellData.components(separatedBy: ",").first{
				print("type = "+type)
				self.showMenu(menuStr: type)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40;
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	
	
  //MARK:- request helper
	///提醒时间设置参数
	func paramsAlert() -> [String: String]? {
		var params:[String: String] = [:]
		if let duration = self.alertDuration{
      params["reaminTime"] = duration
    }else{
      self.remindUser(msg: "请选择提醒时间")
      return nil
    }
		
		if let car = self.carInfo{
			params["sendCode"] = car.sendCode
		}else{
      self.remindUser(msg: "没有发车信息")
      return nil
    }
		let driver = DataManager.shared.loginDriver
		params["truckNum"] = driver.truckNum
		params["operateMan"] = driver.truckOwer
		return params
	}
	
	
  //MARK:- request server
	private func submitArriAlertData(param:[String:String]) -> Void {
		self.showLoading(msg: "提交数据中...")
		let req = ArriAlertReq(params: param)
		STNetworking<RespMsg>(stRequest:req) {
			[unowned self] resp in
			if resp.stauts == Status.Success.rawValue{
				self.remindUser(msg: "提交成功")
        self.navigationController?.popViewController(animated: true)
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				var msg = resp.msg
				if resp.stauts == Status.PasswordWrong.rawValue{
					msg = "提交错误"
				}
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
  
	
	
	//根据登录账号获取下个站点的经纬度
	func fetchNextStationLoc() -> Void {
		guard let car = self.carInfo else {
			return;
		}
		let siteName = car.bakNextStaTion
		self.group.enter()
		let req = NextLocReq(siteName: siteName)
		STNetworking<NexSiteLocModel>(stRequest:req) {
		[unowned self] resp in
		self.group.leave()
		if resp.stauts == Status.Success.rawValue{
			self.nextSiteLoc = resp.data
		}else if resp.stauts == Status.NetworkTimeout.rawValue{
			self.remindUser(msg: "网络超时，请稍后尝试")
		}else{
			let msg = resp.msg
			self.remindUser(msg: msg)
		}
		}?.resume()
	}
	
	
	
	
	
	
	
	
}


