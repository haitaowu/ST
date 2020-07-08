//
//  DeliverForeCastControl.swift
//  ST
//
//  Created by taotao on 2020/7/5.
//  Copyright © 2020 HTT. All rights reserved.
//

import UIKit
import BRPickerView


class DeliverForeCastControl: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dateField: UITextField!
  
  var datePicker: BRDatePickerView?
  
  enum DeliveryType: String {
		case send = "0",arrive = "1" ,record = "2"
	}
	
	var deliType: DeliveryType = .send
	
	//MARK: - overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.dateField.addRightBtn(imgName: "date",margin: 8,  action: #selector(showDatePicker), target: self)
		if deliType == .arrive{
			self.title = "网点到件预报"
		}else if deliType == .record{
			self.title = "网点录单预报"
		}else{
			self.title = "中心发件预报"
		}
		self.tableView.allowsSelection = false
		self.tableView.register(ForecastCell.cellNib(), forCellReuseIdentifier: ForecastCell.cellID())
	}

  
  @objc func showDatePicker(){
    let today = Date()
//    let minDate = today.dateAdd(year: -1)
    let datePicker = BRDatePickerView(pickerMode: .YMD)
    self.datePicker = datePicker
    let resetBtn = UIButton(frame: CGRect(x: 80, y: 0, width: 40, height: 44))
    resetBtn.addTarget(self, action: #selector(resetDate), for: .touchUpInside)
    resetBtn.setTitle("重置", for: .normal)
    resetBtn.setTitleColor(UIColor.appBlue, for: .normal)
    resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    datePicker.addSubView(toTitleBar: resetBtn)
    
    
    datePicker.title = "请选择日期"
    datePicker.pickerStyle = BRPickerStyle(themeColor: UIColor.appBlue)
    datePicker.selectDate = today
//    datePicker.minDate = minDate
//    datePicker.maxDate = today
    datePicker.resultBlock = {
      [unowned self] (date, dateStr) in
      self.dateField.text = dateStr
      print("picker date \(dateStr)")
    }
    datePicker.show()
  }
  
  @objc func resetDate(){
    self.dateField.text = ""
	self.datePicker?.dismiss()
  }
  
	//MARK:- UITextFieldDelegate
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    print("textFieldShouldBeginEditing....")
    return false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
  
  //MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.001
  }
  
  //MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return ForecastCell.cellHeight(data: nil)
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.cellID())
    if let fCell = cell as? ForecastCell{
      fCell.updateUI()
      fCell.printBlock = {
        [unowned self] in
        print("click print clock baby!!!")
        let control = DeliverBillDetailControl.make()
        self.navigationController?.pushViewController(control, animated: true)
      }
    }
    return cell!
  }
  
  
  
}
