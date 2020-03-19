//
//  TruckRouteListController.swift
//  ST
//
//  Created by taotao on 2019/12/14.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation

typealias SelectTruckRouteBlock = (_ model: TruckRouteModel) -> Void



class TruckRouteListController: UIViewController,UITableViewDataSource,UITableViewDelegate{
  //MARK:- IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK:- variables
  var truckRouteAry:Array<TruckRouteModel>?
	var selectNumBlock:SelectTruckRouteBlock?
  
  //MARK:- overrides
  override func viewDidLoad() {
    self.title = "选择路由"
  }
  
  //MARK:- UITableView data source
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.truckRouteAry?.count ?? 0
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "TruckRouteCellID")
    if cell == nil{
      cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "TruckRouteCellID")
    }
    
    if let model = self.truckRouteAry?[indexPath.row]{
			cell?.textLabel?.text = model.lineName
    }
    return cell!
  }
  
  
  //MARK:- UITableView delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let model = self.truckRouteAry?[indexPath.row],let block = self.selectNumBlock{
			block(model)
		}
  }
  
  
	
}
