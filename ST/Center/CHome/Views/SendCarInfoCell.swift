//
//  SendCarInfoCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class SendCarInfoCell: BaseCell {
  @IBOutlet weak var txtLabel: UILabel!

  
  //MARK:- override
  override class func cellHeight(data: Any?) -> CGFloat{
    if let model = data as?  EmpSendCarModel{
      let title = model.content
      let font = UIFont.systemFont(ofSize: 17)
      let screenWidth = UIScreen.main.bounds.size.width
      let limitW = screenWidth - 10 * 2
      let height = title.strHeightWith(font: font, limitWidth: limitW)
      return height
    }else{
      return 40;
    }
  }
  
  
  //MARK:- update ui by model
	func updateUIBy(model: EmpSendCarModel){
		self.txtLabel.text = model.content
	}
  
	
	
    
}
