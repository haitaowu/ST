//
//  DriDamQueryDetailController.swift
//  ST
//
//  Created by taotao on 2019/6/16.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0
import AVKit
import ESPullToRefresh




class DriDamQueryDetailController: UITableViewController{
  
  
  
	@IBOutlet weak var damImgsView: DriVideoView!
	@IBOutlet weak var liveImgsView: DriVideoView!
	
	@IBOutlet weak var reportNumLabel: UILabel!
	@IBOutlet weak var workNumLabel: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	@IBOutlet weak var locLabel: UILabel!
  @IBOutlet weak var repairTypeLabel: UILabel!
	@IBOutlet weak var repairLocLabel: UILabel!
	@IBOutlet weak var repairDuraLabel: UILabel!
	
	var recModel:DamRecModel?
	var detailModel:DamaDetailModel?
	
	
	let size = UIScreen.main.bounds.size;
	
	let kSectionDamImg = 2
	let kRowIdxImg = 1
	let kSectionLiveImg = 3
	let kRowIdxLiveImg = 1
	
	var damPicAry:Array<Any>?
	var livePicAry:Array<Any>?

	//MARK:- public
	static func DetailControl() -> UIViewController{
		let storyboard = UIStoryboard.init(name: "Driver", bundle: nil)
		let control = storyboard.instantiateViewController(withIdentifier: "DriDamQueryDetailController")
		return control;
	}
	
	
	//MARK:- override
	override func viewDidLoad() {
		self.setupMediaViews()
		self.setupUI()
		self.setupTable()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "playerSegue"{
		}
	}
	
	//MARK:- setup tableview update UI
	private func setupTable() -> Void {
		self.tableView.es.addPullToRefresh {
			[unowned self] in
			if let model = self.recModel{
				self.fetchDamageDetailData(recModel: model)
			}
		}
		self.tableView.es.startPullToRefresh()
	}
	
	
	private func setupUI() -> Void {
		let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(DriDamQueryDetailController.tapEndViewEdit))
		self.view.addGestureRecognizer(tapGesture)
		self.title = "车损报备详情"
	}
	
	func setupMediaViews() -> Void {
		//损坏图片
		self.damImgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("damImgsView item click")
			if let imgs = self.damPicAry{
				self.showImgAt(idx:idx,imgs: imgs)
			}
		};
		
		//实时拍照图片
		self.liveImgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("damImgsView item click")
			if let imgs = self.livePicAry{
				self.showImgAt(idx:idx,imgs: imgs)
			}
		};
	}
	
  //MARK:- update UI
	///模型更新界面。
	func updateUIByDamageDetailModel(model: DamaDetailModel){
		self.damPicAry = Array.init()
		self.livePicAry = Array.init()
		self.reportNumLabel.text = model.vehicleDamageCode
		self.workNumLabel.text = model.listCode
		//    self.stateLabel.text = model.
		self.repairTypeLabel.text = model.repairType
		self.repairLocLabel.text = model.repairAddress
		self.repairDuraLabel.text = model.repairTime
		
		let longiDou = (model.longtiude as NSString).doubleValue
		let latDou = (model.latitude as NSString).doubleValue
		let longi = String(format: "%.2f", longiDou)
		let lat = String(format: "%.2f", latDou)
    let localStr = "(" + longi + "," + lat + ")"
		self.locLabel.text = localStr
		
		if model.damageUrl.isEmpty == false {
			let damPics = model.damageUrl.components(separatedBy: ",")
			for url in damPics{
				self.damPicAry?.append(url)
			}
		}
		if model.liveActionPic.isEmpty == false {
			let livePics = model.liveActionPic.components(separatedBy: ",")
			for url in livePics{
				self.livePicAry?.append(url)
			}
			
		}
//		self.damPicAry?.append("http://www.ziticq.com/upload/image/20190919/5d82e5dd1f193.png")
		if let imgsAry = self.damPicAry {
			self.damImgsView.updateUI(imgs: imgsAry, type: .imgRemote, addAble: false)
		}
		
		if let imgsAry = self.livePicAry {
			self.liveImgsView.updateUI(imgs: imgsAry, type: .imgRemote, addAble: false)
		}
		self.tableView.reloadData()
	}
	

	//展示图片预览
	func showImgAt(idx:Int, imgs:Array<Any>) -> Void {
		let loader = HTBrowserLoader()
		let dataSource = JXNetworkingDataSource(photoLoader: loader, numberOfItems: {() -> Int in
			return imgs.count
		}, placeholder: { (index) -> UIImage? in
			return UIImage(named: "img_placeholder")
		}) {(index) -> String? in
			if let url = imgs[index] as? String{
				return url
			}else{
				return ""
			}
		}
		// 视图代理，实现了光点型页码指示器
		let delegate = JXDefaultPageControlDelegate()
		// 转场动画
		let trans = JXPhotoBrowserFadeTransitioning.init()
		// 打开浏览器
		JXPhotoBrowser(dataSource: dataSource, delegate: delegate, transDelegate: trans)
			.show(pageIndex: idx)
	}
	

	//MARK:- selectors
	//确认
	@IBAction func clickConfirmBtn(_ sender: Any) {
		
	}
	
	@objc func tapEndViewEdit() -> Void {
		self.view.endEditing(true)
	}
	
	
	//MARK:- tableView delegate
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == kSectionDamImg{
			if indexPath.row == kRowIdxImg{
				let count = self.damPicAry?.count ?? 0
				return DriVideoView.viewHeightBy(itemCount: count)
			}else{
				return 44;
			}
		}else if indexPath.section == kSectionLiveImg{
			if indexPath.row == kRowIdxLiveImg{
				let count = self.livePicAry?.count ?? 0
				return DriVideoView.viewHeightBy(itemCount: count)
			}else{
				return 44;
			}
		}else{
			return 44;
		}
	}
	
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	
	
	//MARK:- request server
	func fetchDamageDetailData(recModel: DamRecModel) -> Void {
		let damCode = recModel.vehicleDamageCode
		let req = DamaDetailReq(damCode: damCode)
		STNetworking<DamaDetailModel>(stRequest:req) {
			[unowned self] resp in
			self.tableView.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.detailModel = resp.data
				if let model = self.detailModel{
					self.updateUIByDamageDetailModel(model:model)
				}
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
}
