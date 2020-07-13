//
//  ForecastCell.swift
//  ST
//
//  Created by taotao on 2020/7/5.
//  Copyright © 2020 HTT. All rights reserved.
//

import UIKit

typealias PrintBillBlock = ([String: Any])-> Void

class ForecastCell: BaseCell {
  @IBOutlet weak var billNumber: UILabel!
  @IBOutlet weak var adrLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
	
	var billInfo:[String: Any]?

	var printBlock: PrintBillBlock?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override class func cellHeight(data: Any?) -> CGFloat {
		return 120
	}
	
	func updateUI(bill info: [String: Any]){
		self.billInfo = info
		self.billNumber.text = "8888888"
		
		if let adr = info["sendManAddress"] as? String{
			self.adrLabel.text = adr
		}
		
		if let billNum = info["bill"] as? String{
			self.billNumber.text = billNum
		}
		
		if let date = info["sendDate"] as? String{
			self.dateLabel.text = date
		}
		
	}
	
	//MARK:- selectors
	///点击打印
	@IBAction func printBill(_ sender: Any) {
		printBlock?(self.billInfo!)
	}
	
	
	
}
