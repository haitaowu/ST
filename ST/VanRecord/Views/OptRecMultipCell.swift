//
//  OptRecMultipCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation


class OptRecMultipCell: OptRecSingleCell {
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var optTypeLabel: UILabel!
	@IBOutlet weak var optManLabel: UILabel!
	@IBOutlet weak var numBackLabel: UILabel!
	@IBOutlet weak var numAheadLabel: UILabel!
	@IBOutlet weak var numSideLabel: UILabel!
	
	//MARK:- init cell
	override class func cellHeight(data: Any?) -> CGFloat{
		return 250;
	}
	
	//MARK:- update ui
	func updateUI(model: OptDataModel) -> Void {
		self.dateLabel.text = model.scanDate
		self.optTypeLabel.text = model.operteType
		self.optManLabel.text = model.scanMan
		self.numBackLabel.text = model.sendsealScanBackDoor
		self.numAheadLabel.text = model.sendsealScanAhead
		self.numSideLabel.text = model.sendsealScanMittertor
	}
	
	
	
	
}
