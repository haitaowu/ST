//
//  DriDamgeController.swift
//  ST
//
//  Created by taotao on 2019/6/16.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0
import AVKit
import Alamofire




class DriDamgeController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BMKLocationAuthDelegate{
	
	
	
	@IBOutlet weak var fixedTypeField: UITextField!
	@IBOutlet weak var locField: UITextField!
	@IBOutlet weak var durationField: UITextField!
  //
  @IBOutlet weak var realImgsView: DriVideoView!
  @IBOutlet weak var damImgsView: DriVideoView!
	@IBOutlet weak var confirmBtn: UIButton!
	@IBOutlet var asteriskLabels: [UILabel]!
	var locationManager:BMKLocationManager?
	
	@IBOutlet weak var locLabel: UILabel!
  
  //经度
  var longitudeStr:String?
  //纬度
  var latitudeStr:String?
	
	let size = UIScreen.main.bounds.size;
	
  let kSectionRealImg = 0
  let kRowIdxRealImg = 1
	let kSectionDamImg = 2
	let kRowIdxDamImg = 1
	let kConfirmBtnIdx = 4
	
  var realImgesAry:Array<UIImage>?
	var realUrlsAry:Array<String> = []
  var damImgesAry:Array<UIImage>?
	var damUrlsAry:Array<String> = []
  
  //0：代表实时，1：代表损坏
  var cameraType:Int = 0
	let group = DispatchGroup()
  
	// MARK: - Constants
	
	//MARK:- override
	override func viewDidLoad() {
		self.setupMediaViews()
		self.setupUI()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
	
	
	//MARK:- setup UI
	func setupUI() -> Void {
		self.confirmBtn.addCorner(radius: 10)
		self.fixedTypeField.addLeftSpaceView(width: 8)
		self.fixedTypeField.addRightBtn(imgName: "arrow", action: #selector(DriDamgeController.clickFixTypeBtn), target: self)
		
		self.durationField.addLeftSpaceView(width: 8)
		self.durationField.addRightBtn(imgName: "arrow", action: #selector(DriDamgeController.clickDurationBtn), target: self)
		
		self.view.addDismissGesture()
		
		for label in self.asteriskLabels{
			let txt = label.text
			let attriTxt = txt?.attriStr(highlightStr: "*", color: .red)
			label.attributedText = attriTxt
		}
	}
	
	func setupMediaViews() -> Void {
		self.realImgesAry = Array.init()
		self.realImgesAry?.append(UIImage(named: "plus")!)
		
		if let imgsAry = self.realImgesAry {
			self.updateRealViewBy(imgsAry: imgsAry)
		}
		
		//实时拍摄的图片容器初始化
		self.realImgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("damImgsView item click")
			if itemType == .addBtn{
        if let imgs = self.realImgesAry,imgs.count > 4{
          self.remindUser(msg: "实时图片不可以超过三张")
        }else{
          self.cameraType = 0
          self.showTakePhoto()
        }
			}else{
				if let imgs = self.realImgesAry{
					var imgDataAry = imgs
					imgDataAry.removeLast()
					self.showImgAt(idx:idx,imgs: imgDataAry)
				}
			}
		};
		
		//删除图片刷新tableView
		self.realImgsView.updateBlock = {
			[unowned self] idx in
			self.realImgesAry?.remove(at: idx)
			if let imgs = self.realImgesAry{
				self.updateRealViewBy(imgsAry: imgs)
			}
		}
		
		//损坏部分的图片的图片容器初始化
		self.damImgesAry = Array.init()
		self.damImgesAry?.append(UIImage(named: "plus")!)
    
    if let imgsAry = self.realImgesAry {
      self.updateDamgeViewBy(imgsAry: imgsAry)
    }
    
		self.damImgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("damImgsView item click")
			if itemType == .addBtn{
        if let imgs = self.damImgesAry,imgs.count > 4{
          self.remindUser(msg: "损坏图片不可以超过三张")
        }else{
          self.cameraType = 1
          let actionControl = UIAlertController(title: "选择方式", message: nil, preferredStyle: .actionSheet)
          actionControl.addAction(UIAlertAction(title: "相机", style: UIAlertAction.Style.default, handler: {[unowned self] (action) in
            self.showTakePhoto()
          }))
          
          actionControl.addAction(UIAlertAction(title: "媒体库", style: UIAlertAction.Style.default, handler: { [unowned self] (action) in
            self.showPhotoLibs()
          }))
          
          actionControl.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (action) in
            
          }))
          
          self.present(actionControl, animated: true, completion: {
          })
        }
			}else{
				if let imgs = self.damImgesAry{
					var imgDataAry = imgs
					imgDataAry.removeLast()
					self.showImgAt(idx:idx,imgs: imgDataAry)
				}
			}
		};
		
		//删除图片刷新tableView
		self.damImgsView.updateBlock = {
			[unowned self] idx in
			self.damImgesAry?.remove(at: idx)
			if let imgs = self.damImgesAry{
				self.updateDamgeViewBy(imgsAry: imgs)
			}
		}
		
		
	}
	
	
	
  //MARK:- update UI
	//展示图片预览
	func showImgAt(idx:Int, imgs:Array<Any>) -> Void {
		// 数据源
		let dataSource = JXLocalDataSource(numberOfItems: {
			// 共有多少项
			return imgs.count
		}, localImage: { index -> UIImage? in
			// 每一项的图片对象
			return (imgs[index] as! UIImage)
		})
		let indicator = JXDefaultPageControlDelegate()
		let trans = JXPhotoBrowserFadeTransitioning.init()
		// 打开浏览器
		JXPhotoBrowser(dataSource: dataSource, delegate: indicator, transDelegate: trans).show(pageIndex: idx)
		
		//    // 打开浏览器
		//    JXPhotoBrowser(dataSource: dataSource).show(pageIndex: idx)
	}
	
	
	//拍照
	func showTakePhoto() {
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			let imgPicker = UIImagePickerController.init()
			imgPicker.sourceType = .camera
			imgPicker.delegate = self
			imgPicker.cameraFlashMode = .off
			self.present(imgPicker, animated: true) {
			}
		}else{
			print("相机不可用")
		}
	}
	
  //显示媒体库
  func showPhotoLibs(){
    if(UIImagePickerController.isSourceTypeAvailable(.camera)){
      let imgPicker = UIImagePickerController.init()
      imgPicker.sourceType = .photoLibrary
      imgPicker.delegate = self
      self.present(imgPicker, animated: true) {
      }
    }else{
      print("媒体库不可用")
    }
  }
  
	//更新实时拍摄图片容器
	func updateRealViewBy(imgsAry:Array<Any>) -> Void {
		self.realImgsView.updateUI(imgs: imgsAry, type: .imgLoc, addAble: true)
		self.tableView.reloadData()
	}
  
  //更新损坏部分拍照的图片
  func updateDamgeViewBy(imgsAry:Array<Any>) -> Void {
    self.damImgsView.updateUI(imgs: imgsAry, type: .imgLoc, addAble: true)
    self.tableView.reloadData()
  }
	
	//MARK:- 获取经纬度
	func reqCurrentLoc(){
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
	
	//MARK:- UIImagePickerControllerDelegate
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		print("imagePickerControllerDidCancel")
		picker.dismiss(animated: true) {
			
		}
	}
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		print("didFinishPickingMediaWithInfo")
		if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			print("loaded image already")
      if self.cameraType == 0{
        self.realImgesAry?.insert(img, at: 0)
        if let imgsAry = self.realImgesAry{
          self.updateRealViewBy(imgsAry: imgsAry)
        }
      }else{
        self.damImgesAry?.insert(img, at: 0)
        if let imgsAry = self.damImgesAry{
          self.updateDamgeViewBy(imgsAry: imgsAry)
        }
      }
		}
    
		picker.dismiss(animated: true) {
		}
	}
	
	
	//MARK:- selectors
	@IBAction func clickConfirmBtn(_ sender: Any) {
    if let realImgs = self.realImgesAry,realImgs.count > 1{
			self.showLoading(msg: "提交数据中")
			var imgAry = realImgs
			imgAry.removeLast()
			self.realUrlsAry.removeAll()
      for (idx,img) in imgAry.enumerated(){
					let prefixName = Date().dateStringFrom(dateFormat: "yyyyMMddHHmmss")
        let fileName = "\(prefixName)live\(idx).jpeg"
        let imgData = img.jpegData(compressionQuality: 0.5)
        let pathStr = "Damage"
        guard let data = imgData else{return}
        self.group.enter()
        self.submitDamageImg(flag: 0, pathStr: pathStr, fileName: fileName, imgData: data)
      }
    }else{
      self.remindUser(msg: "请添加实时拍摄图片")
      return
    }


    if let damImgs = self.damImgesAry,damImgs.count > 1{
			self.showLoading(msg: "提交数据中")
			var imgAry = damImgs
			imgAry.removeLast()
			self.damUrlsAry.removeAll()
      for (idx,img) in imgAry.enumerated(){
				let prefixName = Date().dateStringFrom(dateFormat: "yyyyMMddHHmmss")
        let fileName = "\(prefixName)damage\(idx).jpeg"
        let imgData = img.jpegData(compressionQuality: 0.5)
        let pathStr = "Damage"
        guard let data = imgData else{return}
        self.group.enter()
        self.submitDamageImg(flag: 1, pathStr: pathStr, fileName: fileName, imgData: data)
      }
    }else{
      self.remindUser(msg: "请添车损部分的图片")
      return
    }
    
    self.group.notify(queue: .main) {
			
      if let params = self.params(){
				self.hideLoading()
        self.submitVanInfo(param: params)
			}
    }
	}
	
	
	//选择维修方式
	@objc func clickFixTypeBtn() -> Void {
		print("clickFixTypeBtn")
		let rows = ["现场维修","拖拽维修"]
		ActionSheetStringPicker.show(withTitle: "维修方式", rows: rows, initialSelection: 0, doneBlock: { [unowned self] (picker, indexex, values) in
			if let durationStr = values as? String{
				self.fixedTypeField.text = durationStr
			}
			return
			}, cancel: { picker in
				
		}, origin: self.view)
	}
	
	
	//选择预计时长
	@objc func clickDurationBtn() -> Void {
		print("clickDurationBtn")
		let rows = ["1小时","2小时","3小时","6小时","12小时","24小时","2天","大于2天"];
		ActionSheetStringPicker.show(withTitle: "预计时长", rows: rows, initialSelection: 0, doneBlock: { [unowned self] (picker, indexex, values) in
			if let durationStr = values as? String{
				self.durationField.text = durationStr
			}
			return
			}, cancel: { picker in
				
		}, origin: self.view)
	}
	
	
	
	//点击定位
	@IBAction func clickLocBtn(_ sender: Any) {
		self.showLoading(msg: "获取经纬度")
		self.reqCurrentLoc()
	}
	
	
	//MARK:- tableView delegate
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == kSectionRealImg{
			if indexPath.row == kRowIdxRealImg{
				return DriVideoView.viewHeightBy(itemCount: (self.realImgesAry?.count)!)
			}else{
				return 44
			}
		}else if indexPath.section == kSectionDamImg{
			if indexPath.row == kRowIdxDamImg{
				return DriVideoView.viewHeightBy(itemCount: (self.damImgesAry?.count)!)
			}else{
				return 44
			}
		}else{
			if indexPath.row == kConfirmBtnIdx{
				return 144
			}else{
				return 44
			}
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
    if self.realUrlsAry.count > 0{
      let imgUrlStr:String = self.realUrlsAry.joined(separator: ",")
      params["liveActionPic"] = imgUrlStr
    }else{
      self.remindUser(msg: "实时图片上传失败")
      return nil
    }
    
//		#warning("临时写死的经纬度数据")
//		params["longtiude"] = "133"
    if let longtiude = self.longitudeStr{
      params["longtiude"] = longtiude
    }else{
      self.remindUser(msg: "请选择经纬度")
      return nil
    }
		
//		params["latitude"] = "253"
    if let latitude = self.latitudeStr{
      params["latitude"] = latitude
    }else{
      self.remindUser(msg: "请选择经纬度")
      return nil
    }
		
    if self.damUrlsAry.count > 0{
      let imgUrlStr = self.damUrlsAry.joined(separator: ",")
      params["damageUrl"] = imgUrlStr
    }else{
      self.remindUser(msg: "车损图片上传失败")
      return nil
    }
    
    let repType = self.fixedTypeField.text
    if let repairType = repType,repairType.isEmpty==false{
      params["repairType"] = repairType
    }else{
      self.remindUser(msg: "请选择经维修方式")
      return nil
    }
    
    let location = self.locField.text
    if let repairAddress = location,repairAddress.isEmpty==false{
      params["repairAddress"] = repairAddress
    }else{
      self.remindUser(msg: "请选维修地点")
      return nil
    }
    
    let duration = self.durationField.text
    if let repairTime = duration,repairTime.isEmpty==false{
      params["repairTime"] = repairTime
    }else{
      self.remindUser(msg: "请选择预计时长")
      return nil
    }
    
    let driver = DataManager.shared.loginDriver
    params["scanMan"] = driver.truckOwer
    params["trucknum"] = driver.truckNum
    
    return params
	}
  
	
  //MARK:- request server
	//提交图片
  func submitDamageImg(flag: Int, pathStr: String, fileName: String, imgData:Data){
    let url = URL.init(string: Consts.UploadServer)
    guard let uploadUrl = url else{return}
    
	Alamofire.upload(multipartFormData: { (multipartFormData) in
		multipartFormData.append(pathStr.data(using: String.Encoding.utf8)!, withName: "path")
		multipartFormData.append(imgData, withName: "file",fileName: fileName, mimeType: "image/png")
	}, to: uploadUrl) { (encodingResult) in
		switch encodingResult{
		case .success(let upload,_,_):do{
			upload.responseJSON{[unowned self]response in
				self.group.leave()
				if let jsonData = response.result.value as? NSDictionary{
					if let url = jsonData["picUrl"] as? String{
						if flag == 0{
							self.realUrlsAry.append(url)
						}else{
							self.damUrlsAry.append(url)
						}
					}
				}
			}
			}
		case .failure(let error):do{
			self.group.leave()
			print("upload image failure....")
			}
		default:print("default")
		}
	}
	
	
	}
	
	
	
	private func submitVanInfo(param:[String:String]) -> Void {
		let req = DamaVanReq(params: param)
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
