//
//  MessageViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/26.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire



class MessageViewController: BaseController,UITableViewDelegate,UITableViewDataSource{
	@IBOutlet weak var tableView: UITableView!
	
	let cellReuserID = "noticeCellID"
	var noticesData:NSArray?
	
	//MARK:-  override methods
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.setupTabbarItem()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setupTabbarItem()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.navigationBar.isTranslucent = false
		self.title = "公告"
		self.setupTable()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	
	//MARK:- private
	private func setupTable(){
		let nib = UINib.init(nibName: "NoticeCell", bundle: nil)
		self.tableView.register(nib, forCellReuseIdentifier: cellReuserID)
		self.tableView.emptyDataSetSource = self
		self.tableView.emptyDataSetDelegate = self
		self.tableView.es.addPullToRefresh {
			[unowned self] in
			self.reqMessages()
		}
		self.tableView.es.startPullToRefresh()
	}
	
	private func setupTabbarItem(){
		self.tabBarItem = UITabBarItem(title: "消息", image:UIImage(named:"notification_disselected") , selectedImage: UIImage(named:"notification_selected"))
	}
	
	// MARK: - Table view data source
	//    func numberOfSections(in tableView: UITableView) -> Int {
	//        return 1
	//    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let array = self.noticesData{
			return array.count;
		}else{
			return 10;
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellReuserID, for: indexPath) as! NoticeCell
		if let array = self.noticesData{
			let notiData = array[indexPath.row]
			cell.noticeData = notiData as? NSDictionary
		}
		return cell
	}
	
	//MARK:- Table view delegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let vc = NoticeDetailController(nibName: "NoticeDetailController", bundle: nil)
		if let array = self.noticesData{
			let notiData = array[indexPath.row]
			vc.noticeData = notiData as? NSDictionary
		}
		vc.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	//MARK:- empty data
	///是否第一次加载数据
	func firstLoadData()->Bool{
		if self.noticesData == nil{
			return true
		}else{
			return false
		}
	}
	
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
	
	///是否有公告信息
	func hasAnnData()->Bool{
		if self.firstLoadData() == false{
			if self.noticesData?.count ?? 0 > 0{
				return true
			}else{
				return false
			}
		}else{
			return true
		}
	}
	
	
	//MARK:- override for DZNEmptyDataSetSource delegate
	override func titleForEmpty(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if self.hasAnnData() == false{
			let title = "暂无公告"
			return self.attri(title: title)
		}else{
			return nil
		}
	}
	
	override func titleForEmptyBtn(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString? {
		if self.hasAnnData() == false{
			return self.emptyBtnTitle()
		}else{
			return nil
		}
	}
	
	override func reloadViewData(scrollView: UIScrollView!) {
		self.tableView.es.startPullToRefresh()
	}
	
	//MARK:- request server
	func reqMessages() {
		let reqUrl = Consts.Server+Consts.BaseUrl+"/searchSiteNotice.do"
		Alamofire.request(reqUrl, method: .post, parameters: nil).responseJSON { response in
			self.noticesData = []
			self.tableView.es.stopPullToRefresh()
			if let json = response.result.value as? NSDictionary{
				if let data = json.value(forKey: "data"){
					self.noticesData = data as? NSArray
				}
			}
			self.tableView.reloadData()
		}
	}
	
}
