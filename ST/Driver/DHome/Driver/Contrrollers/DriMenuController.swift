//
//  DriMenuController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import MapKit





class DriMenuController: UIViewController,UITableViewDataSource,UITableViewDelegate{
	
	var menuAry:Array<Any>?
	
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
			self.fetchNextStationLoc()
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
	
	///选择提醒时间之后提交服务器。
	func submitArriCarAlert(){
		if let params = self.paramsAlert(){
			self.submitArriAlertData(param: params)
		}
	}
	
	
	func startNavi(latitude: Double,longitude: Double){
		
		guard let nexLoc = self.nextSiteLoc else{return}
		
		let latitute = Double(nexLoc.latitude)!
		let longitute = Double(nexLoc.longitude)!

		let alter = UIAlertController.init(title: "请选择导航应用程序", message: "", preferredStyle: UIAlertController.Style.actionSheet)
		

		let cancel =  UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { (sheet) in
			
		}
		
		let apple =  UIAlertAction(title: "苹果地图", style: UIAlertAction.Style.default) { (sheet) in
			self.openIOSMap(longitude: longitute, latitude: latitute)
		}
		
		let gd =  UIAlertAction(title: "高德地图", style: UIAlertAction.Style.default) { (sheet) in
			self.openGDMap(longitude: longitute, latitude: latitute)
		}
		
		let bd =  UIAlertAction(title: "百度地图", style: UIAlertAction.Style.default) { (sheet) in
			self.openBaiDuMap(longitude: longitute, latitude: latitute)
		}
		
		alter.addAction(apple)
		alter.addAction(gd)
		alter.addAction(bd)
		alter.addAction(cancel)
		self.present(alter, animated: true, completion: nil)
	}
	
	// 高德经纬度转为百度地图经纬度
	// 百度经纬度转为高德经纬度，减掉相应的值就可以了。
	func getBaiDuCoordinateByGaoDeCoordinate(coordinate:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
			return CLLocationCoordinate2DMake(coordinate.latitude + 0.006, coordinate.longitude + 0.0065)
	}
	
	//打开百度地图
	func openBaiDuMap(longitude: Double, latitude: Double){
		let coordinate = CLLocationCoordinate2DMake(latitude, longitude)

		let endAddress = "下一站"
		// 将高德的经纬度转为百度的经纬度
		let baidu_coordinate = getBaiDuCoordinateByGaoDeCoordinate(coordinate: coordinate)
		let destination = "\(baidu_coordinate.latitude),\(baidu_coordinate.longitude)"
		let urlString = "baidumap://map/direction?" + "&destination=" + endAddress + "&mode=driving&destination=" + destination
		let str = urlString as NSString
		if self.openMap(str) == false {
			self.remindUser(msg: "您还没有安装百度地图")
		}
	}
	
	
	//打开自带地图
	func openIOSMap(longitude: Double, latitude: Double){
		let destination = "下一站"
		let loc = CLLocationCoordinate2DMake(latitude, longitude)
		let currentLocation = MKMapItem.forCurrentLocation()
		let toLocation = MKMapItem(placemark:MKPlacemark(coordinate:loc,addressDictionary:nil))
		toLocation.name = destination
		MKMapItem.openMaps(with: [currentLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
	
	
	//打开高德地图
	func openGDMap(longitude: Double, latitude: Double){
		let appName = "速通"
		let dname = "下一站"
		
		let urlString = "iosamap://path?sourceApplication=\(appName)&dname=\(dname)&dlat=\(latitude)&dlon=\(longitude)&t=0" as NSString
		
		if self.openMap(urlString) == false {
			self.remindUser(msg: "您还没有安装高德地图")
		}
	}
	
	
	// 打开第三方地图
	private func openMap(_ urlString: NSString) -> Bool {
			let url = NSURL(string:urlString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!)
			if UIApplication.shared.canOpenURL(url! as URL) == true {
					UIApplication.shared.openURL(url! as URL)
					return true
			} else {
					return false
			}
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
		if siteName == ""{
			self.remindUser(msg: "暂无下站信息,无法导航")
			print("currentThread name：\(Thread.current)")
//			return
		}else{
			self.showLoading(msg: "请求站点...")
			let req = NextLocReq(siteName: siteName)
			STNetworking<NexSiteLocModel>(stRequest:req) {
				[unowned self] resp in
				if resp.stauts == Status.Success.rawValue{
					self.nextSiteLoc = resp.data
					if let longitude = self.currentLongitude,let latitude = self.currentLatitude{
						self.startNavi(latitude: latitude, longitude: longitude)
					}
				}else if resp.stauts == Status.NetworkTimeout.rawValue{
					self.remindUser(msg: "网络超时，请稍后尝试")
				}else{
					let msg = resp.msg
					self.remindUser(msg: msg)
				}
				}?.resume()
		}
	}
	
	
	
	
	
	
	
	
	
}


