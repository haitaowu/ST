//
//  DriHeavyDetailController.swift
//  ST
//
//  Created by taotao on 2019/6/16.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0
import AVKit
import ESPullToRefresh




class DriHeavyDetailController: UITableViewController{
    
    
  
//  @IBOutlet weak var videosView: DriVideoView!
	///导航图片的view
  @IBOutlet weak var navContainer: DriVideoView!
	///实时拍摄图片的view
  @IBOutlet weak var liveContainer: DriVideoView!
  ///报备流水号
  @IBOutlet weak var reportNumLabel: UILabel!
  @IBOutlet weak var workNumLabel: UILabel!
  @IBOutlet weak var stateLabel: UILabel!
  @IBOutlet weak var reasonLabel: UILabel!
  @IBOutlet weak var locLabel: UILabel!
  
  var recModel:HeavyRecModel?
  var detailModel:HeavDetailModel?
  
  
  let size = UIScreen.main.bounds.size;

  let kSectionNavImg = 2
  let kRowIdxImg = 1
	
	let kSectionLiveImg = 3
  let kRowIdxLiveImg = 1
  
  var navImsAry:Array<Any>?
  var liveImsAry:Array<Any>?
  
  
  //MARK:- public
  static func DetailControl() -> UIViewController{
    let storyboard = UIStoryboard.init(name: "Driver", bundle: nil)
    let control = storyboard.instantiateViewController(withIdentifier: "DriHeavyDetailController")
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
	
	//MARK:- setup navbar tableView
	private func setupTable(){
		self.tableView.es.addPullToRefresh {
			[unowned self] in
			self.fetchHeavDetailDatas()
		}
		self.tableView.es.startPullToRefresh()
	}
  
  ///使用模型更新界面
  private func updateUIByDetailModel(model:HeavDetailModel){
    //报备流水号
    self.reportNumLabel.text = model.truckCode
    //作业流水号
    self.workNumLabel.text = model.linkCode
    self.stateLabel.text = model.endScanType
    self.reasonLabel.text = model.trafficJamReason
		let longiDou = (model.longtiude as NSString).doubleValue
		let latDou = (model.latitude as NSString).doubleValue
		let longi = String(format: "%.2f", longiDou)
		let lat = String(format: "%.2f", latDou)
    let localStr = "(" + longi + "," + lat + ")"
    self.locLabel.text = localStr
		
		//导航图片
		if model.navigationUrl.isEmpty == false {
			let navPics = model.navigationUrl.components(separatedBy: ",")
			for picStr in navPics{
				self.navImsAry?.append(picStr)
			}
		}
	
		if let imgsAry = self.navImsAry {
			self.navContainer.updateUI(imgs: imgsAry, type: .imgRemote, addAble: false)
		}
		
		//实时拍摄图片
		if model.jamPic.isEmpty == false {
			let navPics = model.jamPic.components(separatedBy: ",")
			for picStr in navPics{
				self.liveImsAry?.append(picStr)
			}
		}
		
		if let imgsAry = self.liveImsAry {
			self.liveContainer.updateUI(imgs: imgsAry, type: .imgRemote, addAble: false)
		}
		
	}
	
  private func setupMediaViews() -> Void {
    self.navImsAry = Array.init()
    self.liveImsAry = Array.init()
    
    //导航图片
    self.navContainer.clickBlock = {
      [unowned self] (idx, itemType) in
      print("navContainer item click")
      if let imgs = self.navImsAry{
        self.showImgAt(idx:idx,imgs: imgs)
      }
    };
    
    //实时拍摄图片
    self.liveContainer.clickBlock = {
      [unowned self] (idx, itemType) in
      print("liveContainer item click")
      if let imgs = self.liveImsAry{
        self.showImgAt(idx:idx,imgs: imgs)
      }
    };
  }
  
  func setupUI() -> Void {
    self.view.addDismissGesture()
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
    if indexPath.section == kSectionNavImg{
      if indexPath.row == kRowIdxImg{
        return DriVideoView.viewHeightBy(itemCount: (self.navImsAry?.count)!)
      }else{
        return 44;
      }
		}else if indexPath.section == kSectionLiveImg{
			if indexPath.row == kRowIdxLiveImg{
				return DriVideoView.viewHeightBy(itemCount: (self.liveImsAry?.count)!)
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
  func fetchHeavDetailDatas() -> Void {
    if let model = self.recModel{
      let truckCode = model.truckCode
      let req = HeavyDetailReq(carNum: truckCode)
      STNetworking<HeavDetailModel>(stRequest:req) {
        [unowned self] resp in
        self.tableView.es.stopPullToRefresh()
        if resp.stauts == Status.Success.rawValue{
          self.detailModel = resp.data
          self.tableView.reloadData()
          if let model = self.detailModel{
            self.updateUIByDetailModel(model: model)
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
  
  
  
  
}
