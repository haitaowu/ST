//
//  VanRecordResController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh



class VanRecordResController: BaseController ,UITableViewDelegate,UITableViewDataSource{


	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var titlesLabelContainer: UIView!
	@IBOutlet var titlesAry: [UILabel]!
  
  var paramsQuery:(params:[String: String], req:STRequest?)?
  
	var recsAry:Array<SARecModel>?

	//MARK:- Overrides
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.basicSetupUI()
		self.setupTable()
		
	}
	
	//MARK:- setup ui
	func basicSetupUI() -> Void {
		self.title = "记录查询结果"
		let screenSize = UIScreen.main.bounds.size
		let titleSpace:CGFloat = 16
		let titlesWith = screenSize.width - CGFloat(self.titlesAry.count + 1) * titleSpace
		let titleLabelW = titlesWith / CGFloat(self.titlesAry.count)
		let titleLabelH = self.titlesLabelContainer.vHeight()
		for (idx,label) in self.titlesAry.enumerated(){
			let x = titleSpace + CGFloat(idx) * (titleLabelW + titleSpace)
			let frame = CGRect(x: x, y: 0, width: titleLabelW, height: titleLabelH)
			label.frame = frame
		}
	}
	
	//setup tableView
	func setupTable() -> Void {
		self.tableView.emptyDataSetSource = self
		self.tableView.emptyDataSetDelegate = self
		let nibNotiCell = VanRecCell.cellNib();
		self.tableView.register(nibNotiCell, forCellReuseIdentifier: VanRecCell.cellID())
		self.tableView.es.addPullToRefresh {
			[unowned self] in
			if let result = self.paramsQuery{
				let request:STRequest? = result.req
				let params = result.params
				guard let req = request else{return}
				self.fetchVanRecDatas(params: params, req: req)
			}
		}
		self.tableView.es.startPullToRefresh()
	}
	

	
	
	//MARK:- tableView datasource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.recsAry?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:VanRecCell? = tableView.dequeueReusableCell(withIdentifier: VanRecCell.cellID()) as? VanRecCell
		if let model = self.recsAry?[indexPath.row]{
			cell?.updateCellUI(model: model)
		}
		return cell!
	}
	
	//MARK:- tableView delegate
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40;
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let storyboard = UIStoryboard.init(name: "BaseUI", bundle: nil)
		let control = storyboard.instantiateViewController(withIdentifier: "VanRecordDetailControl")
		control.hidesBottomBarWhenPushed = true
		if let model = self.recsAry?[indexPath.row] , let recControl = control as? VanRecordDetailControl{
			recControl.vanRecModel = model
		}
		self.navigationController?.pushViewController(control, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	//MARK:- empty data
	///empty attributestring title
	func attri(title: String) -> NSAttributedString {
		let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.appLineColor]
		let attrStr = NSAttributedString(string: title, attributes: attributes)
		return attrStr
	}
	
	///emptyata button title
	func emptyBtnTitle() -> NSAttributedString {
		let title = "点我刷新试试"
		let attris = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.appBlue]
		let attriStr = NSAttributedString(string: title,attributes: attris)
		return attriStr
	}
	
	///是否第一次加载到车数据
	func firstLoadData()->Bool{
		if self.recsAry == nil{
			return true
		}else{
			return false
		}
	}
	
	///是否有公告信息
	func hasRecsData()->Bool{
		if self.firstLoadData() == false{
			if let data = self.recsAry{
				if data.count > 0{
					return true
				}else{
					return false
				}
			}else{
				return false
			}
		}else{
			return true
		}
	}
	
	
	//MARK:- override for DZNEmptyDataSetSource delegate
	override func titleForEmpty(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if self.hasRecsData() == false{
			let title = "暂无记录..."
			return self.attri(title: title)
		}else{
			return nil
		}
	}
	
	override func titleForEmptyBtn(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if self.hasRecsData() == false{
			return self.emptyBtnTitle()
		}else{
			return nil
		}
	}
	
	override func reloadViewData(scrollView: UIScrollView!) {
		self.tableView.es.startPullToRefresh()
	}
	
	
	//MARK:- request server
	///列表数据的请求
	func fetchVanRecDatas(params: [String: String], req: STRequest) -> Void {
		STNetworking<[SARecModel]>(stRequest:req) {
			[unowned self] resp in
			self.recsAry = []
			self.tableView.es.stopPullToRefresh()
			if resp.stauts == Status.Success.rawValue{
				self.recsAry = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
			self.tableView.reloadData()
			}?.resume()
	}

	
}


