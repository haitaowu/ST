//
//  HomeMenuItemView.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit


typealias HomeMenuItems = (title:String,icon:String,key:String,handler:ViewClickHandler)

extension GridView{
    func setupWith(items:[HomeMenuItems]){
        self.views = items.map(HomeMenuItemView.build)
    }
}
class HomeMenuItemView: HightlightableView {
    var onClicked:ViewClickHandler?
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    private var key:String = ""
    class func build(item:HomeMenuItems) -> HomeMenuItemView{
        let v:HomeMenuItemView = Bundle.main.loadNibView(name: "HomeMenuItemView")
        v.iconView.image = UIImage(named: item.icon)
        v.titleView.text = item.title
        v.key = item.key
        v.onClicked = item.handler
        v.isUserInteractionEnabled = true
        return v
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.onClicked?(key)
    }
    
    

}
