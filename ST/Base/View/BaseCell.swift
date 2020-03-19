//
//  BaseCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class BaseCell: UITableViewCell {
    
    
    //MARK:- static
    static func cellNib() -> UINib {
        let clsName = self.clsName()
        let nib = UINib(nibName:clsName , bundle: nil);
        return nib;
    }
    
    static func clsName() -> String {
        return String(describing: self.classForCoder());
    }
    
    static func cellID() -> String {
        let clsName = self.clsName();
        return clsName + "ID";
    }
    
    class func cellHeight(data: Any?) -> CGFloat{
        return 44;
    }
    
    
}
