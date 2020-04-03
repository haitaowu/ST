//
//  VanRecordDetailControl.swift
//  ST
//
//  Created by taotao on 2019/7/23.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation


class VanRecordDetailControl: UITableViewController{
	
	@IBOutlet weak var imgsView: DriVideoView!
	
	let RowIdxLoadState = 9
  let SectionInfoIdx = 0
	let SectionSendIdx = 1
	let SectionArriveIdx = 2
	let SectionOperationIdx = 3
	
	@IBOutlet weak var listCodeLabel: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	
	//发车 labels
	//是否外调加班车 0 否 1是
	@IBOutlet weak var tmpTypeLabel: UILabel!
	@IBOutlet weak var trukNumLabel: UILabel!
	@IBOutlet weak var truckTypeLabel: UILabel!
//	挂车号
	@IBOutlet weak var truckCarNumLabel: UILabel!
	@IBOutlet weak var lineLabel: UILabel!
	@IBOutlet weak var optManLabel: UILabel!
	@IBOutlet weak var sendDateLabel: UILabel!
	
	//到车 labels
	@IBOutlet weak var siteLabel: UILabel!
	@IBOutlet weak var arrOptManLabel: UILabel!
	@IBOutlet weak var arrDateLabel: UILabel!
	
	
	var vanRecModel:SARecModel?
	var vanRecDetailModel:DriSADetailModel?
	var imgesAry:Array<Any>?
	
	//MARK:- override
	override func viewDidLoad() {
		self.setupUIImgView()
		self.setupTable()
		if let model = self.vanRecModel{
			self.fetchRecordDetail(recModel: model)
		}
	}
	
	//MARK:- setup ui
	func setupUIImgView() -> Void {
		self.imgesAry = Array.init()
//		self.imgesAry?.append(UIImage(named: "plus")!)
		//图片
		self.imgsView.clickBlock = {
			[unowned self] (idx, itemType) in
			print("imgsView item click")
			if let imgs = self.imgesAry{
				self.showImgPreviewAt(idx:idx,imgs: imgs)
			}
		}
		

	}
	
	//初始化tableView
	func setupTable(){
		self.tableView.register(OperationHeader.headerNib(), forHeaderFooterViewReuseIdentifier: OperationHeader.headerID())
//    self.tableView.register(OptRecSingleCell.cellNib(), forCellReuseIdentifier: OptRecSingleCell.cellID())
		self.tableView.register(OptRecMultipCell.cellNib(), forCellReuseIdentifier: OptRecMultipCell.cellID())
	}
	
	//展示图片预览
	func showImgPreviewAt(idx:Int, imgs:Array<Any>) -> Void {
		// 数据源
//		let dataSource = JXLocalDataSource(numberOfItems: {
//			// 共有多少项
//			return imgs.count
//		}, localImage: { index -> UIImage? in
//			// 每一项的图片对象
//			return imgs[index] as? UIImage
//		})
//		// 打开浏览器
//		JXPhotoBrowser(dataSource: dataSource).show(pageIndex: idx)
		
		
		let loader = HTBrowserLoader()
		let dataSource = JXNetworkingDataSource(photoLoader: loader, numberOfItems: {[unowned self] () -> Int in
			return self.imgesAry?.count ?? 0
		}, placeholder: { (index) -> UIImage? in
			return UIImage(named: "img_placeholder")
		}) {(index) -> String? in
			if let imgs = self.imgesAry, let url = imgs[index] as? String{
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
	
	//取得数据后更新tableView界面
	func reloadTableViewUI(){
		if let detailModel = self.vanRecDetailModel{
			let sendData = detailModel.sendData
			let comeData = detailModel.comeData
			self.listCodeLabel.text = detailModel.listCode
			self.stateLabel.text = detailModel.truckState
			self.tmpTypeLabel.text = sendData.blTempWorkStr()
			self.trukNumLabel.text = sendData.truckNum
			self.truckTypeLabel.text = sendData.truckType
			self.truckCarNumLabel.text = sendData.truckCarNum
			self.lineLabel.text = sendData.lineName
			self.optManLabel.text = sendData.scanMan
			self.sendDateLabel.text = sendData.scanDate
			self.siteLabel.text = comeData.scanSite
			self.arrOptManLabel.text = comeData.scanMan
			self.arrDateLabel.text = comeData.scanDate
			if detailModel.sendData.picUrl.isEmpty == false{
				let picUrl = detailModel.sendData.picUrl
				let imgAry = picUrl.components(separatedBy: ",")
				for picStr in imgAry {
					guard picStr.isEmpty == false else{continue}
					let imgStr = picStr
					self.imgesAry?.append(imgStr)
				}
			}
			
//			for idx in 1...4{
//				let imgStr = Consts.ImgServer+"AppCar/Damage/201912/20191231/124305c4z.jpg"
//				self.imgesAry?.append(imgStr)
//			}
			
			if let imgsAry = self.imgesAry {
				self.imgsView.updateUI(imgs: imgsAry, type: .imgRemote, addAble: false)
			}
		}
		
	}
	
	//MARK:- UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == SectionOperationIdx{
      if let detailModel = self.vanRecDetailModel{
        return detailModel.listInfo.count
      }else{
        return 5
      }
		}else{
			return super.tableView(tableView, numberOfRowsInSection: section)
		}
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return super.numberOfSections(in: tableView)
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == SectionOperationIdx{
      let cell = tableView.dequeueReusableCell(withIdentifier: OptRecMultipCell.cellID()) as! OptRecMultipCell
      if let detailModel = self.vanRecDetailModel{
        let model = detailModel.listInfo[indexPath.row]
        cell.updateUI(model: model)
      }
      return cell
		}else{
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
	
	override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		if indexPath.section == SectionOperationIdx{
			return tableView.numberOfRows(inSection: SectionOperationIdx)
		}else{
			return super.tableView(tableView, indentationLevelForRowAt: indexPath)
		}
	}
	
	
	//MARK:- UITableViewDelegate
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == SectionSendIdx{
			if indexPath.row == RowIdxLoadState{
				return DriVideoView.viewHeightBy(itemCount: (self.imgesAry?.count)!)
			}else{
				return 44;
			}
		}else if indexPath.section == SectionOperationIdx{
      return CGFloat(OptRecMultipCell.cellHeight(data: nil))
		}else{
			return 44;
		}
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == SectionOperationIdx{
			return tableView.dequeueReusableHeaderFooterView(withIdentifier: OperationHeader.headerID())
		}else{
			return super.tableView(tableView, viewForHeaderInSection: section)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == SectionOperationIdx{
			return OperationHeader.headerHeight()
		}else{
			return 0.001
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 10
	}
	
	//MARK:- request server
	func fetchRecordDetail(recModel:SARecModel) -> Void {
		let req = DriSARecDetailReq(listCode: recModel.listCode)
		STNetworking<DriSADetailModel>(stRequest:req) {
			[unowned self] resp in
			self.tableView.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.vanRecDetailModel = resp.data
				self.reloadTableViewUI()
				self.tableView.reloadData()
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			}?.resume()
	}
	
	
}
