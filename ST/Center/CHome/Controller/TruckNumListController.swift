//
//  TruckNumListController.swift
//  ST
//
//  Created by taotao on 2019/12/14.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation

typealias SelectTruckNumBlock = (_ model: TruckNumModel) -> Void



class TruckNumListController: UIViewController{
	
  //MARK:- IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK:- variables
	var truckNumAry:Array<TruckNumModel>?
	var dataAry:Array<TruckNumModel>?
	var selectNumBlock:SelectTruckNumBlock?

	
	//MARK:- overrides
	override func viewDidLoad() {
		self.title = "选择车牌"
		let searchBar = UISearchBar(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
		searchBar.delegate = self
		self.tableView.tableHeaderView = searchBar
		self.dataAry = self.truckNumAry
		self.tableView.keyboardDismissMode = .onDrag
		self.tableView.reloadData()
	}
}



extension TruckNumListController :UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate
{
	//MARK:- UISearchBarDelegate
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			self.dataAry = self.truckNumAry
		}else{
			self.dataAry = self.truckNumAry?.filter{
				$0.truckNum.contains(searchText)
			}
		}
		self.tableView.reloadData()
	}
	
	
	//MARK:- UITableView data source
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataAry?.count ?? 0
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "TruckNumCellID")
		if cell == nil{
			cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "TruckNumCellID")
		}
		
		if let model = self.dataAry?[indexPath.row]{
			cell?.textLabel?.text = model.truckNum
		}
		return cell!
	}
	
	//MARK:- UITableView delegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let model = self.dataAry?[indexPath.row],let block = self.selectNumBlock{
			block(model)
		}
	}
	
	
	
	
	
}
