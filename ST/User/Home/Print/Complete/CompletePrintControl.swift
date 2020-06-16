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
	case town="townName",city="city",province="province"
}


class CompletePrintControl:UITableViewController,QrInterface,WangdianPickerInterface,UITextFieldDelegate {
	let kSectionSend = 1
	let kSectionReceive = 2
	
	//MARK:- IBOutlets
	@IBOutlet var containerViewCollect: [HTDashView]!
	@IBOutlet weak var sendSiteField: UITextField!
	@IBOutlet weak var sendDateField: UITextField!
	@IBOutlet weak var reciverField: UITextField!
	@IBOutlet weak var billNumField: UITextField!
	@IBOutlet weak var fetchBillBtn: UIButton!
	@IBOutlet weak var destSiteField: UITextField!
	
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
	@IBOutlet weak var jinE: UITextField!
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
		self.removeObserver(self, forKeyPath: "destSiteField.text")
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "destSiteField.text" {
			print("observer for destSiteField.text")
			if let newValue = change?[.newKey] as? String{
				self.fetchSiteSuperName(siteName: newValue, view: self.destSiteSupBtn)
			}
		}
	}
	
	
	//base setup for ui
	func setupUI() {
		self.title = "单票录入(全)"
		for  view in self.containerViewCollect {
			view.setupDashLine()
		}
		
		
		self.addObserver(self, forKeyPath: "destSiteField.text", options: [.new,.old], context: nil)
		
		self.sendDateField.text = Date().dateStringFrom(dateFormat: "yyyy-MM-dd hh:mm:ss")
		self.sendSiteField.text = DataManager.shared.loginUser.siteName
		fetchBillBtn.addCorner(radius: 5, color: UIColor.red, borderWidth: 1)
		self.tableView.register(MenuRSHeader.headerNib(), forHeaderFooterViewReuseIdentifier: MenuRSHeader.headerID())
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style:.plain, target: self, action: #selector(CompletePrintControl.saveBill))
		
		self.weightField.delegate = self
		self.volumeField.delegate = self
	}

	
	func showSubmitSuccView() -> Void {
		HTAlertViewPrint.ShowAlertViewWith(printBlock: {[unowned self] in
			self.showConnPrinterView()
		}) {
			
		}
	}
	
	func showConnPrinterView() -> Void {
		let connViewControl = PrinterPreviewController(nibName: "PrinterPreviewController", bundle: nil)
		let billCode = self.billNumField.text!
		connViewControl.billSN = billCode
		self.navigationController?.pushViewController(connViewControl, animated: true)
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
//	func showTranTypeSheet(types: Array<Dictionary<String,Any>>){
	func showTranTypeSheet(types: [TransportType]){
		var typeAry: [String] = []
		for type in types{
//			let name = type["className"] as? String ?? ""
			let name = type.className
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
	func showDeliverTypeSheet(types: [ExpressTypeModel]){
		var typeAry: [String] = []
		for type in types{
			let name = type.dispatchName
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
//	func showAdrActSheet(key: String, adrs: Array<Dictionary<String,Any>>, view: UIButton){
	func showAdrActSheet(key: AdrKey, adrs: [AdrModel], view: UIButton){
		guard adrs.count > 0 else{
			self.remindUser(msg: "未查询到城市信息")
			return
		}
		var adrAry: [String] = []
		for adr in adrs{
			let name = adr[key]
			adrAry.append(name)
		}
		
		
		ActionSheetStringPicker.show(withTitle: "", rows: adrAry, initialSelection: 0, doneBlock: {
			[unowned self](picker, index, val) in
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
			if billCode.isValidateBillNum(){
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
		
		let arriveSite = self.destSiteField.text!
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
	
		var params = [String: Any]()
		params["rec"] = Rec.jsonDicStr()
//		do{
//			let recData = try JSONSerialization.data(withJSONObject: [Rec], options: .prettyPrinted)
//			let recStr = String.init(data: recData, encoding: .utf8)
//			if recStr != nil{
//				params["rec"] = recStr
//			}
//		}catch{
//		}
		self.submitBillInfoWith(params: params)
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
		self.fetchAddressInfo(model: AdrModel(), view: sender, key: .province){
			[unowned self] result in
			if result{
				self.sendCityBtn.setTitle("", for: .normal)
				self.sendDistBtn.setTitle("", for: .normal)
			}
		}
	}
	
	//寄件人市
	@IBAction func sendCity(_ sender: UIButton) {
		print("寄件人市")
		guard let province = self.sendProvinceBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择寄件省")
			return
		}
		var model = AdrModel()
		model.province = province
		self.fetchAddressInfo(model: model, view: sender, key: .city){
			[unowned self] result in
			if result{
				self.sendDistBtn.setTitle("", for: .normal)
			}
		}
	}
	
	//寄件人区
	@IBAction func sendDistrict(_ sender: UIButton) {
//		var params:Parameters = [:]
		guard let province = self.sendProvinceBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择寄件省")
			return
		}
//		params[AdrKey.province.rawValue] = province
		guard let city = self.sendCityBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择寄件市")
			return
		}
//		params[AdrKey.city.rawValue] = city
		var model = AdrModel()
		model.province = province
		model.city = city
		self.fetchAddressInfo(model: model, view: sender, key: .town, block: nil)
	}
	
	//收件人省
	@IBAction func receiveProvince(_ sender: UIButton) {
		self.fetchAddressInfo(model: AdrModel(), view: sender, key: .province){
			[unowned self] result in
			if result{
				self.receCityBtn.setTitle("", for: .normal)
				self.receDistBtn.setTitle("", for: .normal)
			}
		}
	}
	
	//收件人市
	@IBAction func receiveCity(_ sender: UIButton) {
//		var params:Parameters = [:]
		guard let province = self.recePronvinBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择收件省")
			return
		}
//		params[AdrKey.province.rawValue] = province
		var model = AdrModel()
		model.province = province
		self.fetchAddressInfo(model: model, view: sender, key: .city){
			[unowned self] result in
			if result{
				self.receDistBtn.setTitle("", for: .normal)
			}
		}
	}
	
	//收件人区
	@IBAction func receiveDistrict(_ sender: UIButton) {
//		var params:Parameters = [:]
		guard let province = self.recePronvinBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择收件省")
			return
		}
//		params[AdrKey.province.rawValue] = province
		guard let city = self.receCityBtn.titleLabel?.text else{
			self.remindUser(msg: "请选择收件市")
			return
		}
//		params[AdrKey.city.rawValue] = city
		var model = AdrModel()
		model.province = province
		model.city = city
		self.fetchAddressInfo(model: model, view: sender, key: .town, block: nil)
	}
	
	
	//超长、签收回单、超重、进仓件、发货、收货
	@IBAction func checkBoxs(sender: UIButton){
		print("获取单号。。。")
		sender.isSelected = !sender.isSelected
	}
	
	//保存
	@objc func saveBill(){
		print("click right bar item save ....")
		guard let paramsData = self.paramsSaveBill() else{
			return
		}
		var params: Parameters = [:]
		do{
			let recData = try JSONSerialization.data(withJSONObject: [paramsData], options: .prettyPrinted)
			let recStr = String.init(data: recData, encoding: .utf8)
			if recStr != nil{
				params["rec"] = recStr
			}
		}catch{
		}
		
		self.submitBillInfoWith(params: params)
		
	}
	
	//目的网点所属中心
	@IBAction func destSite(_ sender: UIButton) {
		print("目的网点所属中心")
	}
	
	//寄件网点所属中心
	@IBAction func sendSite(_ sender: UIButton) {
		let siteName = DataManager.shared.loginUser.siteName
//		let params:Parameters = ["siteName":siteName]
		self.fetchSiteSuperName(siteName: siteName, view: sender)
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
  
  //pay type action sheet
  @IBAction func payType(_ sender: UIButton) {
    let types = ["到付","现金","月结"]
    ActionSheetStringPicker.show(withTitle: "支付类型", rows: types, initialSelection: 0, doneBlock: {
      [unowned self] (picker, index, vals) in
      if let typeStr = vals as? String{
        self.payTypeField.text = typeStr
      }
      }, cancel: {(picker) in
    }, origin: self.view)
  }
	
	
	
	//MARK:- WangdianPickerInterface
	func onWangdianPicked(item:SiteInfo){
		self.destSiteField.text = item.siteName
		self.paiSiteField.text = item.siteName
	}
	
	//MARK:- UITExtField delegate
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField.tag == 100 {
			let weightStr = self.weightField.text!
			let weightD = Double(weightStr) ?? 0.0
			
			let volWeightStr = self.volumeWeightField.text!
			let volWeightD = Double(volWeightStr) ?? 0.0
			
			let weight = weightD > volWeightD ? weightD : volWeightD
			if weight != 0.0{
				let calWeightStr = String(weight)
				self.calWeightField.text = calWeightStr
			}else{
				self.calWeightField.text = ""
			}

			
		}else if textField.tag == 101 {
			let weightStr = self.weightField.text!
			let weightD = Double(weightStr) ?? 0.0
			
			let volStr = self.volumeField.text!
			let vol = Double(volStr) ?? 0.0
			let volWeight = vol * 200
			
			if volWeight > 0.0 {
				let volWeigthStr = String(volWeight)
				self.volumeWeightField.text = volWeigthStr
			}else{
				self.volumeWeightField.text = ""
			}
			
			let weight = weightD > volWeight ? weightD : volWeight
			if weight != 0.0{
				let calWeightStr = String(weight)
				self.calWeightField.text = calWeightStr
			}else{
				self.calWeightField.text = ""
			}
			
			
		}
		
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
	
	
	//MARK:- request params
	func paramsSaveBill() -> Parameters?{
		var params: Parameters = [:]
		params["sendDate"] = self.sendDateField.text
		if let billCode = self.billNumField.text,!billCode.isEmpty {
			params["billCode"] = billCode
		}else{
			self.remindUser(msg: "请输入运单号")
			return nil
		}
		
//		if let billCode = self.billNumField.text {
//			params["billCode"] = billCode
//		}else{
//			self.remindUser(msg: "请输入运单号")
//			return nil
//		}
		
		
		if let sendMan = self.senderField.text,!sendMan.isEmpty {
			params["sendMan"] = sendMan
		}else{
			self.remindUser(msg: "请输入寄件人")
			return nil
		}
		
		//寄件省--
		if let province = self.sendProvinceBtn.titleLabel?.text,!province.isEmpty {
			params["province"] = province
		}else{
			self.remindUser(msg: "请输入寄件省")
			return nil
		}
		
		//寄件市--
		if let city = self.sendCityBtn.titleLabel?.text,!city.isEmpty {
			params["city"] = city
		}else{
			self.remindUser(msg: "请输入寄件市")
			return nil
		}
		
		//寄件区--
		if let borough = self.sendDistBtn.titleLabel?.text ,!borough.isEmpty{
			params["borough"] = borough
		}else{
			self.remindUser(msg: "请输入寄件区")
			return nil
		}
		
		//寄件地？？？
//		if let sendAddress = self.sendAdrDetail.text {
//			params["sendAddress"] = sendAddress
//		}
		
		//寄件地址--？？
		if let sendManAddress = self.sendAdrDetail.text,!sendManAddress.isEmpty {
			params["sendManAddress"] = sendManAddress
		}else{
			self.remindUser(msg: "请输入寄件地址")
			return nil
		}
		
		if let sendManPhone = self.sendPhoneField.text,!sendManPhone.isEmpty {
			params["sendManPhone"] = sendManPhone
		}else{
			self.remindUser(msg: "请输入寄件人电话")
			return nil
		}
		
		//收件人--
		if let acceptMan = self.receiverField1.text, !acceptMan.isEmpty {
			params["acceptMan"] = acceptMan
		}else{
			self.remindUser(msg: "请输入收件人")
			return nil
		}
		
		//收件省--
		if let provinceName = self.recePronvinBtn.titleLabel?.text,!provinceName.isEmpty {
			params["provinceName"] = provinceName
		}else{
			self.remindUser(msg: "请选择收件省")
			return nil
		}
		
		//收件市--
		if let cityName = self.receCityBtn.titleLabel?.text, !cityName.isEmpty {
			params["cityName"] = cityName
		}else{
			self.remindUser(msg: "请选择收件市")
			return nil
		}
		
		//收件区--
		if let countyName = self.receDistBtn.titleLabel?.text, !countyName.isEmpty{
			params["countyName"] = countyName
		}else{
			self.remindUser(msg: "请选择收件区")
			return nil
		}
		
		//收件地址--
		if let acceptManAddress = self.receAdrDetail.text,!acceptManAddress.isEmpty {
			params["acceptManAddress"] = acceptManAddress
		}else{
			self.remindUser(msg: "请输入收件地址")
			return nil
		}
		
		//收件电话--
		if let acceptManPhone = self.recePhoneField.text,!acceptManPhone.isEmpty {
			params["acceptManPhone"] = acceptManPhone
		}else{
			self.remindUser(msg: "请输入收件电话")
			return nil
		}
		
		//目的地--
		if let destination = self.destSiteField.text, !destination.isEmpty {
			params["destination"] = destination
		}else{
			self.remindUser(msg: "请选择目的地")
			return nil
		}
		
		//目的分拨中心--
		if let destinationCenter = self.destSiteSupBtn.titleLabel?.text,!destinationCenter.isEmpty {
			params["destinationCenter"] = destinationCenter
		}else{
			self.remindUser(msg: "请选择目的分拨中心")
			return nil
		}
		
		//派件网点--
		if let dispatchSite = self.paiSiteField.text,!dispatchSite.isEmpty {
			params["dispatchSite"] = dispatchSite
		}else{
			self.remindUser(msg: "请选择派件网点")
			return nil
		}
		
		//寄件网点分拨中心--
		if let scanSite3 = self.jiSiteSupBtn.titleLabel?.text, !scanSite3.isEmpty {
			params["scanSite3"] = scanSite3
		}else{
			self.remindUser(msg: "请选择寄件网点分拨中心")
			return nil
		}
		
		//货物名称--
		if let goodsName = self.goodsNameField.text, !goodsName.isEmpty {
			params["goodsName"] = goodsName
		}else{
			self.remindUser(msg: "请输入货物名称")
			return nil
		}
		
		//包装类型--
		if let packType = self.packageBtn.titleLabel?.text, !packType.isEmpty {
			params["packType"] = packType
		}else{
			self.remindUser(msg: "请选择包装类型")
			return nil
		}
		
		//结算重量--
		if let settlementWeight = self.calWeightField.text, !settlementWeight.isEmpty {
			params["settlementWeight"] = settlementWeight
		}
		
		//实际重量--
		if let billWeight = self.weightField.text, !billWeight.isEmpty {
			params["billWeight"] = billWeight
		}else{
			self.remindUser(msg: "请输入实际重量")
			return nil
		}
		
		//体积--
		if let volume = self.volumeField.text,!volume.isEmpty {
			params["volume"] = volume
		}else{
			self.remindUser(msg: "请输入体积")
			return nil
		}
		
		//体积重量--
		if let volumeWeight = self.volumeWeightField.text, !volumeWeight.isEmpty {
			params["volumeWeight"] = volumeWeight
		}
		
		//派送方式--
		if let dispatchMode = self.deliverTypeBtn.titleLabel?.text,!dispatchMode.isEmpty {
			params["dispatchMode"] = dispatchMode
		}else{
			self.remindUser(msg: "请选择派送方式")
			return nil
		}
		
		//运输方式--
		if let classType = self.transportTypeBtn.titleLabel?.text, !classType.isEmpty {
			params["classType"] = classType
		}else{
			self.remindUser(msg: "请选择运输方式")
			return nil
		}
		
		//件数--
		if let pieceNumber = self.jianShuField.text, !pieceNumber.isEmpty {
			params["pieceNumber"] = pieceNumber
		}else{
			self.remindUser(msg: "请输入件数")
			return nil
		}
		
		//管理费
		if let manageFee = self.managerFeeField.text, !manageFee.isEmpty {
			params["manageFee"] = manageFee
		}else{
			self.remindUser(msg: "请输入管理费")
			return nil
		}
		
		//子单号--
		if let billCodeSub = self.subBillField.text, !billCodeSub.isEmpty {
			params["billCodeSub"] = billCodeSub
		}
		
		
		//支付方式--
		if let paymentType = self.payTypeField.text,!paymentType.isEmpty {
			params["paymentType"] = paymentType
		}else{
			self.remindUser(msg: "请选择支付方式")
			return nil
		}
		
		//到付款--
		if let topayment = self.payMoneyField.text, !topayment.isEmpty {
			params["topayment"] = topayment
		}else{
			self.remindUser(msg: "请输入到付款")
			return nil
		}
		
		//运费--
		if let freight = self.yunFeiField.text, !freight.isEmpty {
			params["freight"] = freight
		}else{
			self.remindUser(msg: "请输入运费")
			return nil
		}
		
		//保价金额--
		if let insuredMoney = self.jinE.text,!insuredMoney.isEmpty {
			params["insuredMoney"] = insuredMoney
		}else{
			self.remindUser(msg: "请输入保价金额")
			return nil
		}
		
		//保价费--
		if let insureValueStr = self.payMoneyField.text,!insureValueStr.isEmpty {
			let ary = insureValueStr.split(separator: ":")
			if ary.count > 1 {
				let insureValue = ary.last
				params["insureValue"] = insureValue
			}
		}
		
		//回单标识-- int ;
		if self.signBillBtn.isSelected {
			params["blReturnBill"] = 1
			//回单编号--
			if let rBillcode = self.rebillField.text,!rBillcode.isEmpty {
				params["rBillcode"] = rBillcode
			}
		}else{
			params["blReturnBill"] = 0
		}
		
		//超长标识--int ;
		if self.overLen.isSelected {
			params["blOverLong"] = 1
		}else{
			params["blOverLong"] = 0
		}
		
		
		//超重标识--int ;
		if self.overWeightBtn.isSelected {
			params["blOverWeight"] = 1
			//超重件数--
			if let overWeightPiece = self.chaoZhongJianShu.text,!overWeightPiece.isEmpty {
				params["overWeightPiece"] = overWeightPiece
			}
		}else{
			params["blOverWeight"] = 0
		}
		

		//进仓标识-- int ;
		if self.storeBtn.isSelected {
			params["blIntoWarehouse"] = 1
			//进仓编号--
			if let storageno = self.storeBillField.text,!storageno.isEmpty {
				params["storageno"] = storageno
			}
		}else{
			params["blIntoWarehouse"] = 0
		}
		
		
		//其他费用--
		if let otherFee = self.qiTaFei.text,!otherFee.isEmpty {
			params["otherFee"] = otherFee
		}
		
		//送货费--
		if let sendgoodsFee = self.songHuoFei.text,!sendgoodsFee.isEmpty {
			params["sendgoodsFee"] = sendgoodsFee
		}else{
			self.remindUser(msg: "请输入送货费")
			return nil
		}
		
		//超区费--
		if let overAreaFee = self.chaoQuFei.text,!overAreaFee.isEmpty {
			params["overAreaFee"] = overAreaFee
		}
		//上楼费--
		if let upstairsFee = self.shangLouFei.text,!upstairsFee.isEmpty {
			params["upstairsFee"] = upstairsFee
		}
		
		//收货短信标识--
		if self.receMsgBtn.isSelected{
			params["blMessage1"] = 1
		}else{
			params["blMessage1"] = 0
		}
		
		//发货短信标识--
		if self.sendMsgBtn.isSelected{
			params["blMessage"] = 1
		}else{
			params["blMessage"] = 0
		}
		
		
		return params
		
	}
	
	
	
	
	//MARK:- request server
	//提交录单数据
	func submitBillInfoWith(params: [String: Any]) {
		self.view.endEditing(true)
		let req = DanPiaoQuanReq(params: params)
		self.showLoading(msg: "提交中...")
		STNetworking<RespMsg>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
		}?.resume()
	}
	
	
	//app获取电子面单接口
	func fetchBillNum(){
		self.view.endEditing(true)
		self.showLoading(msg: "查询中...")
		let req = BillNumReq()
		STNetworking<String>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				self.billNumField.text = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
		}?.resume()
	}
	
	
	
	
	//查询运输方式
	func fetchTransportType(){
		self.view.endEditing(true)
		self.showLoading(msg: "查询运输类型...")
		let req = TransportReq()
		
		STNetworking<[TransportType]>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				self.showTranTypeSheet(types: resp.data)
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
		}?.resume()
	}
	
	
	//查询派送方式
	func fetchDeliverType(){
		self.view.endEditing(true)
		self.showLoading(msg: "")

		let req = ExpressReq()
		STNetworking<[ExpressTypeModel]>(stRequest: req) {
			[unowned self](resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				if resp.data.count > 0 {
					self.showDeliverTypeSheet(types: resp.data)
				}
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络请求超时")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
		}?.resume()
	}
	
	
  //query jijian province city district
	func fetchAddressInfo(model: AdrModel, view: UIButton, key: AdrKey, block: ((Bool) -> Void)?){
		self.view.endEditing(true)
		self.showLoading(msg: "数据加载中...")
		let req = AddressReq(adrModel: model)
		STNetworking<[AdrModel]>(stRequest: req) {
			[unowned self](resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				let adrs = resp.data
				print("adrs array: \(adrs)")
				block?(true)
				self.showAdrActSheet(key: key, adrs: adrs, view: view)
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
		
  }
	
	
	//查询寄件网点所属分拨中心
	func fetchSiteSuperName(siteName: String, view: UIButton){
		self.showLoading(msg: "查询...")
		let req = SiteRequest(siteName: siteName)
		STNetworking<String>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				let site = resp.data
				let nameStr = site.replacingAll(matching: ";", with: "")
				view.setTitle(nameStr, for: .normal)
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "请求超时")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
	
	
	
	
	
	
	
	
	
}
