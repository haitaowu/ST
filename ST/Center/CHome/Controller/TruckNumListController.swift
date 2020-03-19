//
//  TruckNumListController.swift
//  ST
//
//  Created by taotao on 2019/12/14.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation

typealias SelectTruckNumBlock = (_ model: TruckNumModel) -> Void



class TruckNumListController: UIViewController,UITableViewDataSource,UITableViewDelegate{
  //MARK:- IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK:- variables
  var truckNumAry:Array<TruckNumModel>?
	var selectNumBlock:SelectTruckNumBlock?
  
  //MARK:- overrides
  override func viewDidLoad() {
    self.title = "选择车牌"
  }
  
  //MARK:- UITableView data source
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.truckNumAry?.count ?? 0
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "TruckNumCellID")
    if cell == nil{
      cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "TruckNumCellID")
    }
    
    if let model = self.truckNumAry?[indexPath.row]{
      cell?.textLabel?.text = model.truckNum
    }
    return cell!
  }
  
  
  //MARK:- UITableView delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let model = self.truckNumAry?[indexPath.row],let block = self.selectNumBlock{
			block(model)
		}
  }
  
  
	
}
