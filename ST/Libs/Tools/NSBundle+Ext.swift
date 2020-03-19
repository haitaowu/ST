//
//  NSBundle.swift
//  DajiaStudio
//
//  Created by Ming Wang on 5/10/16.
//  Copyright © 2016 Da Jia Zhong Yi. All rights reserved.
//

import UIKit

extension Bundle{
    func loadNibView<T>(name:String) -> T {
        var find:T?
        let bundleViews = self.loadNibNamed(name, owner: nil, options: nil)!
        for v in bundleViews {
            if v is T {
                find = v as? T
                break
            }
        }
        return find!
    }
}
