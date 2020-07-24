//
//  MenuRSHeader.swift
//  ST
//
//  Created by taotao on 2020/5/4.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation


class MenuRSHeader: UITableViewHeaderFooterView {
  
  @IBOutlet weak var titleLabel: UILabel!
  
	class func headerNib() -> UINib{
		let nib = UINib.init(nibName: "MenuRSHeader", bundle: nil)
		return nib
	}
  
	
	class func headerID() -> String{
		return "MenuRSHeaderID"
	}
	
  //MARK:- update ui
  func updateBy(title: String){
    self.titleLabel.text = title
  }
	
	
}
