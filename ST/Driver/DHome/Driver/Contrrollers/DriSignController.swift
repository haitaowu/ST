//
//  DriSignController.swift
//  ST
//
//  Created by taotao on 2020/9/18.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation
import BRPickerView




class DriSignController: UITableViewController{
	let kAttachSection = 0
	let kAttachRow = 1
	var params:[String: String]?
	var doneBlock:((Bool) -> Void)?
	
	//local properties
	@IBOutlet weak var attachContainer: DriVideoView!
	var attachAry:Array<UIImage>?
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupMediaViews()
	}
	
	
	//MARK: - SETUP UI
	func setupMediaViews() -> Void {
		self.attachAry = Array.init()
		self.attachAry?.append(UIImage(named: "plus")!)
		
		if let imgsAry = self.attachAry {
			self.updateAttachViewBy(imgsAry: imgsAry)
		}
		
		//实时拍摄的图片容器初始化
		self.attachContainer.clickBlock = {
			[unowned self] (idx, itemType) in
			print("attach item click")
			if itemType == .addBtn{
				if let imgs = self.attachAry,imgs.count > 3{
					self.remindUser(msg: "附件图片不可以超过三张")
				}else{
					self.showImgPickerView()
				}
			}else{
				if let imgs = self.attachAry{
					var imgDataAry = imgs
					imgDataAry.removeLast()
					self.showImgAt(idx:idx,imgs: imgDataAry)
				}
			}
		}
		
		//删除图片刷新tableView
		self.attachContainer.updateBlock = {
			[unowned self] idx in
			self.attachAry?.remove(at: idx)
			if let imgs = self.attachAry{
				self.updateAttachViewBy(imgsAry: imgs)
			}
		}
	}
	
	
	//MARK:- update UI
	func showImgPickerView(){
		BRStringPickerView.showPicker(withTitle: "选择", dataSourceArr: ["相机","媒体库"], select: 0) {
			[unowned self] model in
			if model?.index == 0{
				self.showTakePhoto()
			}else{
				self.showPhotoLibs()
			}
		}
	}
	
	
	
	//展示图片预览
	func showImgAt(idx:Int, imgs:Array<Any>) -> Void {
		// 数据源
		let dataSource = JXLocalDataSource(numberOfItems: {
			// 共有多少项
			return imgs.count
		}, localImage: { index -> UIImage? in
			// 每一项的图片对象
			return (imgs[index] as! UIImage)
		})
		let indicator = JXDefaultPageControlDelegate()
		let trans = JXPhotoBrowserFadeTransitioning.init()
		// 打开浏览器
		JXPhotoBrowser(dataSource: dataSource, delegate: indicator, transDelegate: trans).show(pageIndex: idx)
	}
	
	
	//拍照
	func showTakePhoto() {
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			let imgPicker = UIImagePickerController.init()
			imgPicker.sourceType = .camera
			imgPicker.delegate = self
			imgPicker.cameraFlashMode = .off
			self.present(imgPicker, animated: true) {
			}
		}else{
			print("相机不可用")
		}
	}
	
	//显示媒体库
	func showPhotoLibs(){
		if(UIImagePickerController.isSourceTypeAvailable(.camera)){
			let imgPicker = UIImagePickerController.init()
			imgPicker.sourceType = .photoLibrary
			imgPicker.delegate = self
			self.present(imgPicker, animated: true) {
			}
		}else{
			print("媒体库不可用")
		}
	}
	
	//更新实时拍摄图片容器
	func updateAttachViewBy(imgsAry:Array<Any>) -> Void {
		self.attachContainer.updateUI(imgs: imgsAry, type: .imgLoc, addAble: true)
		self.tableView.reloadData()
	}
	
	
	//MARK:-  selectors
	///提交fachedengji
	@IBAction func clickSubmitBtn(_ sender: UIButton) {
		if let block = self.doneBlock{
			block(true)
		}
		guard let imgAry = self.attachAry else{return}
		NetworkHelper.uploadDriSignImgs(to: "imageurl", imgs: imgAry){
			[unowned self] (state, data) in
			
		}
	}
	
	
}




extension DriSignController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == kAttachSection{
			if indexPath.row == kAttachRow{
				return DriVideoView.viewHeightBy(itemCount: (self.attachAry?.count)!)
			}else{
				return 50
			}
		}else if indexPath.section == 0{
			if indexPath.row == 4{
				return 80
			}
			return 50
		}else{
			return super.tableView(tableView, heightForRowAt: indexPath)
		}
	}
	
	
	//MARK:- UIImagePickerControllerDelegate
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		print("imagePickerControllerDidCancel")
		picker.dismiss(animated: true) {
		}
	}
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		print("didFinishPickingMediaWithInfo")
		if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			print("loaded image already")
			self.attachAry?.insert(img, at: 0)
			if let imgsAry = self.attachAry{
				self.updateAttachViewBy(imgsAry: imgsAry)
			}
		}
		
		picker.dismiss(animated: true) {
		}
	}
	
}
