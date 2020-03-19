//
//  StackTableHeaderView.swift
//  DajiaZhongyi
//
//  Created by yunchou on 16/9/1.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

protocol StackViewProtocol{
    func preferHeaderHeight() -> CGFloat
    func displayAbleView() -> UIView
}
extension StackViewProtocol where Self:UIView{
    func displayAbleView() -> UIView{
        return self
    }
}
class StackView: UIView {
    var height:CGFloat = 0
    var views:[StackViewProtocol] = [] {
        didSet{
            self.updateViews()
        }
    }
    
    private func updateViews(){
        //TODO
        self.height = self.views.reduce(0) { (old, s) in
            return old + s.preferHeaderHeight()
        }
        self.layoutSubviews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        var offset = CGFloat(0)
        for i in  0 ..< self.views.count {
            let v = self.views[i]
            let h = v.preferHeaderHeight()
            let view = v.displayAbleView()
            view.frame = CGRect(x: 0, y: offset, width: self.frame.width, height: h)
            offset += h
            self.bringSubviewToFront(view)
        }
    }
}
