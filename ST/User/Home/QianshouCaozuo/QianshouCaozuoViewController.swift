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
	
	
	//MARK:- overrides
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
	
	//MARK:- private methods
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
	
	private func reloadData(){
		self.objects = STDb.shared.allQs()
		self.listView.reloadData()
	}
	
	
	//MARK:- selectors
	@objc private func onUploadAction(){
		let ary: [QianshouModel] = STDb.shared.allQs()
		guard ary.count > 0 else {
			self.remindUser(msg: "无签收上传")
			return
		}
		self.showLoading(msg: "上传中，清稍后")
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
	
	
	@IBAction func scanBtnClicked(_ sender: Any) {
		self.openQrReader()
	}
	
	///点击存储button
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
		
		//运单号是否到件和录单检测
		let req = OrderValiReq(billCode: ydh)
		self.showLoading(msg: "验证运单号...")
		self.reqValidateOrderIllegal(req: req) {
			[unowned self] result in
			if (result){
				let m = QianshouModel(billCode: ydh, signName: qsr, tp: self.tp, signRemark: bz, signDate: Date.stNow)
				DataManager.shared.saveQianshou(m: m)
				self.reloadData()
			}
		}
		
		
	}
	
	
	//MARK:- UIImagePickerController delegate
	private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
		self.dismiss(animated: true, completion: nil)
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
	
	//MARK:- QRCodeReaderViewDelegate
	func onReadQrCode(code: String) {
		self.ydhField.text = code
	}
	
	
	
	//MARK:- request server
	func reqValidateOrderIllegal(req: OrderValiReq, result: @escaping ((_ res: Bool)->Void)){
		
		STNetworking<ReqResult>(stRequest: req) {
			[unowned self] resp in
			if resp.stauts == Status.Success.rawValue{
				self.hideLoading()
				result(true)
      }else if resp.stauts == Status.NetworkTimeout.rawValue{
        self.remindUser(msg: "网络超时，请稍后尝试")
      }else{
				self.remindUser(msg: "运单号不正确")
			}
		}?.resume()
		
	}
	
	
	
}
