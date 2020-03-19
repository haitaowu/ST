//
//  HightlightableView.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class HightlightableView: UIView {

    private var touchVisiable:Bool = false{
        didSet{
            if touchVisiable{
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                })
            }else{
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.backgroundColor = UIColor.white
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.touchVisiable = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.touchVisiable = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchVisiable = false
    }
    

}
