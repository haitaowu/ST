//
//  CompletePrintControl.swift
//  ST
//  Created by taotao on 20/03/2018.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire


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
  @IBOutlet weak var chaoQuFei: UILabel!
 //上楼费
  @IBOutlet weak var shangLouFei: UILabel!
  //送货费
  @IBOutlet weak var songHuoFei: UILabel!
  //其它费用
  @IBOutlet weak var qiTaFei: UILabel!
  
  //当前扫描的UITextField
  var scanField:UITextField?
  
  let billInfo:NSMutableDictionary  = NSMutableDictionary()
  
  //MARK:- override mothods
  override func viewDidLoad() {
    self.setupUI()
  }
  
  //MARK:- private methods
  func setupUI() {
    self.title = "单票录入(全)"
    for  view in self.containerViewCollect {
      view.setupDashLine()
    }
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
  }
  //寄件人省
  @IBAction func sendProvince(_ sender: UIButton) {
    print("寄件人省")
  }
  
  //寄件人市
  @IBAction func sendCity(_ sender: UIButton) {
    print("寄件人市")
  }
  
  //寄件人区
  @IBAction func sendDistrict(_ sender: UIButton) {
    print("寄件人区")
  }
  
  //收件人省
  @IBAction func receiveProvince(_ sender: UIButton) {
    print("收件人省")
  }
  
  //收件人市
  @IBAction func receiveCity(_ sender: UIButton) {
    print("收件人市")
  }
  
  //收件人区
  @IBAction func receiveDistrict(_ sender: UIButton) {
    print("收件人区")
  }
  
  //超长、签收回单、超重、进仓件、发货、收货
  @IBAction func checkBoxs(sender: UIButton){
     print("获取单号。。。")
    sender.isSelected = !sender.isSelected
  }
  
  //保存
  @objc func saveBill(){
    print("click right bar item save ....")
  }
  
  //目的网点所属中心
  @IBAction func destSite(_ sender: UIButton) {
    print("目的网点所属中心")
  }
  
  //寄件网点所属中心
  @IBAction func sendSite(_ sender: UIButton) {
    print("寄件网点所属中心")
  }
  
  //包装类型
  @IBAction func packageType(_ sender: UIButton) {
    print("包装类型")
  }
  
  //运输方式
  @IBAction func transportType(_ sender: UIButton) {
    print("运输方式")
  }
  
  //派送方式
  @IBAction func deliverType(_ sender: UIButton) {
    print("派送方式")
  }
  
  
  //MARK:- request server
  //提交录单数据
  func submitBillInfoWith(params:Parameters) {
    self.showLoading(msg: "提交保单中...")
    let reqUrl = Consts.Server + Consts.BaseUrl + "m8/uploadPrintBillSubNew.do"
    Alamofire.request(reqUrl, method: .post, parameters: params).responseJSON {[unowned self] response in
      print("Request: \(String(describing: response.request))")   // original url request
      print("Response: \(String(describing: response.response))") // http url response
      print("Result: \(response.result)")                         // response serialization result
      if let json = response.result.value as? NSDictionary{
        if let stauts = json.value(forKey: "stauts"){
          if let statusNum = stauts as? Int{
            if statusNum == 4{
              self.remindUser(msg: "保存成功")
              let data = json.value(forKey: "data") as? NSArray
              if let billData = data?.firstObject as? NSDictionary{
                let transferCenter = billData["transferCenter"]
                print("transferCenter = \(String(describing: transferCenter))")
                self.billInfo["transferCenter"] = billData["transferCenter"]
                self.showSubmitSuccView()
              }
            }else{
              let msg = json.value(forKey: "msg") as? String
              self.remindUser(msg: msg!)
              NSLog("request product status = \(stauts)")
            }
          }
        }else{
          self.remindUser(msg: "保存失败")
        }
      }else{
        self.remindUser(msg: "保存失败")
      }
    }
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
}
