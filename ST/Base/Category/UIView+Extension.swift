//
//  UIView+extension.swift
//  ST
//
//  Created by taotao on 2019/7/11.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

extension UIView{
    
    //MARK:- public
    func addDismissGesture() -> Void{
        let tapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapEndViewEdit))
        self.addGestureRecognizer(tapGest)
    }
    
    ///添加圆角、边框、边框的颜色
    func  addCorner(radius:CGFloat, color:UIColor,borderWidth:CGFloat) -> Void{
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    ///添加圆角、边框、边框的颜色
    ///- parameter radius:圆角的大小
    func  addCorner(radius:CGFloat) -> Void{
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    ///添加边框
    func  addBorder(width:CGFloat,color:UIColor) -> Void{
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func x() -> CGFloat {
        return self.frame.origin.x
    }
    
    func y() -> CGFloat {
        return self.frame.origin.y
    }
    
    func setY(y: CGFloat){
        let frame = CGRect(x: self.x(), y: y, width: self.vWidth(), height: self.vHeight())
        self.frame = frame
    }
    
    func vHeight() -> CGFloat {
        return self.frame.size.height
    }
    
    func vWidth() -> CGFloat {
        return self.frame.size.width
    }

    
    //MARK:- objc selectors
    @objc func tapEndViewEdit() -> Void {
        self.endEditing(true)
    }
    
    
}
