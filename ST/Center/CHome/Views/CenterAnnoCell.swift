//
//  CenterAnnoCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class CenterAnnoCell: BaseCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    //MARK:-  public
    func updateCellUI(model: EmpHomAnno) -> Void {
        self.dateLabel.text = model.noticeTime
        self.contentLabel.text = model.content
    }
    
}
