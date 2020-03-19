//
//  DaojianSaomiaoViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class DaojianSaomiaoViewController: UIViewController,STListViewDelegate,QrInterface,WangdianPickerInterface{
    var objects:[STListViewModel] = []
    @IBOutlet weak var ydhField: UITextField!
    @IBOutlet weak var zdField: UITextField!
    var headers:[String] = ["运单号","站点"]
    var columnPercents:[CGFloat] = [0.5,0.5]
    @IBOutlet weak var listView: STListView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "到件扫描"
        self.view.backgroundColor = UIColor.appBgColor
        self.listView.styleme()
        self.listView.delegate = self
        self.reloadData()
        self.setupUploadNavItem()
        // Do any additional setup after loading the view.
    }
    func deleteObject(object:STListViewModel) -> Bool{
        if let object = object as? DaojianModel{
            STDb.shared.deleteDj(model: object)
            self.objects = self.objects.filter{ ($0 as! DaojianModel).billCode != object.billCode }
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
//        DataManager.shared.uploadDaojian(m: STDb.shared.allDj()){
//            [unowned self]result in
//            self.hideLoading()
//            if result.0{
//                STDb.shared.removeAllDj()
//                self.reloadData()
//                self.remindUser(msg: "上传成功")
//            }else{
//                self.remindUser(msg: result.1)
//            }
//        }
        
        DataManager.shared.uploadDaojian(m: STDb.shared.allDj()) {
            [unowned self] (succ, msg) in
            self.hideLoading()
            if succ{
                STDb.shared.removeAllDj()
                self.reloadData()
                self.remindUser(msg: "上传成功")
            }else{
                self.remindUser(msg: msg)
            }
        }
    }
    private func reloadData(){
        self.objects = STDb.shared.allDj()
        self.listView.reloadData()
    }
    
    func onReadQrCode(code: String) {
        self.ydhField.text = code
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    func onWangdianPicked(item:SiteInfo){
        self.zdField.text = item.siteName
    }
    
    @IBAction func wangdianBtnClicked(_ sender: Any) {
        self.showWangdianPicker()
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let ydh = self.ydhField.text ?? ""
        let zd = self.zdField.text ?? ""
        if ydh.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return
        }
        if !ydh.isBarcode(){
            self.remindUser(msg: "运单号格式错误")
            return
        }
        if zd.isEmpty{
            self.remindUser(msg: "站点不能为空")
            return
        }
        let m = DaojianModel(billCode: ydh, preOrNext: zd, scanDate: Date.stNow)
        DataManager.shared.saveDaojian(m: m)
        self.reloadData()
    }
}
