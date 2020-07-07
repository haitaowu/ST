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
	
  
  
  
	public class func make() -> UIViewController{
		let storyboard = UIStoryboard.init(name: "BaseUI", bundle: nil);
		let control = storyboard.instantiateViewController(withIdentifier: "DeliverBillDetailControl");
		return control
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	//MARK:- SELECTORS
	@IBAction func toPrint(_ sender: Any) {
		
	}
	
	//MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.001
	}
	
	
}
