//
//  AnnouceQueryController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ESPullToRefresh



class AnnouceQueryController: UIViewController,UITableViewDelegate,UITableViewDataSource{
  
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
  
  

  
  //MARK:- request server
  ///请求公告数据
  func fetchAnnoDatas(req: STRequest) -> Void {
    STNetworking<[AnnoModel]>(stRequest:req) {
      [unowned self] resp in
      self.tableView.es.stopPullToRefresh()
      if resp.stauts == Status.Success.rawValue{
        self.dataAry = resp.data
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


