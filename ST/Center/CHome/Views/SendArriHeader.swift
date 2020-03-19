//
//  SendArriHeader.swift
//  ST
//
//  Created by taotao on 2019/6/1.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

enum ArriverSendType:Int{
    case arrive = 0, send = 1
}

typealias SelectSABlock = (_ type:ArriverSendType) -> ()

class SendArriHeader: BaseHeader {
    
    @IBOutlet weak var sendCarBtn: UIButton!
    @IBOutlet weak var arriveCarBtn: UIButton!
    
    var typeBlock:SelectSABlock?
    
   //MARK:- overrride
    override func layoutSubviews() {
        super.layoutSubviews();
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendCarBtn.addCorner(radius: 20, color: UIColor.green, borderWidth: 0.8)
        self.arriveCarBtn.addCorner(radius: 20, color: UIColor.red, borderWidth: 0.8)
    }
    
    
    //MARK:- static
    static func headerHeight() -> CGFloat{
        return 60
    }
    
    //MARK:- selectors
    @IBAction func clickTypeBtn(_ sender: UIButton) {
        if let block = self.typeBlock, let type = ArriverSendType(rawValue: sender.tag){
            block(type)
        }
    }
    
}
