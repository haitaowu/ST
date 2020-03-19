//
//  SystemSettingEntryType1.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class SystemSettingEntryType1: HightlightableView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    var onClicked:((_ type:String) -> Void)?
    var key:String = ""
    class func build(item:SettingEntryItem) -> SystemSettingEntryType1{
        let v:SystemSettingEntryType1 = Bundle.main.loadNibView(name: "SystemSettingEntryType1")
        v.label.text = item.title
        v.iconView.image = UIImage(named: item.icon)
        v.key = item.key
        v.onClicked = item.handler
        return v
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.onClicked?(key)
    }
}
