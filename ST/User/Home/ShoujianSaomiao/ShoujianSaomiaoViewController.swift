//
//  ShoujianSaomiaoViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class ShoujianSaomiaoViewController: UIViewController,STListViewDelegate,QrInterface,YuangongPickerInterface {
    @IBOutlet weak var ydhField: UITextField!
    @IBOutlet weak var sjyField: UITextField!
    var objects:[STListViewModel] = []
    var headers:[String] = ["运单号","收件员"]
    var columnPercents:[CGFloat] = [0.5,0.5]
    @IBOutlet weak var listView: STListView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "收件扫描"
        self.view.backgroundColor = UIColor.appBgColor
        self.listView.styleme()
        self.listView.delegate = self
        self.reloadData()
        self.setupUploadNavItem()
        // Do any additional setup after loading the view.
    }
    func deleteObject(object:STListViewModel) -> Bool{
        if let object = object as? ShoujianModel{
            STDb.shared.deleteSj(model: object)
            self.objects = self.objects.filter{ ($0 as! ShoujianModel).billCode != object.billCode }
            return true
        }
        return false
    }
    private func setupUploadNavItem(){
        let uploadBtn = UIBarButtonItem(image: UIImage(named: "upload"), style: UIBarButtonItem.Style.done, target: self, action: #selector(onUploadAction))
        self.navigationItem.rightBarButtonItem = uploadBtn
    }
    @objc private func onUploadAction(){
        self.showLoading(msg: "上传中，清稍后")
//        DataManager.shared.uploadShoujian(m: STDb.shared.allSj()){
//            [unowned self]result in
//            self.hideLoading()
//            if result.0{
//                STDb.shared.removeAllSj()
//                self.reloadData()
//                self.remindUser(msg: "上传成功")
//            }else{
//                self.remindUser(msg: result.1)
//            }
//        }
        DataManager.shared.uploadShoujian(m: STDb.shared.allSj()) {
            [unowned self] (succ, msg) in
            self.hideLoading()
            if succ{
                STDb.shared.removeAllSj()
                self.reloadData()
                self.remindUser(msg: "上传成功")
            }else{
                self.remindUser(msg: msg)
            }
        }
    }
    
    private func reloadData(){
        self.objects = STDb.shared.allSj()
        self.listView.reloadData()
    }
    func onYuangongSelect(item:Employee){
        self.sjyField.text = item.employeeName
        self.ydhField.becomeFirstResponder()
    }
    @IBAction func shoujianyuanSelectBtnClicked(_ sender: Any) {
            self.showYuangongPicker()
    }
    func onReadQrCode(code: String) {
        self.ydhField.text = code
    }
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        let ydh = self.ydhField.text ?? ""
        let sjy = self.sjyField.text ?? ""
        if ydh.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return
        }
        if !ydh.isBarcode(){
            self.remindUser(msg: "运单号格式错误")
            return
        }
        if sjy.isEmpty{
            self.remindUser(msg: "收件员不能为空")
            return
        }
        let m = ShoujianModel(billCode: ydh, recMan: sjy, scanDate: Date.stNow)
        DataManager.shared.saveShouJian(m: m)
        self.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
