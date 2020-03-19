//
//  RemindInterface.swift
//  ST
//
//  Created by yunchou on 2016/11/8.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import PKHUD

extension UIViewController{
    func remindUser(msg:String){
        HUD.flash(HUDContentType.label(msg),delay:1.5)
    }
}

extension UIViewController{
    func showLoading(msg:String){
        HUD.show(HUDContentType.labeledProgress(title: nil, subtitle:msg))
    }
    func hideLoading(){
        HUD.hide()
    }
}

