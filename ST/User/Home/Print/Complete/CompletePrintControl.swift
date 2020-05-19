//
//  CompletePrintControl.swift
//  ST
//  Created by taotao on 20/03/2018.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire
import ActionSheetPicker_3_0

enum AdrKey: String{
	case town="town",city="city",province="province"
}


class CompletePrintControl:UITableViewController,QrInterface,WangdianPickerInterface {
	let kSectionSend = 1
	let kSectionReceive = 2
	
	//MARK:- IBOutlets
	@IBOutlet var containerViewCollect: [HTDashView]!
	@IBOutlet weak var sendSiteField: UITextField!
	@IBOutlet weak var sendDateField: UITextField!
	@IBOutlet weak var reciverField: UITextField!
	@IBOutlet weak var billNumField: UITextField!
	@IBOutlet weak var fetchBillBtn: UIButton!
	@IBOutlet weak var destAdrField: UITextField!
	
	@IBOutlet weak var goodsNameField: UITextField!
	//超长
	@IBOutlet weak var overLen: UIButton!
	//签收回单
	@IBOutlet weak var signBillBtn: UIButton!
	//回单
	@IBOutlet weak var rebillField: UITextField!
	//超重
	@IBOutlet weak var overWeightBtn: UIButton!
	//进仓件
	@IBOutlet weak var storeBtn: UIButton!
	//进仓编号
	@IBOutlet weak var storeBillField: UITextField!
	//发货
	@IBOutlet weak var sendMsgBtn: UIButton!
	//收货
	@IBOutlet weak var receMsgBtn: UIButton!
	
	//寄件
	//人
	@IBOutlet weak var senderField: UITextField!
	//电话
	@IBOutlet weak var sendPhoneField: UITextField!
	//省
	@IBOutlet weak var sendProvinceBtn: UIButton!
	//市
	@IBOutlet weak var sendCityBtn: UIButton!
	//区
	@IBOutlet weak var sendDistBtn: UIButton!
	//详细地址
	@IBOutlet weak var sendAdrDetail: CustomTextView!
	
	//收件
	//人
	@IBOutlet weak var receiverField1: UITextField!
	//电话
	@IBOutlet weak var recePhoneField: UITextField!
	//省
	@IBOutlet weak var recePronvinBtn: UIButton!
	//市
	@IBOutlet weak var receCityBtn: UIButton!
	//区
	@IBOutlet weak var receDistBtn: UIButton!
	//详细地址
	@IBOutlet weak var receAdrDetail: CustomTextView!
	
	//目的网点所属中心
	@IBOutlet weak var destSiteSupBtn: UIButton!
	//派件网点
	@IBOutlet weak var paiSiteField: UITextField!
	//寄件网点所属中心
	@IBOutlet weak var jiSiteSupBtn: UIButton!
	
	//包装类型
	@IBOutlet weak var packageBtn: UIButton!
	
	//运输方式
	@IBOutlet weak var transportTypeBtn: UIButton!
	
	//送货方式
	@IBOutlet weak var deliverTypeBtn: UIButton!
	
	//实际重量
	@IBOutlet weak var weightField: UITextField!
	
	//结算重量
	@IBOutlet weak var calWeightField: UITextField!
	
	//体积
	@IBOutlet weak var volumeField: UITextField!
	
	//体积重量
	@IBOutlet weak var volumeWeightField: UITextField!
	
	//件数
	@IBOutlet weak var jianShuField: UITextField!
	
	//管理费重量
	@IBOutlet weak var managerFeeField: UITextField!
	//子单号
	@IBOutlet weak var subBillField: UITextField!
	
	//支付类型
	@IBOutlet weak var payTypeField: UITextField!
	
	//到付款
	@IBOutlet weak var payMoneyField: UITextField!
	//运费
	@IBOutlet weak var yunFeiField: UITextField!
	
	//保险费率
	@IBOutlet weak var baoxianLv: UILabel!
	//金额
	@IBOutlet weak var jinE: UILabel!
	//保险费
	@IBOutlet weak var baoxianFei: UILabel!
	//超重件数
	@IBOutlet weak var chaoZhongJianShu: UITextField!
	//超区费用
	@IBOutlet weak var chaoQuFei: UITextField!
	//上楼费
	@IBOutlet weak var shangLouFei: UITextField!
	//送货费
	@IBOutlet weak var songHuoFei: UITextField!
	//其它费用
	@IBOutlet weak var qiTaFei: UITextField!
	
	//当前扫描的UITextField
	var scanField:UITextField?
	
	let billInfo:NSMutableDictionary  = NSMutableDictionary()
	
	var billDetailInfo:Dictionary<String,Any>?
	
	//MARK:- override mothods
	override func viewDidLoad() {
		self.setupUI()
	}
	
	deinit {
		print("deinit....")
		self.billNumField.removeObserver(self, forKeyPath: "text")
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "text" {
			if let newValue = change?[.newKey] as? String{
				let params: Parameters = ["billCode": newValue]
				self.fetchBillDetailInfo(params: params)
			}
		}
	}
	
	//MARK:- private methods
	func setupUI() {
		self.title = "单票录入(全)"
		for  view in self.containerViewCollect {
			view.setupDashLine()
		}
		
		self.billNumField.addObserver(self, forKeyPath: "text", options: [.new,.old], context: nil)
		
		self.sendDateField.text = self.currentDateStr()
		self.sendSiteField.text = DataManager.shared.loginUser.siteName
		fetchBillBtn.addCorner(radius: 5, color: UIColor.red, borderWidth: 1)
		self.tableView.register(MenuRSHeader.headerNib(), forHeaderFooterViewReuseIdentifier: MenuRSHeader.headerID())
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style:.plain, target: self, action: #selector(CompletePrintControl.saveBill))
	}
	
	
	
	
	func currentDateStr() -> String {
		let dateFormat = DateFormatter()
		dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss"
		let dateStr = dateFormat.string(from: Date())
		return dateStr
	}
	
	
	func showSubmitSuccView() -> Void {
		HTAlertViewPrint.ShowAlertViewWith(printBlock: {[unowned self] in
			self.showConnPrinterView()
		}) {
			
		}
	}
	
	func showConnPrinterView() -> Void {
		let connViewControl = PrinterPreviewController(nibName: "PrinterPreviewController", bundle: nil)
		//        connViewControl.billInfo = self.billInfo
		let billCode = self.billNumField.text!
		connViewControl.billSN = billCode
		self.navigationController?.pushViewController(connViewControl, animated: true)
	}
	
	//验证运单号是否正确
	func isValidateBillNum(billNumStr:String) -> Bool {
		let regexStr = "^(((66|77|88|99)[0-9]{7})|((8)[0-9]{12})|((2)[0-9]{10}))$"
		let predicate = NSPredicate(format: "SELF MATCHES %@", regexStr)
		let isValid = predicate.evaluate(with: billNumStr)
		return isValid
	}
	
	//MARK:- updateUI
	func updateUIByBillInfo(detail: Dictionary<String,Any>){
		//收
		if let acceptMan = detail["ACCEPT_MAN"] as? String{
			self.reciverField.text = acceptMan
		}
		if let acptPhone = detail["ACCEPT_MAN_PHONE"] as? String{
			self.recePhoneField.text = acptPhone
		}
		if let acptAdr = detail["ACCEPT_MAN_COMPANY"] as? String{
			self.receAdrDetail.text = acptAdr
		}
		
		//寄
		if let sendMan = detail["SEND_MAN"] as? String{
			self.senderField.text = sendMan
		}
		
		if let sendManPhone = detail["SEND_MAN_PHONE"] as? String{
			self.sendPhoneField.text = sendManPhone
		}
		
		if let sendProvince = detail["PROVINCE"] as? String{
			self.sendProvinceBtn.setTitle(sendProvince, for: .normal)
		}
		
		if let sendCity = detail["CITY"] as? String{
			self.sendCityBtn.setTitle(sendCity, for: .normal)
		}
		
		if let sendDistrict = detail["BOROUGH"] as? String{
			self.sendDistBtn.setTitle(sendDistrict, for: .normal)
		}
		
		if let sendAdr = detail["SEND_MAN_ADDRESS"] as? String{
			self.sendAdrDetail.text = sendAdr
		}
		
		if let payType = detail["PAYMENT_TYPE"] as? String{
			self.payTypeField.text = payType
		}
		
		if let goodsName = detail["GOODS_NAME"] as? String{
			self.goodsNameField.text = goodsName
		}
		
		if let deliveryType = detail["DISPATCH_MODE"] as? String{
			self.deliverTypeBtn.setTitle(deliveryType, for: .normal)
		}
		
		if let weight = detail["SETTLEMENT_WEIGHT"] as? String{
			self.calWeightField.text = weight
		}
		
		if let isOverLen = detail["BL_OVER_LONG"] as? Int{
			if isOverLen == 1{
				self.overLen.isSelected = true
			}
		}
		
		if let isOverWeight = detail["BL_OVER_WEIGHT"] as? Int{
			if isOverWeight == 1{
				self.overWeightBtn.isSelected = true
				
			}
		}
		
		if let overWeightPiece = detail["OVER_WEIGHT_PIECE"] as? String{
			self.chaoZhongJianShu.text = overWeightPiece
		}
		
		if let isStore = detail["BL_INTO_WAREHOUSE"] as? Int{
			if isStore == 1{
				self.storeBtn.isSelected = true
			}
		}
		
		if let storeNum = detail["STORAGENO"] as? String{
			self.storeBillField.text = storeNum
		}
		
		if let chaoquFei = detail["OVER_AREA_FEE"] as? String{
			self.chaoQuFei.text = chaoquFei
		}
		
		if let shanglouFei = detail["UPSTAIRS_FEE"] as? String{
			self.shangLouFei.text = shanglouFei
		}
		
	}
	
	//show transports types action sheetpicker
	func showTranTypeSheet(types: Array<Dictionary<String,Any>>){
		var typeAry: [String] = []
		for type in types{
			let name = type["className"] as? String ?? ""
			typeAry.append(name)
		}
		
		ActionSheetStringPicker.show(withTitle: "", rows: typeAry, initialSelection: 0, doneBlock: { [unowned self](picker, index, val) in
			if let title = val as? String{
				self.transportTypeBtn.setTitle(title, for: .normal)
			}
			}, cancel: { (picker) in
		}, origin: self.view)
	}
	
	//show devliver types action sheetpicker
	func showDeliverTypeSheet(types: Array<Dictionary<String,Any>>){
		var typeAry: [String] = []
		for type in types{
			let name = type["dispatchCame"] as? String ?? ""
			typeAry.append(name)
		}
		
		ActionSheetStringPicker.show(withTitle: "", rows: typeAry, initialSelection: 0, doneBlock: { [unowned self](picker, index, val) in
			if let title = val as? String{
				self.deliverTypeBtn.setTitle(title, for: .normal)
			}
			}, cancel: { (picker) in
		}, origin: self.view)
	}
	
	//show province city town action sheet picker
	func showAdrActSheet(key: String, adrs: Array<Dictionary<String,Any>>, view: UIButton){
		var adrAry: [String] = []
		for adr in adrs{
			let name = adr[key] as? String ?? ""
			adrAry.append(name)
		}
		
		ActionSheetStringPicker.show(withTitle: "", rows: adrAry, initialSelection: 0, doneBlock: { [unowned self](picker, index, val) in
			if let title = val as? String{
				view.setTitle(title, for: .normal)
			}
			}, cancel: { (picker) in
		}, origin: self.view)
	}
	
	
	//MARK:- selectors
	@IBAction func tapSubmitBtn(_ sender: Any) {
		//        self.showSubmitSuccView()
		//        return
		
		var Rec: Parameters = [:]
		let registerDate = self.sendDateField.text!
		if registerDate.isEmpty{
			self.remindUser(msg: "请选择日期")
			return
		}else{
			Rec["registerDate"] = registerDate
			billInfo["registerDate"] = registerDate
		}
		
		let SITE_NAME = self.sendSiteField.text!
		if SITE_NAME.isEmpty{
			self.remindUser(msg: "请选择网点名称")
			return
		}else{
			Rec["sendSite"] = SITE_NAME
			billInfo["sendSite"] = SITE_NAME
		}
		
		let billCode = self.billNumField.text!
		if billCode.isEmpty{
			self.remindUser(msg: "请输入运单号")
			return
		}else{
			let isValidate = self.isValidateBillNum(billNumStr: billCode)
			if isValidate == true {
				Rec["billCode"] = billCode
				billInfo["billCode"] = billCode
			}else{
				self.remindUser(msg: "运单号格式不正确")
				return
			}
		}
		
		//        let acceptManAddress = self.receSiteTxtView.text!
		//        if acceptManAddress.isEmpty{
		//            self.remindUser(msg: "请输入收件地址")
		//            return
		//        }else{
		//            Rec["acceptManAddress"] = acceptManAddress
		//            billInfo["acceptManAddress"] = acceptManAddress
		//        }
		
		let arriveSite = self.destAdrField.text!
		if arriveSite.isEmpty{
			self.remindUser(msg: "请输入目的网点")
			return
		}else{
			Rec["arriveSite"] = arriveSite
			billInfo["arriveSite"] = arriveSite
		}
		
		//        let sendgoodsType = self.expressBtn.title(for: .normal)!
		//        if sendgoodsType.isEmpty{
		//            self.remindUser(msg: "请选择送货方式")
		//            return
		//        }else{
		//            Rec["sendgoodsType"] = sendgoodsType
		//        }
		
		let goodsName = self.goodsNameField.text!
		if goodsName.isEmpty{
			self.remindUser(msg: "请输入物品名称")
			return
		}else{
			Rec["goodsName"] = goodsName
			billInfo["goodsName"] = goodsName
		}
		//
		//    let weight = self.weightField.text!
		//    if weight.isEmpty{
		//      self.remindUser(msg: "请输入实际重量")
		//      return
		//    }else{
		//      Rec["weight"] = weight
		//      billInfo["weight"] = weight
		//    }
		//
		//    let pieceNumber = self.countField.text!
		//    if pieceNumber.isEmpty{
		//      self.remindUser(msg: "请输入件数")
		//      return
		//    }else{
		//      Rec["pieceNumber"] = pieceNumber
		//      billInfo["pieceNumber"] = pieceNumber
		//    }
		
		var params: Parameters = [:]
		do{
			let recData = try JSONSerialization.data(withJSONObject: [Rec], options: .prettyPrinted)
			let recStr = String.init(data: recData, encoding: .utf8)
			if recStr != nil{
				params["rec"] = recStr
			}
		}catch{
		}
		
		self.submitBillInfoWith(params: params)
	}
	
	@IBAction func tapExpressBtn(_ sender: Any) {
		let array = ["派送","自提"]
		self.view.endEditing(true)
		HTAlertConfirmView .ShowAlertViewWithTitles(titles: array) {[unowned self] (title:String) ->Void in
			print("hello baby \(title)")
			//            self.expressBtn.setTitle(title, for: .normal)
		}
	}
	
	@IBAction func wangdianBtnClicked(_ sender: Any) {
		self.showWangdianPicker()
	}
	
	@IBAction func scanBtnClicked(_ sender: UIButton) {
		if(sender.tag == 0){
			self.scanField = self.billNumField
		}else{
			self.scanField = self.rebillField
		}
		self.openQrReader()
	}
	
	@IBAction func fetchBill(){
		print("获取单号。。。")
		self.fetchBillNum()
	}
	
	//寄件人省
	@IBAction func sendProvince(_ sender: UIButton) {
		print("寄件人省")
		self.fetchAddressInfo(params: nil, view: sender, key: AdrKey.province.rawValue)
	}
	
	//寄件人市
	@IBAction func sendCity(_ sender: UIButton) {
		print("寄件人市")
		var params:Parameters = [:]
		guard let province = self.sendProvinceBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择寄件省")
			return
		}
		params[AdrKey.province.rawValue] = province
		self.fetchAddressInfo(params: params, view: sender, key: AdrKey.city.rawValue)
	}
	
	//寄件人区
	@IBAction func sendDistrict(_ sender: UIButton) {
		var params:Parameters = [:]
		guard let province = self.sendProvinceBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择寄件省")
			return
		}
		params[AdrKey.province.rawValue] = province
		guard let city = self.sendCityBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择寄件市")
			return
		}
		params[AdrKey.city.rawValue] = city
		self.fetchAddressInfo(params: params, view: sender, key: AdrKey.town.rawValue)
	}
	
	//收件人省
	@IBAction func receiveProvince(_ sender: UIButton) {
		self.fetchAddressInfo(params: nil, view: sender, key: AdrKey.province.rawValue)
	}
	
	//收件人市
	@IBAction func receiveCity(_ sender: UIButton) {
		var params:Parameters = [:]
		guard let province = self.recePronvinBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择收件省")
			return
		}
		params[AdrKey.province.rawValue] = province
		self.fetchAddressInfo(params: params, view: sender, key: AdrKey.city.rawValue)
	}
	
	//收件人区
	@IBAction func receiveDistrict(_ sender: UIButton) {
		var params:Parameters = [:]
		guard let province = self.recePronvinBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择收件省")
			return
		}
		params[AdrKey.province.rawValue] = province
		guard let city = self.receCityBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择收件市")
			return
		}
		params[AdrKey.city.rawValue] = city
		self.fetchAddressInfo(params: params, view: sender, key: AdrKey.town.rawValue)
	}
	
	
	//超长、签收回单、超重、进仓件、发货、收货
	@IBAction func checkBoxs(sender: UIButton){
		print("获取单号。。。")
		sender.isSelected = !sender.isSelected
	}
	
	//保存
	@objc func saveBill(){
		print("click right bar item save ....")
		self.billNumField.text =  "232323232"
	}
	
	//目的网点所属中心
	@IBAction func destSite(_ sender: UIButton) {
		print("目的网点所属中心")
	}
	
	//寄件网点所属中心
	@IBAction func sendSite(_ sender: UIButton) {
		let siteName = DataManager.shared.loginUser.siteName
		let params:Parameters = ["siteName":siteName]
		self.fetchSiteSuperName(params: params)
	}
	
	
	//包装类型
	@IBAction func packageType(_ sender: UIButton) {
		let types = ["箱装","袋装","托盘","散装","裸装","桶装","罐装","盘卷包装"]
		ActionSheetStringPicker.show(withTitle: "包装类型", rows: types, initialSelection: 0, doneBlock: {
			[unowned self] (picker, index, vals) in
			if let typeStr = vals as? String{
				self.packageBtn.setTitle(typeStr, for: .normal)
			}
			}, cancel: {(picker) in
		}, origin: self.view)
	}
	
	
	//express type selector
	@IBAction func transportType(_ sender: UIButton) {
		self.fetchTransportType()
	}
	
	//devliver type selector
	@IBAction func deliverType(_ sender: UIButton) {
		self.fetchDeliverType()
	}
	
	
	
	//MARK:- WangdianPickerInterface
	func onWangdianPicked(item:SiteInfo){
		self.destAdrField.text = item.siteName
	}
	
	
	//MARK:- 二维码扫描
	func onReadQrCode(code: String) {
		if let field = self.scanField{
			field.text = code
		}
	}
	
	//MARK:- UITableView dataSource
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = UIColor.clear
		return cell
	}
	
	//MARK:- UITableView delegate
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if ((section == 1)||(section == 2)){
			return 40
		}else{
			return 0.001
		}
	}
	
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if ((section == kSectionSend)||(section == kSectionReceive)){
			let header:MenuRSHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: MenuRSHeader.headerID()) as! MenuRSHeader
			let title:String = section == kSectionSend ? "寄件信息":"收件信息"
			header.updateBy(title: title)
			return header
		}else{
			return nil
		}
	}
	
	
	
	//MARK:- UIScrollView delegate
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.view.endEditing(true)
	}
	
	
	
	//MARK:- request server
	//提交录单数据
	func submitBillInfoWith(params:Parameters) {
		self.showLoading(msg: "提交保单中...")
		let reqUrl = Consts.Server + Consts.BaseUrl + "m8/uploadPrintBillSubNew.do"
		STHelper.POST(url: reqUrl, params: nil) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let dataAry = data as? NSArray{
					if let billData = dataAry.firstObject as? NSDictionary{
						let transferCenter = billData["transferCenter"]
						print("transferCenter = \(String(describing: transferCenter))")
						self.billInfo["transferCenter"] = billData["transferCenter"]
						self.showSubmitSuccView()
					}
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	//app获取电子面单接口
	func fetchBillNum(){
		self.showLoading(msg: "查询中...")
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/getElectronic.do"
		let reqUrl = "http://58.215.182.252:8119/AndroidServiceST-M8/m8/getElectronic.do"
		STHelper.POST(url: reqUrl, params: nil) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let billCode = data as? String{
					self.billNumField.text = billCode
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	
	//查询运单信息
	func fetchBillDetailInfo(params: Parameters){
		//		billCode
		self.showLoading(msg: "查询中运单信息...")
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/getbillData.do"
		let reqUrl = "http://58.215.182.252:8119/AndroidServiceST-M8/m8/getbillData.do"
		STHelper.POST(url: reqUrl, params: params) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let billInfo = data as? Dictionary<String,Any>{
					self.billDetailInfo = billInfo
					self.updateUIByBillInfo(detail: billInfo)
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	
	//查询运输方式
	func fetchTransportType(){
		self.showLoading(msg: "查询运输类型...")
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/getClasses.do"
		let reqUrl = "http://58.215.182.252:8119/AndroidServiceST-M8/m8/getClasses.do"
		
		STHelper.POST(url: reqUrl, params: nil) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let dataAry = data as? Array<Dictionary<String,Any>>{
					self.showTranTypeSheet(types: dataAry)
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	//查询派送方式
	func fetchDeliverType(){
		self.showLoading(msg: "查询派送...")
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/gettabDispatchMode.do"
		let reqUrl = "http://58.215.182.252:8119/AndroidServiceST-M8/m8/gettabDispatchMode.do"
		
		STHelper.POST(url: reqUrl, params: nil) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let dataAry = data as? Array<Dictionary<String,Any>>{
					self.showDeliverTypeSheet(types: dataAry)
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	
	//query jijian province city district
	func fetchAddressInfo(params: Parameters?, view: UIButton, key: String){
		self.showLoading(msg: "...")
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/getProvinceCityTown.do"
		let reqUrl="http://58.215.182.252:8119/AndroidServiceST-M8/m8/getProvinceCityTown.do"
		
		STHelper.POST(url: reqUrl, params: params) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let dataAry = data as? Array<Dictionary<String,Any>>{
					self.showAdrActSheet(key: key, adrs: dataAry, view: view)
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	
	//查询寄件网点所属分拨中心
	func fetchSiteSuperName(params: Parameters){
		self.showLoading(msg: "查询...")
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/gettabDispatchMode.do"
		let reqUrl = "http://58.215.182.252:8119/AndroidServiceST-M8/m8/qryFbCenter.do"
		
		STHelper.POST(url: reqUrl, params: params) {
			[unowned self](result, data) in
			self.hideLoading()
			if (result == .reqSucc) {
				if let siteName = data as? String{
					self.jiSiteSupBtn.setTitle(siteName, for: .normal)
				}
			}else{
				guard let msg = data as? String else {
					return
				}
				self.remindUser(msg: msg)
			}
		}
	}
	
	
	
	
	
	
	
	
	
	
	
}
