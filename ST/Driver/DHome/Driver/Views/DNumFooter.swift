//
//  DNumHeader.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class DNumFooter: BaseFooter{
 
  @IBOutlet weak var numLabel: UILabel!
  
  //MARK:- static
  static func footerHeight() -> CGFloat{
    return 40
  }
  
  func updateUIBy(model: UnFinishedModel) -> Void {
    let txtStr = "流水号"+model.sendCode
    self.numLabel.text = txtStr
  }
  
}
