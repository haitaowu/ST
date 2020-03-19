//
//  OptRecSingleCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

enum OptRecordCellType:String {
    case  reportType = "report_type",verifyResult = "verify_result" ,optResult = "opt_result"
}



class OptRecSingleCell: BaseCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    var cellType:String?
    
    
    //MARK:- init cell
    public func setupCell(dataStr: String) -> Void {
    }
    
    
    override class func cellHeight(data: Any?) -> CGFloat{
        return 120;
    }

}
