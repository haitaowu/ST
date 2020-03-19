//
//  DNumHeader.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class DNumHeader: BaseHeader {
 
  @IBOutlet weak var numLabel: UILabel!
  
  //MARK:- static
  static func headerHeight() -> CGFloat{
    return 50
  }
  
  func updateUIBy(model: UnFinishedModel) -> Void {
    let txtStr = "流水号"+model.sendCode
    self.numLabel.text = txtStr
  }
  
}
