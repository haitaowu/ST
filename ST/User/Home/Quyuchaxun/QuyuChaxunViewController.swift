//
//  QuyuChaxunViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class QuyuChaxunViewController: UIViewController,STListViewDelegate,PickerInputViewModelDelegate,UITextFieldDelegate {
    var objects:[STListViewModel] = []
    var headers:[String] = ["省份","站点","电话"]
    var columnPercents:[CGFloat] = [0.3,0.3,0.4]
    @IBOutlet weak var keywordField: UITextField!
    
    @IBOutlet weak var addressInputField: UITextField!
    @IBOutlet weak var listView: STListView!
    var addressInputView:PickerInputView = Bundle.main.loadNibView(name: "PickerInputView")
    var inputType:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "区域查询"
        self.view.backgroundColor = UIColor.appBgColor
        self.listView.styleme()
        self.listView.delegate = self
        self.addressInputView.model = DataManager.shared.addressPickerModel
        self.addressInputField.delegate = self
        self.addressInputView.delegate  = self
        self.reloadData()
        // Do any additional setup after loading the view.
    }
    func onObjectSelect(object: STListViewModel) {
        if let object = object as? QuyuModel{
            self.showQuyuDetail(qy: object)
        }
    }
    func showQuyuDetail(qy:QuyuModel){
        let header = "<header><meta name=\"viewport\" content=\"width=device-width,height=device-height,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"><meta charset=\"utf-8\"/></header>"
        let contents = [
            ("网点编号","\(qy.siteCode)"),
            ("网点名称","\(qy.siteName)"),
            ("负责人","\(qy.principal)"),
            ("联系电话","\(qy.tel)"),
            ("能否贷收货款",""),
            ("代收货款限制金额",""),
            ("是否停用",""),
            ("传真号码",""),
            ("派送区域","\(qy.dispatchRange)"),
            ("地址",""),
            ("不派送范围","\(qy.notdispatchRange)"),
            ("特殊服务范围",""),
            ("派送时间",""),
        ].map{"<div class='line' style='border-bottom-color: rgba(0, 0, 0, 0.4); border-bottom-style: solid; border-bottom-width: 0.5px;font-size: 12px;'>\($0.0):\($0.1)</div>"}.joined(separator: "")
        let body = "<body><h4 class='title' style='border-bottom-color: rgba(0, 0, 0, 0.4); border-bottom-style: solid; border-bottom-width: 0.5px;'>【\(qy.siteName)】 网点信息</h4>\(contents)</body>"
        let html = "<!DOCTYPE html><html>\(header)\(body)</html>"
        let web = WebViewController(html: html)
        web.title = "网点详情"
        self.navigationController?.pushViewController(web, animated: true)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.updateInputViews()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.inputType = 0
    }
    func updateInputViews(){
        if inputType == 0{
            self.addressInputField.inputView = nil
        }else{
            self.addressInputField.inputView = self.addressInputView
        }
        self.addressInputField.reloadInputViews()
    }
    @IBAction func quyuSelectBtnClicked(_ sender: Any) {
        self.inputType = 1
        self.addressInputField.becomeFirstResponder()
        self.updateInputViews()
    }
    
    @IBAction func quyuChaxunBtnClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.searchQuyu()
    }
    
    private func searchQuyu(){
        let add = self.addressInputField.text ?? ""
        let cmps = add.components(separatedBy: "-")
        if cmps.count != 2{
            self.remindUser(msg: "请输入正确的地址格式(请省-市格式输入)")
            return
        }
        
        let prov = cmps[0]
        let city = cmps[1]
        let word = self.keywordField.text ?? ""
        let req = QuyuChaxunRequest(prov: prov, city: city, word: word)
        self.showLoading(msg: "查询中")
        STNetworking<[QuyuModel]>(stRequest:req){
            [unowned self]resp in
            self.hideLoading()
            self.objects = resp.data
            if self.objects.count == 0{
                self.remindUser(msg: "查询结果为空")
                return
            }
            self.reloadData()
        }?.resume()
        
    }
    func onPickerInputViewIndexChagne(_ row:Int,_ component:Int){
        if component == 0{
            DataManager.shared.addressPickerModel.selectProvinceIndex = row
            self.addressInputView.model = DataManager.shared.addressPickerModel
        }else if component == 1{
            let pIndex = DataManager.shared.addressPickerModel.selectProvinceIndex
            DataManager.shared.addressPickerModel.provincesList[pIndex].selectCityIndex = row
        }
        self.addressInputField.text = DataManager.shared.addressPickerModel.getCurrentAddress()
    }
    func onPickerInputViewRequestDismiss(){
        self.addressInputField.resignFirstResponder()
    }
    
    private func reloadData(){
        self.listView.reloadData()
    }

}
