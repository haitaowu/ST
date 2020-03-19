//
//  FajianSaomiaoViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class FajianSaomiaoViewController: UIViewController,STListViewDelegate ,QrInterface,WangdianPickerInterface{
    var objects:[STListViewModel] = []
    @IBOutlet weak var ydhField: UITextField!
    @IBOutlet weak var zdField: UITextField!
    var headers:[String] = ["运单号","站点"]
    var columnPercents:[CGFloat] = [0.5,0.5]
    @IBOutlet weak var listView: STListView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发件扫描"
        self.view.backgroundColor = UIColor.appBgColor
        self.listView.styleme()
        self.listView.delegate = self
        self.reloadData()
        self.setupUploadNavItem()
        // Do any additional setup after loading the view.
    }
    func deleteObject(object:STListViewModel) -> Bool{
        if let object = object as? FajianModel{
            STDb.shared.deleteFj(model: object)
            self.objects = self.objects.filter{ ($0 as! FajianModel).billCode != object.billCode }
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
//        DataManager.shared.uploadFajian(m: STDb.shared.allFj()){
//            [unowned self] result in
//            self.hideLoading()
//            if result.0{
//                STDb.shared.removeAllFj()
//                self.reloadData()
//                self.remindUser(msg: "上传成功")
//            }else{
//                self.remindUser(msg: result.1)
//            }
//        }
        DataManager.shared.uploadFajian(m: STDb.shared.allFj()) {
            [unowned self] (succ, msg) in
            
            self.hideLoading()
            if succ{
                STDb.shared.removeAllFj()
                self.reloadData()
                self.remindUser(msg: "上传成功")
            }else{
                self.remindUser(msg: msg)
            }
        }
    }
    private func reloadData(){
        self.objects = STDb.shared.allFj()
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
        //let ysfs = self.fjfsField.text ?? ""
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
        if zd.isEmpty{
            self.remindUser(msg: "收件员不能为空")
            return
        }
        let m = FajianModel(billCode: ydh, preOrNext: zd, scanDate: Date.stNow, classs: "汽运")
        DataManager.shared.saveFaJian(m:m)
        self.reloadData()
    }
}
