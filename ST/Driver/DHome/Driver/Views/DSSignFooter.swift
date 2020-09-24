//
//  DSSignFooter.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

typealias SignSendBlock = ()->Void

class DSSignFooter: UITableViewHeaderFooterView {
	var carInfo:UnFinishedModel?
	var signBlock:SignSendBlock?
  @IBOutlet weak var signBtn: UIButton!
  
  //MARK:- static
  static func footerNib() -> UINib {
    let clsName = self.clsName()
    let nib = UINib(nibName:clsName , bundle: nil);
    return nib;
  }
  
  static func clsName() -> String {
    return String(describing: self.classForCoder());
  }
  
  static func footerID() -> String {
    let clsName = self.clsName();
    return clsName + "ID";
  }
  
  static func footerHeight() -> CGFloat{
    return 50
  }
  
	
	//MARK:- public 
	func updateUI(model:UnFinishedModel?,signBlock: SignSendBlock?){
		self.enableSignBtn()
		self.signBlock = signBlock
		return;
		
		if let carInfo = model{
			self.carInfo = carInfo
			if carInfo.deiverStatus == "0" {
				self.enableSignBtn()
			}else{
				self.disableSignBtn()
			}
		}else{
			self.disableSignBtn()
		}
		
	}
	
  //MARK:- selectors
  @IBAction func clickSignBtn(_ sender: Any) {
    if let block = self.signBlock{
      block()
    }
  }
  
  
	//MARK:- update ui
	///enable assign button
	func enableSignBtn(){
		self.signBtn.isEnabled = true
		self.signBtn.setTitle("发车登记", for: .normal)
		self.signBtn.setTitleColor(UIColor.white, for: .normal)
		self.signBtn.backgroundColor = UIColor.appMajor
	}
	
	///disable assign button
	func disableSignBtn(){
		self.signBtn.isEnabled = false
		self.signBtn.setTitle("已发车登记", for: .disabled)
		self.signBtn.setTitleColor(UIColor.white, for: .disabled)
		self.signBtn.backgroundColor = UIColor.lightGray
	}
	
}
