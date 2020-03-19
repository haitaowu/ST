//
//  DriHeavQueryResController.swift
//  ST
//
//  Created by taotao on 2019/5/27.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ESPullToRefresh



class DriHeavQueryResController: UIViewController,UITableViewDelegate,UITableViewDataSource{
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var titlesLabelContainer: UIView!
  @IBOutlet var titlesAry: [UILabel]!
  
  var paramsQuery:[String: String]?


  var dataAry:Array<HeavyRecModel>?

  
  static func HeavQueryControl()-> UIViewController{
    let control = DriHeavQueryResController(nibName: "DriHeavQueryResController", bundle: nil)
    control.hidesBottomBarWhenPushed = true;
    return control
  }
  
  //MARK:- Overrides
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.basicSetupUI()
    self.setNaviBar()
    self.setupTable()
  }
  
  //MARK:- setup navbar tableView
   func basicSetupUI() -> Void {
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
  
  private func setNaviBar(){
    self.title = "堵车报备查询结果";
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  
  private func setupTable(){
    let nibNotiCell = DriHeavQueryCell.cellNib();
    self.tableView.register(nibNotiCell, forCellReuseIdentifier: DriHeavQueryCell.cellID())
    self.tableView.es.addPullToRefresh {
      [unowned self] in
      if let params = self.paramsQuery{
        self.fetchHeavDatas(params: params)
      }
    }
    self.tableView.es.startPullToRefresh()
  }
  
  
  //MARK:- SELECTORS
  //点击开始查询
  @IBAction func clickToQuery(_ sender: UIButton) {
    self.view.endEditing(true)
    sender.isSelected = !sender.isSelected
    if sender.isSelected{
      self.tableView.es.startPullToRefresh()
    }else{
      self.tableView.reloadData()
    }
    
  }
  
  //更多
  
  
  
  //MARK:- tableView datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.dataAry?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DriHeavQueryCell.cellID()) as! DriHeavQueryCell
    let model:HeavyRecModel? = self.dataAry?[indexPath.row]
    if let heavModel = model{
      cell.updateUI(model: heavModel)
    }
    return cell
  }
  
  //MARK:- tableView delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model:HeavyRecModel? = self.dataAry?[indexPath.row]
    if let heavModel = model{
      let control = DriHeavyDetailController.DetailControl() as! DriHeavyDetailController
      control.recModel = heavModel
      self.navigationController?.pushViewController(control, animated: true)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40;
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.001
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.001
  }
  
 
  
  
  //MARK:- request server
  func fetchHeavDatas(params: [String: String]) -> Void {
    let req = HeavyRecReq(params: params)
    STNetworking<[HeavyRecModel]>(stRequest:req) {
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


