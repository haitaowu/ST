//
//  VanRecCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation


class VanRecCell: BaseCell {
    @IBOutlet weak var vanNumLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    
    //MARK:-  public
    func updateCellUI(model: SARecModel) -> Void {
        self.vanNumLabel.text = model.truckNum
        self.routeLabel.text = model.lineName
        self.stateLabel.text = model.endScanType
    }
    
}
