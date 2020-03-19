//
//  StBottomButton.swift
//  ST
//
//  Created by yunchou on 2016/11/7.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class StBottomButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.backgroundColor = UIColor.appMajor
        self.layer.cornerRadius  = 3
        self.clipsToBounds = true
        self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    }
}
