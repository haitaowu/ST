//
//  DeliverBillDetailControl.swift
//  ST
//
//  Created by taotao on 2020/7/7.
//  Copyright © 2020 HTT. All rights reserved.
//

import UIKit

class DeliverBillDetailControl: UITableViewController{
	@IBOutlet weak var senderField: UITextField!
	@IBOutlet weak var receiverField: UITextField!
	@IBOutlet weak var goodsInfoField: UITextField!
	@IBOutlet weak var piecesField: UITextField!
	@IBOutlet weak var weightField: UITextField!
	@IBOutlet weak var expressField: UITextField!
	@IBOutlet weak var resignField: UITextField!
	@IBOutlet weak var storeField: UITextField!
	@IBOutlet weak var payField: UITextField!
	@IBOutlet weak var baoField: UITextField!
	@IBOutlet weak var freightField: UITextField!
	
  
	var billInfo:[String: Any]?
  
  
	public class func make() -> UIViewController{
		let storyboard = UIStoryboard.init(name: "BaseUI", bundle: nil);
		let control = storyboard.instantiateViewController(withIdentifier: "DeliverBillDetailControl");
		return control
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let info = self.billInfo{
			self.updateUIBy(billInfo: info)
		}
	}
	
	
	//MARK:- update ui
	func updateUIBy(billInfo: [String: Any]){
		if let sender = billInfo["sendMan"] as? String{
			self.senderField.text = sender
		}
		if let receiver = billInfo["acceptMan"] as? String{
			self.receiverField.text = receiver
		}
		
		if let goodsName = billInfo["goodsName"] as? String{
			self.goodsInfoField.text = goodsName
		}
		
		if let pieceNumber = billInfo["pieceNumber"]{
			let pieceStr = "\(pieceNumber)"
			self.piecesField.text = pieceStr
		}
		
		if let feeWeight = billInfo["feeWeight"]{
			let feeWeightStr = "\(feeWeight)"
			self.weightField.text = feeWeightStr
		}
		
		if let dispatchMode = billInfo["dispatchMode"] as? String{
			self.expressField.text = dispatchMode
		}
		
		if let blReturnBill = billInfo["blReturnBill"]{
			let resign = "\(blReturnBill)"
			self.resignField.text = resign
		}
		
		if let blIntoWarehouse = billInfo["blIntoWarehouse"]{
			let store = "\(blIntoWarehouse)"
			self.storeField.text = store
		}
		
		if let topayment = billInfo["topayment"]{
			let topaymentStr = "\(topayment)"
			self.payField.text = topaymentStr
		}
		
		//baojiafei
		if let insureValue = billInfo["insureValue"]{
			let insureValueStr = "\(insureValue)"
			self.baoField.text = insureValueStr
		}
		//yun fei
		if let freight = billInfo["freight"]{
			let freightStr = "\(freight)"
			self.freightField.text = freightStr
		}
	}
	
	//MARK:- SELECTORS
	@IBAction func toPrint(_ sender: Any) {
		let control  = DeliverBillPrinterController(nibName: "DeliverBillPrinterController", bundle: nil)
		control.billInfo = self.billInfo
		self.navigationController?.pushViewController(control, animated: true)
	}
	
	
	//MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	
}
