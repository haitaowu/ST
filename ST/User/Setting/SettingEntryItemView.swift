//
//  SettingEntryItemView.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit


typealias SettingEntryItem = (icon:String,title:String,key:String,handler:ViewClickHandler)

extension GridView{
    func setupWith(items:[SettingEntryItem] ){
        self.views = items.map(SettingEntryItemView.build)
    }
}

class SettingEntryItemView: HightlightableView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    var onClicked:((_ type:String) -> Void)?
    private var key:String = ""
    class func build(item:SettingEntryItem) -> SettingEntryItemView{
        let v:SettingEntryItemView = Bundle.main.loadNibView(name: "SettingEntryItemView")
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
