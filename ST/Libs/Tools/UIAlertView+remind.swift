//
//  UIAlertView+remind.swift
//  ST
//
//  Created by yunchou on 2016/12/13.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit


extension UIAlertView{
    class func remindUser( _ msg:String){
        let alert = UIAlertView(title: "", message: msg, delegate: nil, cancelButtonTitle: nil)
        alert.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
        })
    }
}
