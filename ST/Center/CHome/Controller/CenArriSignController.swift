//
//  CenArriSignController.swift
//  ST
//
//  Created by taotao on 2019/7/29.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0



class CenArriSignController: UITableViewController,QrInterface,CLLocationManagerDelegate{
  
  
  @IBOutlet var moreFields: [UITextField]!
	
	///可以扫描的封签号
  @IBOutlet var qrFields: [UITextField]!
	
	///必填标签集合
  @IBOutlet var labelsCollect: [UILabel]!
  
  //车牌
  @IBOutlet weak var carNumField: UITextField!
  //是否加班
  @IBOutlet weak var tmpTruckLabel: UILabel!
  //车型
  @IBOutlet weak var carTypeLabel: UILabel!
  //挂车号
  @IBOutlet weak var carPendNumLabel: UILabel!
  //路由
  @IBOutlet weak var routeLabel: UILabel!
  //发车时间
  @IBOutlet weak var sendCarTime: UILabel!
  //封签号（后）
  @IBOutlet weak var labelBackField: UITextField!
  //封签号（前侧）
  @IBOutlet weak var labelFrontSideField: UITextField!
  //封签号（后侧）
  @IBOutlet weak var labelBackSideField: UITextField!
  //到仓时间
  @IBOutlet weak var arriDateTimeField: UITextField!
  //停靠位
  @IBOutlet weak var positionField: UITextField!
  
  
  var scanField:UITextField?
  
  ///选中的车牌
  var selTruckModel:TruckNumModel?
  
  ///发车的信息
  var sendTruckInfo:SendTruckModel?
	
	let locManager:CLLocationManager = CLLocationManager()
	///当前的位置
	var curLocation:CLLocation?
  
  
  //MARK:- overrides
  override func viewDidLoad() {
    self.view.addDismissGesture()
    
    for label in self.labelsCollect{
      let txt = label.text!
      if let nsRan = txt.nsRangeOf(txt: "*"){
        let attri = NSMutableAttributedString(string: txt)
        attri.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: nsRan)
        label.attributedText = attri
      }
    }
    
    for field in self.qrFields{
			field.addLeftSpaceView(width: 8)
		}
		self.positionField.addLeftSpaceView(width: 8)
		
    for field in self.moreFields{
      let typeImg = UIImage(named: "arrow");
      let rightViewF = CGRect(x: 0, y: 0, width: 33, height: 33)
      let typeRightVeiw = UIButton.init(frame: rightViewF)
      typeRightVeiw.tag = field.tag
      typeRightVeiw.setImage(typeImg, for: .normal)
      typeRightVeiw.addTarget(self, action: #selector(CenArriSignController.clickFieldMore), for: .touchUpInside)
      field.rightView = typeRightVeiw
      field.rightViewMode = .always
      field.addLeftSpaceView(width: 8)
    }
		
		self.reqLocationAuthorizeStatus {
			[unowned self] (authorized) in
			if(authorized){
				self.startUpdateLocation()
			}else{
				let alertControl = UIAlertController.init(title: "位置授权", message: "需要你授权位置", preferredStyle: UIAlertController.Style.alert)
				let yAction = UIAlertAction.init(title: "YES", style: UIAlertAction.Style.default) { (action) in
					
				}
				let nAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel) { (action) in
				}
				alertControl.addAction(yAction)
				alertControl.addAction(nAction)
			}
		}
		
  }
	
	
  
  
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.locManager.stopUpdatingLocation()
	}
	
  //MARK:- update ui
  func updateSendTruckUIBy(carInfo: SendTruckModel){
    self.tmpTruckLabel.text = carInfo.blTempWork
    self.carTypeLabel.text = carInfo.truckType
    self.carPendNumLabel.text = carInfo.truckCarNum
    self.routeLabel.text = carInfo.lineName
    self.sendCarTime.text = carInfo.starTime
  }
  
  //MARK:-  selectors
  //确认
  @IBAction func clickConfirmItem(_ sender: Any) {
		if(self.inSignArea()){
			if let params = self.paramsArri(){
				self.submitArriSign(params: params)
			}
		}
  }
	
  ///点击去扫描
  @IBAction func clickToScan(_ sender: UIButton) {
		for field in self.qrFields{
      if field.tag == sender.tag{
        self.scanField = field
      }
    }
    self.openQrReader()
  }
	
  
  let CarNumTag = 0,ArriTimeTag = 1
  //field rightview selector
  @objc func clickFieldMore(sender: UIButton) -> Void {
    if sender.tag == CarNumTag {
			self.fetchTruckNums()
    }else if sender.tag == ArriTimeTag {
      self.showDateTimeSeet()
    }else{
    }
  }
  
  //外调加班车
  @IBAction func clickOutCarWork(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
  }
  
  //MARK:- private
  //用户选择了车牌
  func hasSelectTruckNum(model: TruckNumModel){
    var params:[String: String] = [:]
    params["truckNum"] = model.truckNum
    params["scanSite"] = DataManager.shared.loginUser.siteName
    self.fetchArrivedTruckInfo(params: params)
  }
	
	///位置授权状态:notdetermine denied always inUse
	func reqLocationAuthorizeStatus(result: ((_ authorized: Bool)->Void)) -> Void {
		locManager.requestWhenInUseAuthorization();
		let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
		if(authStatus == .denied){
			result(false)
		}else if(authStatus == .notDetermined){
			result(false)
		}else{
			result(true)
		}
	}
	
	///开始i当前的位置
	func startUpdateLocation(){
		locManager.delegate = self
		locManager.desiredAccuracy = kCLLocationAccuracyBest
		locManager.startUpdatingLocation()
	}
	
	///是否在500米内
	func inSignArea()-> Bool{
		guard let curLoc = self.curLocation else {
			return false
		}
		let user = DataManager.shared.loginUser
		let cLatitude = user.lati()
		let cLongitude = user.longi()
		let centerLocation = CLLocation(latitude: cLatitude, longitude: cLongitude)
		let distance:CLLocationDistance = curLoc.distance(from: centerLocation)
		if distance < 500 {
			print("distance <<<<<500")
			return true
		}else{
			self.remindUser(msg: "距中心距离>500米")
			print("distance >>>>>500")
			return false
		}
	}
	
  
  //MARK:- QrInterface
  func onReadQrCode(code: String) {
    if let field = self.scanField{
      field.text = code
    }
  }
  
	//MARK:- CLLocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
		print("locationManager didUpdateLoctaions...")
		if let curLoc = locations.last{
			self.curLocation = curLoc
			let longitude = curLoc.coordinate.longitude
			let latitude = curLoc.coordinate.latitude
			print("current location:longitude\(longitude),latitude\(latitude)")
		}
	}
	
	

  
  //MARK:- field
  //车型
  func showDateTimeSeet() -> Void {
    let now = Date()
    ActionSheetDatePicker.show(withTitle: "选择到仓时间", datePickerMode: UIDatePicker.Mode.dateAndTime, selectedDate: now, doneBlock: {
      [unowned self] (pick, date, origin) in
      print("date = \(String(describing:date))")
      if let dateObj = date as? Date{
        let dateTimeStr = dateObj.dateStringFrom(dateFormat: "yyyy-MM-dd HH:mm:ss")
        self.arriDateTimeField.text = dateTimeStr
      }
      }, cancel: { (picker) in
        
    }, origin: self.view)
  }
  
  
  //MARK:- UITableViewDelegate
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.001
  }
  
  
  //MARK:- request parameter helper
  private func paramsArri()-> [String: String]?{
    var params:[String:String] = [:]
    //    #warning("是否外调加班车参数不需要传递吗？")
    let truckNumTxt = self.carNumField.text
    if let truckNum = truckNumTxt,truckNum.isEmpty==false{
      params["truckNum"] = truckNum
    }else{
      self.remindUser(msg: "请输入车牌")
      return nil
    }
    
    let aheadTxt = self.labelBackField.text
    if let ahead = aheadTxt,ahead.isEmpty==false{
      params["sendsealScanAhead"] = ahead
    }else{
      self.remindUser(msg: "请输入封签号（后）")
      return nil
    }
    
    let frontTxt = self.labelFrontSideField.text
    if let frontNum = frontTxt,frontNum.isEmpty==false{
      params["sendsealScanMittertor"] = frontNum
    }
    
    let backTxt = self.labelBackSideField.text
    if let backDoor = backTxt,backDoor.isEmpty==false{
      params["sendsealScanBackDoor"] = backDoor
    }
    
    let arriDateTime = self.arriDateTimeField.text
    if let dateTimeStr = arriDateTime,dateTimeStr.isEmpty==false{
      params["scanDate"] = dateTimeStr
		}else{
			self.remindUser(msg: "请选择到仓时间")
			return nil
		}

    
    let user = DataManager.shared.loginUser
    params["scanMan"] = user.empName
    params["scanSite"] = user.siteName
    return params
  }
  
  
  //MARK:- request servers
  //车牌查询
  func fetchTruckNums(){
    self.showLoading(msg: "请求车牌数据..")
    let req = TruckNumMDataReq()
    STNetworking<[TruckNumModel]>(stRequest: req) {
      [unowned self] (resp) in
      self.hideLoading()
      if resp.stauts == Status.Success.rawValue{
        let control = TruckNumListController()
        control.selectNumBlock = {
          [unowned self] (model) in
          self.selTruckModel = model
          self.carNumField.text = model.truckNum
          self.navigationController?.popViewController(animated: true)
          self.hasSelectTruckNum(model:model)
          //					self.fetchTrailTruckInfoBy(truckNum: model.truckNum)
        }
        control.truckNumAry = resp.data
        self.navigationController?.pushViewController(control, animated: true)
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
  
  
  //到车信息查询
  func fetchArrivedTruckInfo(params: [String: String]){
    self.showLoading(msg: "请求车牌数据...")
    let req = ArriTruckMDataReq(params:params)
    STNetworking<SendTruckModel>(stRequest: req) {
      [unowned self] (resp) in
      self.hideLoading()
      if resp.stauts == Status.Success.rawValue{
        let carInfo = resp.data
        self.updateSendTruckUIBy(carInfo: carInfo)
        self.sendTruckInfo = carInfo
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
	
	
	///提交到车登记的数据
	func submitArriSign(params: [String: String]){
		self.showLoading(msg: "到车登记...")
		let req = ArriTruckSignReq(params:params)
		STNetworking<RespMsg>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
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
  
  
  
}
