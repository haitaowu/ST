//
//  DriHeavyController.swift
//  ST
//
//  Created by taotao on 2019/6/16.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation
import Alamofire




class DriHeavyController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BMKLocationAuthDelegate{
	
	
	
	@IBOutlet weak var reasonField: UITextField!
	@IBOutlet weak var realImgsView: DriVideoView!
	@IBOutlet weak var navImgsView: DriVideoView!
	@IBOutlet weak var confirmBtn: UIButton!
	@IBOutlet weak var choseBtn: UIButton!
	@IBOutlet var asteriskLabels: [UILabel]!
	
	@IBOutlet weak var locLabel: UILabel!
	var locationManager:BMKLocationManager?
	
	
	let size = UIScreen.main.bounds.size;
	
	//0：代表实时，1：代表导航
	var cameraType:Int = 0
	
	let kSectionRealImg = 0
	let kSectionNavImg = 2
	let kRowIdxNavImg = 1
	
	let kConfirmBtnRowIdx = 2
	
	var realImgAry:Array<UIImage>?
	var realImgUrlAry:Array<String> = []
	
	var navImgAry:Array<UIImage>?
	var navImgUrlAry:Array<String> = []
	
	//经度
	var longitudeStr:String?
	//纬度
	var latitudeStr:String?
	let group = DispatchGroup()
	
	//MARK:- public
	
	//MARK:- override
	override func viewDidLoad() {
		self.setupMediaViews()
		self.setupUI()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "playerSegue"{
		}
	}
	
	//MARK:- setup view
	func setupUI() -> Void {
		self.view.addDismissGesture()
		self.reasonField.addLeftSpaceView(width: 8)
		self.confirmBtn.addCorner(radius: 10)
		self.choseBtn.addCorner(radius: 0, color: UIColor.black, borderWidth: 1)
		
		for label in self.asteriskLabels{
			let txt = label.text
			let attriTxt = txt?.attriStr(highlightStr: "*", color: .red)
			label.attributedText = attriTxt
		}
		
	}
	
	
	
	//MARK:- update UI
	func setupMediaViews() -> Void {
		self.navImgAry = Array.init()
		self.realImgAry = Array.init()
		//    self.imgesAry?.append(UIImage(named: "plus")!)
		
		
		//导航图片容器
		self.navImgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("navImgsView item click")
			if itemType == .addBtn{
			}else{
				if let imgs = self.navImgAry{
					let imgDataAry = imgs
					self.showImgAt(idx:idx,imgs: imgDataAry)
				}
			}
		};
		
		//删除导航图片容器图片刷新tableView
		self.navImgsView.updateBlock = {
			[unowned self] idx in
			self.navImgAry?.remove(at: idx)
			if let imgs = self.navImgAry{
				self.updateNavImgsContainerBy(imgAry: imgs)
			}
		}
		
		//实时拍摄图片容器
		self.realImgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("navImgsView item click")
			if itemType == .addBtn{
			}else{
				if let imgs = self.realImgAry{
					let imgDataAry = imgs
					self.showImgAt(idx:idx,imgs: imgDataAry)
				}
			}
		};
		
		//删除实时拍摄图片容器中图片刷新tableView
		self.realImgsView.updateBlock = {
			[unowned self] idx in
			self.realImgAry?.remove(at: idx)
			if let imgs = self.realImgAry{
				self.updateRealImgsContainerBy(imgAry: imgs)
			}
		}
		
	}
	
	
	//展示图片预览
	func showImgAt(idx:Int, imgs:Array<Any>) -> Void {
		// 数据源
		let dataSource = JXLocalDataSource(numberOfItems: {
			// 共有多少项
			return imgs.count
		}, localImage: { index -> UIImage? in
			// 每一项的图片对象
			return imgs[index] as? UIImage
		})
		let indicator = JXDefaultPageControlDelegate()
		let trans = JXPhotoBrowserFadeTransitioning.init()
		// 打开浏览器
		JXPhotoBrowser(dataSource: dataSource, delegate: indicator, transDelegate: trans).show(pageIndex: idx)
		// 打开浏览器
		//    JXPhotoBrowser(dataSource: dataSource).show(pageIndex: idx)
	}
	
	
	//更新实时拍摄view的尺寸
	func updateRealImgsContainerBy(imgAry:Array<UIImage>) -> Void {
		self.realImgsView.updateUI(imgs: imgAry, type: .imgLoc, addAble: false)
		self.tableView.reloadData()
	}
	
	//更新导航图片容器view的尺寸
	func updateNavImgsContainerBy(imgAry:Array<UIImage>) -> Void {
		self.navImgsView.updateUI(imgs: imgAry, type: .imgLoc, addAble: false)
		self.tableView.reloadData()
	}
	
	//显示相机
	func showCamera() -> Void {
		let pickerControl = UIImagePickerController.init()
		pickerControl.sourceType = .camera
		pickerControl.delegate = self
		pickerControl.cameraFlashMode = .off
		self.present(pickerControl, animated: true) {
		}
	}
	
	//显示媒体库
	func showPhotoLibs() -> Void {
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			let pickerControl = UIImagePickerController.init()
			pickerControl.sourceType = .photoLibrary
			pickerControl.delegate = self
			self.cameraType = 1
			self.present(pickerControl, animated: true) {
			}
		}else{
			print("媒体库不可用>>>")
		}
	}
	
	
	//MARK:- selectors
	@IBAction func clickConfirmBtn(_ sender: Any) {
		if let imgAry = self.realImgAry,imgAry.count > 0{
			self.showLoading(msg: "提交数据中...")
			self.realImgUrlAry.removeAll()
			for (idx,img) in imgAry.enumerated(){
				if let imgData = img.jpegData(compressionQuality: 0.5){
					group.enter()
					let fileName = "real\(idx).jpeg"
					self.submitImgData(flag: 0, pathStr: "Jar",fileName: fileName, imgData: imgData)
				}
			}
		}else{
			self.remindUser(msg: "请选择实拍图片")
			return
		}
		
		if let imgAry = self.navImgAry,imgAry.count > 0{
			self.navImgUrlAry.removeAll()
			for (idx,img) in imgAry.enumerated(){
				if let imgData = img.jpegData(compressionQuality: 0.5){
					group.enter()
					let fileName =  "nav\(idx).jpeg"
					self.submitImgData(flag: 1, pathStr: "Jar",fileName: fileName, imgData: imgData)
				}
			}
		}else{
			self.remindUser(msg: "请选择导航图片")
			return
		}
		//		return
		group.notify(queue: .main, execute: {
			guard self.navImgUrlAry.count > 0 else{return}
			
			if let params = self.params(){
				self.submitTrafficInfo(params: params)
			}
		})
		
	}
	
	
	//点击定位
	@IBAction func clickLocBtn(_ sender: Any) {
		print("clickLocation ...")
		self.showLoading(msg: "获取经纬度")
		self.updateCurrentLoc()
	}
	
	
	//选择导航图片
	@IBAction func clickPickerImgsBtn(_ sender: Any) {
		if let imgAry = self.navImgAry,imgAry.count >= 1{
			self.remindUser(msg: "实时图片最多选择1张")
			return;
		}
		
		let actionSheet = UIAlertController(title: "选择方式", message: nil, preferredStyle: .actionSheet)
		
		actionSheet.addAction(UIAlertAction(title: "相机", style: UIAlertAction.Style.default, handler: { [unowned self] (action) in
			if(UIImagePickerController.isSourceTypeAvailable(.camera)){
				self.cameraType = 1
				self.showCamera()
			}else{
				print("相机不可用>>>")
			}
		}))
		
		actionSheet.addAction(UIAlertAction(title: "媒体库", style: UIAlertAction.Style.default, handler: {[unowned self] (action) in
			self.showPhotoLibs()
		}))
		
		actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (action) in
			
		}))
		
		self.present(actionSheet, animated: true) {
			
		}
	}
	
	
	//选择实时图片
	@IBAction func clickToPickImg(_ sender: UIButton) {
		if let imgAry = self.realImgAry,imgAry.count >= 3{
			self.remindUser(msg: "实时图片最多选择3张")
			return;
		}
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			self.cameraType = 0
			self.showCamera()
		}else{
			print("相机不可用>>>")
		}
	}
	
	
	//MARK:- 获取经纬度
	func updateCurrentLoc(){
		BMKLocationAuth.sharedInstance()?.checkPermision(withKey: Consts.BDNaviAK, authDelegate: self)
		if(self.locationManager == nil){
			self.locationManager = BMKLocationManager.init()
			if let locManager = self.locationManager{
				locManager.coordinateType = BMKLocationCoordinateType.BMK09LL
				locManager.desiredAccuracy = kCLLocationAccuracyBest
				//设置是否自动停止位置更新
				locManager.pausesLocationUpdatesAutomatically = false
			}
		}
		
		if let locManager = self.locationManager{
			locManager.requestLocation(withReGeocode: true, withNetworkState: true) { [unowned self] (location, state, error) in
				self.hideLoading()
				if (error != nil){
					//						 print(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
					print("error>>>>>>>>>>>>>")
				}
				if let loc = location{//得到定位信息，添加annotation
					if let longitude = loc.location?.coordinate.longitude,let latitude = loc.location?.coordinate.latitude{
						self.latitudeStr = String(latitude)
						self.longitudeStr = String(longitude)
						let longi = String(format: "%.2f", longitude)
						let lat = String(format: "%.2f", latitude)
						let string = "坐标：(\(longi),\(lat))"
						self.locLabel.text = string
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
	

	//MARK:- UIImagePickerControllerDelegate,UINavigationControllerDelegate
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true) {
		}
	}
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			print("loaded image already")
			if self.cameraType == 1{
				self.navImgAry?.insert(img, at: 0)
				if let imgsAry = self.navImgAry{
					self.updateNavImgsContainerBy(imgAry: imgsAry)
				}
			}else{
				self.realImgAry?.insert(img, at: 0)
				if let imgsAry = self.realImgAry{
					self.updateRealImgsContainerBy(imgAry: imgsAry)
				}
			}
		}
		
		picker.dismiss(animated: true) {
		}
		
	}
	
	//MARK:- tableView delegate
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == kSectionNavImg{
			if indexPath.row == kRowIdxNavImg{
				return DriVideoView.viewHeightBy(itemCount: (self.navImgAry?.count)!)
			}else  if indexPath.row == kConfirmBtnRowIdx{
				return 144
			}else{
				return 44
			}
		}else if indexPath.section == kSectionRealImg{
			if indexPath.row == 1{
				return DriVideoView.viewHeightBy(itemCount: (self.realImgAry?.count)!)
			}else{
				return 44
			}
		}else{
			return 44
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 10
	}
	
	//MARK:- request parameter helper
	private func params()-> [String: String]?{
		
		var params:[String:String] = [:]
		let reasonTxt = self.reasonField.text
		if let trafficJamReason = reasonTxt,trafficJamReason.isEmpty==false{
			params["trafficJamReason"] = trafficJamReason
		}else{
			self.remindUser(msg: "请输入原因")
			return nil
		}
		
//		#warning("临时写死的经纬度数据")
		//		params["longtiude"] = "133"
//		params["latitude"] = "253"
		
		if let longtiude = self.longitudeStr{
			params["longtiude"] = longtiude
		}else{
			self.remindUser(msg: "请选择经纬度")
			return nil
		}

		if let latitude = self.latitudeStr{
			params["latitude"] = latitude
		}else{
			self.remindUser(msg: "请选择经纬度")
			return nil
		}
		
		if self.navImgUrlAry.count > 0{
			let imgUrlStr = self.navImgUrlAry.joined(separator: ",")
			params["navigationUrl"] = imgUrlStr
		}else{
			self.remindUser(msg: "导航图片上传失败")
			return nil
		}
		
		
		if self.realImgUrlAry.count > 0{
			let imgUrlStr:String = self.realImgUrlAry.joined(separator: ",")
			params["jamPic"] = imgUrlStr
		}else{
			self.remindUser(msg: "实时图片上传失败")
			return nil
		}
		
		
		
		
		let driver = DataManager.shared.loginDriver
		params["scanMan"] = driver.truckOwer
		params["trucknum"] = driver.truckNum
		
		return params
	}
	
	
	
	//MARK:- request server
	private func submitImgData(flag: Int, pathStr:String, fileName: String, imgData:Data){
		
		let reqUrl = URL.init(string: Consts.UploadServer)
		guard let url = reqUrl else {
			return
		}
		Alamofire.upload(multipartFormData: {(multipart) in
			multipart.append(pathStr.data(using: String.Encoding.utf8)!, withName: "path")
			multipart.append(imgData, withName: "file",fileName: fileName ,mimeType: "image/png")
		}, to: url) { [unowned self] (encodingResult) in
			switch encodingResult{
			case .success(let upload, _, _):do{
				upload.responseJSON { response in
					if let jsonData = response.result.value as? NSDictionary{
						self.group.leave()
						print("jsonData:\(jsonData)")
						if let url = jsonData["picUrl"] as? String{
							if flag == 0{
								self.realImgUrlAry.append(url)
							}else{
								self.navImgUrlAry.append(url)
							}
						}
					}
				}
				}
			case .failure(let encodingError):do{
				self.group.leave()
				print("failure...")
				}
			default:print("default....")
				
			}
		}
	}
	
	
	private func submitTrafficInfo(params:[String: String]) -> Void {
		let req = HeavyReq(params: params)
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
	
}

