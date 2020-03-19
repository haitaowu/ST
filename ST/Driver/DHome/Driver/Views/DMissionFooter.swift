//
//  DMissionFooter.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class DMissionFooter: UITableViewHeaderFooterView {
  @IBOutlet weak var txtLabel: UILabel!
  
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
  
  func updateUI(model:UnFinishedModel){
    self.txtLabel.text = model.bakNextStaTion
  }
}
