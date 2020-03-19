//
//  UIViewController+setcontentViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/27.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class ContainerViewController:UIViewController{
    var content:UIViewController?{
        didSet{
            setContentViewController(current: content, old: oldValue)
        }
    }
    private func setContentViewController(current:UIViewController?,old:UIViewController?){
        if let old = old{
            removeContentViewController(vc: old)
        }
        guard let current = current else { return }
        self.view.addSubview(current.view)
        current.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.addChild(current)
    }
    private func removeContentViewController(vc:UIViewController){
        vc.view.snp.removeConstraints()
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
}


