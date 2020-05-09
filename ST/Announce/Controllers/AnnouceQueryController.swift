//
//  AnnouceQueryController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh



class AnnouceQueryController: BaseController,UITableViewDelegate,UITableViewDataSource{
  
  @IBOutlet weak var tableView: UITableView!

  var dataAry:Array<AnnoModel>?
  var queryReq:STRequest?
  

  
  //MARK:- Overrides
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad();
    self.basicInitUI()
    self.basicInitTable()
  }
  
  //init tableView
  private func basicInitTable(){
		self.tableView.emptyDataSetSource = self
		self.tableView.emptyDataSetDelegate = self
    let nibNotiCell = AnnounceCell.cellNib();
    self.tableView.register(nibNotiCell, forCellReuseIdentifier: AnnounceCell.cellID())
    self.tableView.es.addPullToRefresh {
      [unowned self] in
      if let req = self.queryReq{
        self.fetchAnnoDatas(req: req)
      }else{
        self.tableView.es.stopPullToRefresh()
      }
    }
    self.tableView.es.startPullToRefresh()
  }
  
  //init base ui
  private func basicInitUI(){
    self.title = "公告查询结果";
    self.navigationController?.navigationBar.isTranslucent = false
  }
  

  //MARK:- tableView datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataAry?.count ?? 0
  }
  
	
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let  cell = tableView.dequeueReusableCell(withIdentifier: AnnounceCell.cellID()) as? AnnounceCell
    if let model = self.dataAry?[indexPath.row]{
      cell?.updateCellUI(model: model)
    }
    return cell!;
  }
	
  
  //MARK:- tableView delegate
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40;
  }
  
	
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let control = CenAnnounceDetailController(nibName: "CenAnnounceDetailController", bundle: nil)
    if let model = self.dataAry?[indexPath.row]{
      control.model = model
    }
    control.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(control, animated: true)
  }
	
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.001
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
	
	///是否第一次加载数据
	func firstLoadData()->Bool{
		if self.dataAry == nil{
			return true
		}else{
			return false
		}
	}
	
	///是否有公告信息
	func hasAnnData()->Bool{
		if self.firstLoadData() == false{
			if let data = self.dataAry{
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
  ///请求公告数据
  func fetchAnnoDatas(req: STRequest) -> Void {
    STNetworking<[AnnoModel]>(stRequest:req) {
      [unowned self] resp in
      self.tableView.es.stopPullToRefresh()
			self.dataAry = []
      if resp.stauts == Status.Success.rawValue{
        self.dataAry = resp.data
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


