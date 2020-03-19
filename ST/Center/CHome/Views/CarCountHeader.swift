//
//  CarCountHeader.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class CarCountHeader: BaseHeader {
  @IBOutlet weak var txtLabel: UILabel!
  
	func updateUIBy(model: EmpHomeSendModel){
    let countStr = String(model.count)
		let title = "目前还有\(countStr)辆车前往我中心"
    let attriTxt = title.attriStr(highlightStr: countStr, color: .red)
    self.txtLabel.attributedText = attriTxt
	}
  
	//MARK:- static
	static func headerHeight() -> CGFloat{
		return 40
	}
}
