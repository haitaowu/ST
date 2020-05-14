//
//  PaijianSaomiaoViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class PaijianSaomiaoViewController: UIViewController,STListViewDelegate,QrInterface,YuangongPickerInterface {
    var objects:[STListViewModel] = []
    @IBOutlet weak var ydhField: UITextField!
    @IBOutlet weak var zdField: UITextField!
    var headers:[String] = ["运单号","派件员"]
    var columnPercents:[CGFloat] = [0.5,0.5]
    @IBOutlet weak var listView: STListView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBgColor
        self.title = "派件扫描"
        self.listView.styleme()
        self.listView.delegate = self
        self.reloadData()
        self.setupUploadNavItem()
        // Do any additional setup after loading the view.
    }
    func deleteObject(object:STListViewModel) -> Bool{
        if let object = object as? PaijianModel{
            STDb.shared.deletePj(model: object)
            self.objects = self.objects.filter{ ($0 as! PaijianModel).billCode != object.billCode }
            return true
        }
        return false
    }
    private func setupUploadNavItem(){
        let uploadBtn = UIBarButtonItem(image: UIImage(named: "upload"), style: UIBarButtonItem.Style.done, target: self, action: #selector(onUploadAction))
        self.navigationItem.rightBarButtonItem = uploadBtn
    }
	@objc private func onUploadAction(){
		let ary: [PaijianModel] = STDb.shared.allPj()
		guard ary.count > 0 else {
			self.remindUser(msg: "无派件上传")
			return
		}
		self.showLoading(msg: "上传中，清稍后")
        DataManager.shared.uploadPaijian(m: STDb.shared.allPj()) {
            [unowned self] (succ, msg) in
            self.hideLoading()
            if succ{
                STDb.shared.removeAllPj()
                self.reloadData()
                self.remindUser(msg: "上传成功")
            }else{
                self.remindUser(msg: msg)
            }
        }
    }
    private func reloadData(){
        self.objects = STDb.shared.allPj()
        self.listView.reloadData()
    }
    func onYuangongSelect(item:Employee){
        self.zdField.text = item.employeeName
    }
    @IBAction func paijianyuanSelectBtnClicked(_ sender: Any) {
        self.showYuangongPicker()
    }
    
    func onReadQrCode(code: String) {
        self.ydhField.text = code
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let m = PaijianModel(billCode: ydh, dispMan: zd, scanDate: Date.stNow)
        DataManager.shared.savePijian(m: m)
        self.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
