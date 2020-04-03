//  CenSendSignController.swift
//  ST
//
//  Created by taotao on 2019/7/29.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import ActionSheetPicker_3_0
import Alamofire



class CenSendSignController: UITableViewController,QrInterface,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate{
	
  let SectionImgIdx = 1
  let RowImgsIdx = 1
	
  
  //是否外调加班
  @IBOutlet weak var tmpBtn: UIButton!
  
  @IBOutlet var titleLabels: [UILabel]!
  
  @IBOutlet var qrFields: [UITextField]!
  
  @IBOutlet var listFields: [UITextField]!
  
  //车牌
  @IBOutlet weak var carNumField: UITextField!
  //车型
  @IBOutlet weak var carTypeField: UITextField!
  //挂车号
  @IBOutlet weak var carPendNumField: UITextField!
  //路由
  @IBOutlet weak var routeField: UITextField!
  //下一站
  @IBOutlet weak var nextStationField: UITextField!
  ///封签号（后）
  @IBOutlet weak var labelBackField: UITextField!
  ///封签号（前侧）
  @IBOutlet weak var labelFrontSideField: UITextField!
  ///封签号（后侧）
  @IBOutlet weak var labelBackSideField: UITextField!
  //发车时间
  @IBOutlet weak var setOutTimeField: UITextField!
  
  @IBOutlet weak var imgsView: DriVideoView!
	


  let group = DispatchGroup()
	
	
	//装载图片提交服务器返回的地址数组
	var loadImgUrls:Array<String> = []
  var imgesAry:Array<UIImage>?
  var scanField:UITextField?
	
  var selTruckModel:TruckNumModel?
  var selRouteModel:TruckRouteModel?
	///发车信息模型
  var truckInfoModel:SendTruckInfoModel?
  


  //MARK:- overrides
  override func viewDidLoad() {

    self.imgesAry = Array.init()
    self.imgesAry?.append(UIImage(named: "plus")!)

    self.view.addDismissGesture()
    
    for label in self.titleLabels{
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
		
		self.setOutTimeField.addLeftSpaceView(width: 8)
		let nowDate = Date()
		let nowDateStr = nowDate.dateStringFrom(dateFormat: "yyyy-MM-dd HH:mm:ss")
		self.setOutTimeField.text = nowDateStr
		
		
    for field in self.listFields{
      let typeImg = UIImage(named: "arrow");
      let rightViewF = CGRect(x: 0, y: 0, width: 33, height: 33)
      let typeRightVeiw = UIButton.init(frame: rightViewF)
      typeRightVeiw.tag = field.tag
      typeRightVeiw.setImage(typeImg, for: .normal)
      typeRightVeiw.addTarget(self, action: #selector(CenSendSignController.clickFieldMore), for: .touchUpInside)
      field.rightView = typeRightVeiw
      field.rightViewMode = .always
      field.addLeftSpaceView(width: 8)
    }
    
    //图片
    self.imgsView.clickBlock = {
      [unowned self] (idx, itemType) in
      print("imgsView item click")
      if itemType == .addBtn{
        self.clickTakePic(UIButton())
      }else{
        if let imgs = self.imgesAry{
          var imgDataAry = imgs
          imgDataAry.removeLast()
          self.showImgAt(idx:idx,imgs: imgDataAry)
        }
      }
    };
    
    //删除item刷新tableView
    self.imgsView.updateBlock = {
      [unowned self] idx in
      self.imgesAry?.remove(at: idx)
      if let imgs = self.imgesAry{
        self.imgsView.updateUI(imgs:imgs, type: .imgLoc, addAble: true)
      }
      self.tableView.reloadData()
    }
    
    if let imgsAry = self.imgesAry {
      self.imgsView.updateUI(imgs: imgsAry, type: .imgLoc, addAble: true)
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
    // 打开浏览器
    JXPhotoBrowser(dataSource: dataSource).show(pageIndex: idx)
  }
  
  //更新imagesView和TableView cell的高度
  func updateImgViewTable(){
    self.imgsView.updateUI(imgs: self.imgesAry!, type: .imgLoc, addAble: true)
    self.tableView.reloadData()
  }
  
  //MARK:-  selectors
  //确认
  @IBAction func clickConfirmItem(_ sender: Any) {
		
		var paramsSend = self.paramsSend()
		if paramsSend == nil {
			return
		}
		
		let lateRea = self.needLateReason()
		let sealRea = self.needSealDiffReason()
		if lateRea || sealRea{
			let storyboard = UIStoryboard(name: "STCenter", bundle: nil)
			let control = storyboard.instantiateViewController(withIdentifier: "SendSignReasonControl") as! SendSignReasonControl
			control.needLateRea = lateRea
			control.needSealRea = sealRea
			control.submitBlock = {
				[unowned self] (result,params) in
				if result {
					for(key,val) in params{
						paramsSend![key] = val
						print("key:\(key)+value:\(val)")
						if let imgs = self.imgesAry{
							self.submitImgs(imgs: imgs, params: paramsSend!)
						}
					}
				}else{
					print("cancel cancel ....")
				}
				control.dismiss(animated: true, completion: nil)
			}
			
			control.modalPresentationStyle = .fullScreen
			self.navigationController?.present(control, animated: true, completion: {
			})
		}else{
			if let imgs = self.imgesAry{
				self.submitImgs(imgs: imgs, params: paramsSend!)
			}
		}
		
		
  }
	
  
  @IBAction func clickPickerImgs(_ sender: Any) {
    let vc = BSImagePickerViewController()
    bs_presentImagePickerController(vc, animated: true,
                                    select: { (asset: PHAsset) -> Void in
                                      print("select...")
    }, deselect: { (asset: PHAsset) -> Void in
      print("deselect...")
    }, cancel: { (assets: [PHAsset]) -> Void in
      print("cancel...")
    }, finish: { (assets: [PHAsset]) -> Void in
      for asset in assets{
        let img = self.PHAssetToUIImage(asset: asset)
        self.imgesAry?.insert(img, at: 0)
      }
      self.updateImgViewTable()
    }, completion: nil)
  }
  
  
  //拍照
  @IBAction func clickTakePic(_ sender: Any) {
    self.present(self.imgPicker, animated: true) {
    }
  }
  
  
  @IBAction func clickToScan(_ sender: UIButton) {
    for(idx ,obj) in self.qrFields.enumerated(){
      if idx == sender.tag{
        self.scanField = obj
      }
    }
    self.openQrReader()
  }
  
  let CarNumTag = 4,CarTypeTag = 5,PendCarTag = 6,RouteCarTag = 7,NextStationTag = 8
  //field rightview selector
  @objc func clickFieldMore(sender: UIButton) -> Void {
    if sender.tag == CarNumTag {
      self.fetchTruckNums()
    }else if sender.tag == CarTypeTag {
      self.showCarTypeSheet()
    }else if sender.tag == PendCarTag {
    }else if sender.tag == RouteCarTag {
      self.fetchTruckRoutes()
    }else if sender.tag == NextStationTag {
    }else{
    }
  }
  
  //外调加班车
  @IBAction func clickOutCarWork(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
  }
  
  //MARK:- QrInterface
  func onReadQrCode(code: String) {
    if let field = self.scanField{
      field.text = code
    }
  }
  
  //MARK:- update
  //车型sheet
  func showCarTypeSheet() -> Void {
    var typeField:UITextField?
    for field in self.listFields{
      if field.tag == CarTypeTag{
        typeField = field
        break
      }
    }
    
    let rows = ["7.6米","9.6米","半挂"]
    ActionSheetStringPicker.show(withTitle: "车型选择", rows: rows, initialSelection: 0, doneBlock: { [unowned self] (picker, indexex, values) in
      if let typeStr = values as? String{
        typeField!.text = typeStr
				if typeStr != "半挂"{
					if let carNumStr = self.carNumField.text,carNumStr.isEmpty==false{
						self.carPendNumField.text = carNumStr
					}
				}else{
					self.carPendNumField.text = ""
				}
      }
      return
    }, cancel: { picker in
      
    }, origin: self.view)
  }
	
  //选择路由之后计算出下一站
  func nextSiteByRoute(routeModel: TruckRouteModel){
    let user = DataManager.shared.loginUser
		var nextStation:String?
		if user.siteName == routeModel.sendSite{
			nextStation = routeModel.stopSite1
		}else if user.siteName == routeModel.stopSite1{
			nextStation = routeModel.stopSite2
		}else if user.siteName == routeModel.stopSite2{
			nextStation = routeModel.stopSite3
		}else if user.siteName == routeModel.stopSite3{
			nextStation = routeModel.comeSite
		}
		if let nextSite = nextStation,nextSite.isEmpty==false{
			self.nextStationField.text = nextSite
		}else{
			self.nextStationField.text = ""
		}
  }
	
	//显示选择发车时间的sheet精确到秒
	func showTimerPicker(){
		let now = Date()
		ActionSheetDatePicker.show(withTitle: "选择发车时间", datePickerMode: UIDatePicker.Mode.dateAndTime, selectedDate: now, doneBlock: {
			[unowned self] (pick, date, origin) in
			print("date = \(String(describing:date))")
			if let dateObj = date as? Date{
				let dateTimeStr = dateObj.dateStringFrom(dateFormat: "yyyy-MM-dd HH:mm:ss")
				self.setOutTimeField.text = dateTimeStr
			}
		}, cancel: { (picker) in
			
		}, origin: self.view)
	}
	
	///已经获取发车的数据信息，更新界面。
	func updateSendCarUI(){
		if let car = self.truckInfoModel{
			self.carTypeField.text = car.trucktype
		}
	}
	
	
	
  //MARK:-  lazy methods
  lazy var imgPicker:UIImagePickerController = {
    let imgPicker = UIImagePickerController()
    imgPicker.sourceType = .camera
    imgPicker.delegate = self
    imgPicker.cameraFlashMode = UIImagePickerController.CameraFlashMode.off
    return imgPicker
  }()
  
  //MARK:- private
	//根据选择或者输入的车牌号查询挂车历史号
	func fetchTrailTruckInfoBy(truckNum: String){
		let user = DataManager.shared.loginUser
		var params:[String: String] = [:]
		params["siteName"] = user.siteName
		params["truckNum"] = truckNum
		self.fetchTrailTruckDatas(params: params)
	}
	
	//根据选择或者输入的车牌号查询发车的信息
	func fetchSendCarInfoBy(truckNum: String){
		let user = DataManager.shared.loginUser
		var params:[String: String] = [:]
		params["siteName"] = user.siteName
		params["truckNum"] = truckNum
		self.fetchSendTruckInfo(params: params)
	}
	
	//根据选择或者输入的车牌号查询路由数据
	func fetchTruckRouteInfoBy(truckNum: String){
		let user = DataManager.shared.loginUser
		var params:[String: String] = [:]
		params["siteName"] = user.siteName
		params["truckNum"] = truckNum
		self.fetchTrailTruckDatas(params: params)
	}
	
	///是否需要填写超时原因
	func needLateReason()-> Bool{
		let lineNameTxt = self.routeField.text
		if let route = self.selRouteModel,route.lineName == lineNameTxt! {
			//1.检测发车时间是否超过当前时间
			let sendDateStr = route.sendDate
			let currentDate = Date()
			let sendDate = sendDateStr.dateOf()
			if sendDate.isBefore(date: currentDate){
				return true
			}else{
				return false
			}
		}else{
			return false
		}
	}
	
	
	///是否需要填写封签号不一致原因
	func needSealDiffReason()-> Bool{
		if let car = self.truckInfoModel{
			if car.bl_state == "1" {
				return false
			}else{
				let front = self.labelFrontSideField.text
				if car.sendsealScanMittertor != front{
					return true
				}
				let back = self.labelBackField.text
				if back != car.sendsealScanAhead{
					return true
				}
				let backSide = self.labelBackSideField.text
				if backSide != car.sendsealScanBackDoor{
					return true
				}
				return false
			}
		}else{
			return false
		}
	}
	
	
	//MARK:- UITextFieldDelegate
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		if textField.tag == 9{
			self.showTimerPicker()
			return false
		}else{
			return true
		}
	}
	
	
	
	
  //MARK:- UITableViewDelegate
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath.section == SectionImgIdx){
      if (indexPath.row == RowImgsIdx) {
        return DriVideoView.viewHeightBy(itemCount: (self.imgesAry?.count)!)
      }else{
        return 50
      }
    }else{
      return 50
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.001
  }

  
  //MARK:- UIImagePickerControllerDelegate
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true) {
    }
    
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      self.imgesAry?.insert(image, at: 0)
      self.updateImgViewTable()
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.imgPicker.dismiss(animated: true) {
      
    }
  }
  
  
  // MARK: - 将PHAsset对象转为UIImage对象
  func PHAssetToUIImage(asset: PHAsset) -> UIImage {
    var image = UIImage()
    
    // 新建一个默认类型的图像管理器imageManager
    let imageManager = PHImageManager.default()
    
    // 新建一个PHImageRequestOptions对象
    let imageRequestOption = PHImageRequestOptions()
    
    // PHImageRequestOptions是否有效
    imageRequestOption.isSynchronous = true
    
    // 缩略图的压缩模式设置为无
    imageRequestOption.resizeMode = .none
    
    // 缩略图的质量为高质量，不管加载时间花多少
    imageRequestOption.deliveryMode = .highQualityFormat
    
    // 按照PHImageRequestOptions指定的规则取出图片
    imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageRequestOption, resultHandler: {
      (result, _) -> Void in
      image = result!
    })
    return image
  }
	
  
  //MARK:- request helper
  private func paramsSend()-> [String: String]?{
    
    var params:[String:String] = [:]
//		#warning("是否外调加班车参数不需要传递吗？")
		if self.tmpBtn.isSelected{
			params["blTempWork"] = "1"
		}else{
			params["blTempWork"] = "0"
		}
		
    let truckNumTxt = self.carNumField.text
    if let truckNum = truckNumTxt,truckNum.isEmpty==false{
      params["truckNum"] = truckNum
    }else{
      self.remindUser(msg: "请输入车牌")
      return nil
    }
    
    let truckTypeTxt = self.carTypeField.text
    if let truckType = truckTypeTxt,truckType.isEmpty==false{
      params["truckType"] = truckType
    }else{
      self.remindUser(msg: "请输入车型")
      return nil
    }
    
    let truckCarNumTxt = self.carTypeField.text
    if let truckCarNum = truckCarNumTxt,truckCarNum.isEmpty==false{
      params["truckCarNum"] = truckCarNum
    }else{
      self.remindUser(msg: "请输入挂车号")
      return nil
    }
    
    let lineNameTxt = self.routeField.text
    if let lineName = lineNameTxt,lineName.isEmpty==false{
      params["lineName"] = lineName
    }else{
      self.remindUser(msg: "请输入路由")
      return nil
    }
		
    
    let nextSiteTxt = self.nextStationField.text
    if let nextSite = nextSiteTxt,nextSite.isEmpty==false{
      params["nextSite"] = nextSite
    }else{
      self.remindUser(msg: "请输入下一站")
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
		
		let setoutTxt = self.setOutTimeField.text
		if let scanDate = setoutTxt,scanDate.isEmpty==false{
			params["scanDate"] = scanDate
		}
		
		if (self.imgesAry?.count ?? 0) <= 1{
			self.remindUser(msg: "添加装载图片")
			return nil
		}
		
    let user = DataManager.shared.loginUser
    params["scanMan"] = user.empName
    params["scanSite"] = user.siteName
    
    return params
  }
	
	///提交图片、发车数据
	func submitImgs(imgs:Array<UIImage>, params:[String:String]) -> Void {
		self.showLoading(msg: "提交数据中")
		var loadImgs = imgs
		loadImgs.removeLast()
		self.loadImgUrls.removeAll()
		for (idx,img) in loadImgs.enumerated(){
			group.enter()
			let fileName = "load\(idx).jpeg"
			self.submitImgData(pathStr: "SendCar", fileName: fileName, img: img)
		}

		var paramsSub = params
		group.notify(queue: .main) {
			[unowned self] in
			if self.loadImgUrls.count > 0{
				paramsSub["picUrl"] = self.loadImgUrls.joined(separator: ",")
				self.submitSendSignData(params: paramsSub)
			}else{
				self.remindUser(msg: "添加装载图片")
			}
			
		}
	}
	
	
  
  //MARK:- request server
  //车牌查询
  func fetchTruckNums(){
    self.showLoading(msg: "请求车牌数据..")
		let siteName = DataManager.shared.loginUser.siteName
		let req = TruckNumMDataReq(siteName:siteName)
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
					self.fetchTrailTruckInfoBy(truckNum: model.truckNum)
					self.fetchSendCarInfoBy(truckNum: model.truckNum)
					self.labelBackSideField.text = ""
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
	
	
	//路由数据
	func fetchTruckRoutes(){
		self.showLoading(msg: "请求路由数据..")
		let siteName = DataManager.shared.loginUser.siteName
		let req = TruckRouteMDataReq(siteName:siteName)
		STNetworking<[TruckRouteModel]>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				let control = TruckRouteListController()
				control.selectNumBlock = {
					[unowned self] (model) in
					self.nextSiteByRoute(routeModel: model)
          self.selRouteModel = model
					self.routeField.text = model.lineName
					self.navigationController?.popViewController(animated: true)
				}
				control.truckRouteAry = resp.data
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
	
	
	//挂车历史数据
	func fetchTrailTruckDatas(params: [String: String]){
		self.showLoading(msg: "请求挂车数据..")
		let req = TrailTruckDataReq(params: params)
		STNetworking<[TrailTruckModel]>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				if resp.data.count > 0,let recModel = resp.data.first{
					let truckNum = recModel.truckCarNum
					self.carPendNumField.text = truckNum
				}
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
//				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
//				var msg = resp.msg
//				if resp.stauts == Status.PasswordWrong.rawValue{
//					msg = "错误"
//				}
//				self.remindUser(msg: msg)
			}
			}?.resume()
	}
  
	///根据车牌查询发车的信息
		func fetchSendTruckInfo(params: [String: String]){
			self.showLoading(msg: "检测发车信息..")
			let req = SendTruckInfoReq(params: params)
			STNetworking<SendTruckInfoModel>(stRequest: req) {
				[unowned self] (resp) in
				self.hideLoading()
				if resp.stauts == Status.Success.rawValue{
					self.truckInfoModel = resp.data
					self.updateSendCarUI()
				}else if resp.stauts == Status.NetworkTimeout.rawValue{
					self.remindUser(msg: "网络连接超时")
				}else{
					var msg = resp.msg
					if resp.stauts == Status.PasswordWrong.rawValue{
						msg = "错误"
					}
					self.remindUser(msg: msg)
				}
				}?.resume()
		}
	
  //提交已装载情况的图片
	func submitImgData(pathStr: String, fileName: String, img: UIImage) -> Void {
		let reqUrl = URL.init(string: Consts.UploadServer)
		
		guard let url = reqUrl else {
			return
		}
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        //images
				if let imgData = img.jpegData(compressionQuality: 0.5),let pathData = pathStr.data(using: String.Encoding.utf8){
					multipartFormData.append(pathData, withName: "path")
					multipartFormData.append(imgData, withName: "file",fileName: fileName, mimeType: "image/png")
				}
    },
      to: url,
      encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON {
						[unowned self] response in
						self.group.leave()
						if let jsonData = response.result.value as? NSDictionary{
							if let status = jsonData["stauts"] as? Int,status == 4{
								if let picUrl = jsonData["picUrl"] as? String{
									self.loadImgUrls.append(picUrl)
								}
							}
						}
          }
        case .failure(let encodingError):
          print(encodingError)
        }
    }
    )
  }
  
  //提交发车签到数据
  func submitSendSignData(params:[String: String]) -> Void {
    let req = SendCarSignReq(params: params)
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
