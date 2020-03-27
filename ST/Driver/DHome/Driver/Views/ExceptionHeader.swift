//
//  DMissionFooter.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class ExceptionHeader: BaseHeader {
	
  @IBOutlet weak var txtLabel: UILabel!

  static func headerHeight() -> CGFloat{
    return 50
  }
  
  func updateUI(model:UnFinishedModel){
    self.txtLabel.text = model.bakNextStaTion
  }
	
	
}
