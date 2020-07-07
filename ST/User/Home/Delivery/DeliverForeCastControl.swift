//
//  DeliverForeCastControl.swift
//  ST
//
//  Created by taotao on 2020/7/5.
//  Copyright © 2020 HTT. All rights reserved.
//

import UIKit


class DeliverForeCastControl: UITableViewController{
	enum DeliveryType: String {
		case send = "0",arrive = "1" ,record = "2"
	}
	
	var deliType: DeliveryType = .send
	
	//MARK: - overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		if deliType == .arrive{
			self.title = "网点到件预报"
		}else if deliType == .record{
			self.title = "网点录单预报"
		}else{
			self.title = "中心发件预报"
		}
		self.tableView.register(ForecastCell.cellNib(), forCellReuseIdentifier: ForecastCell.cellID())
	}

	
	
	//MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return ForecastCell.cellHeight(data: nil)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.cellID())
		if let fCell = cell as? ForecastCell{
			fCell.updateUI()
			fCell.printBlock = {
				[unowned self] in
				print("click print clock baby!!!")
			}
		}
		return cell!
	}
	
	
	
}
