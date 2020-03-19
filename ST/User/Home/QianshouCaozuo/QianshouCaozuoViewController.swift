//
//  QianshouCaozuoViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class QianshouCaozuoViewController: UIViewController,STListViewDelegate,QrInterface,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var objects:[STListViewModel] = []
    @IBOutlet weak var ydhField: UITextField!
    @IBOutlet weak var qsrField: UITextField!
    @IBOutlet weak var bzField: UITextField!
    var tp:String = ""
    var headers:[String] = ["运单号","签收人","图片"]
    var columnPercents:[CGFloat] = [0.4,0.4,0.2]
    @IBOutlet weak var listView: STListView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBgColor
        self.title = "签收操作"
        self.listView.styleme()
        self.listView.delegate = self
        self.reloadData()
        self.setupUploadNavItem()
        // Do any additional setup after loading the view.
    }
    func deleteObject(object:STListViewModel) -> Bool{
        if let object = object as? QianshouModel{
            STDb.shared.deleteQs(model: object)
            self.objects = self.objects.filter{ ($0 as! QianshouModel).billCode != object.billCode }
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
//        DataManager.shared.uploadQianshou(m: STDb.shared.allQs()){
//        DataManager.shared.reqBillQianshou(m: STDb.shared.allQs()){
//            [unowned self]result in
//            self.hideLoading()
//            if result.0{
//                STDb.shared.removeAllQs()
//                self.reloadData()
//                self.remindUser(msg: "上传成功")
//            }else{
//                self.remindUser(msg: result.1)
//            }
//        }
        
        DataManager.shared.reqBillQianshou(m: STDb.shared.allQs()) {
            [unowned self] (succ, msg) in
            self.hideLoading()
            if succ{
                STDb.shared.removeAllQs()
                self.reloadData()
                self.remindUser(msg: "上传成功")
            }else{
                self.remindUser(msg: msg)
            }
        }
    }
    
    private func reloadData(){
        self.objects = STDb.shared.allQs()
        self.listView.reloadData()
    }
	
    @IBAction func camaraBtnClicked(_ sender: Any) {
        let ydh = self.ydhField.text ?? ""
        if ydh.isEmpty{
            self.remindUser(msg: "请先输入运单号")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        #if DEBUG
        imagePicker.sourceType = .photoLibrary
        #else
        imagePicker.sourceType = .camera
        #endif
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
// Local variable inserted by Swift 4.2 migrator.
//let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        self.dismiss(animated: true, completion: nil)
//        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let ydh = self.ydhField.text ?? ""
            DataManager.shared.saveLocalImage(img: image,ydh:ydh){ path in
                self.tp = path
                self.qsrField.text = "拍照签收"
                self.saveButtonClicked(self)
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onReadQrCode(code: String) {
        self.ydhField.text = code
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let ydh = self.ydhField.text ?? ""
        let qsr = self.qsrField.text ?? ""
        let bz = self.bzField.text ?? ""
        
        if ydh.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return
        }
        if !ydh.isBarcode(){
            self.remindUser(msg: "运单号格式错误")
            return
        }
        if qsr.isEmpty{
            self.remindUser(msg: "签收人不能为空")
            return
        }
//        if bz.isEmpty{
//            self.remindUser(msg: "备注不能为空")
//            return
//        }
        let m = QianshouModel(billCode: ydh, signName: qsr, tp: tp, signRemark: bz, signDate: Date.stNow)
        DataManager.shared.saveQianshou(m: m)
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
