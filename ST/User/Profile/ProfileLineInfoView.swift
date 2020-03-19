//
//  ProfileLineInfoView.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

typealias ProfileLineInfo = (title:String,value:String)

extension GridView{
    func setupWith(infos:[ProfileLineInfo]) {
        self.views = infos.map(ProfileLineInfoView.build)
    }
}

class ProfileLineInfoView: UIView {
    @IBOutlet weak var label1: UILabel!

    @IBOutlet weak var label2: UILabel!
    class func build(info:ProfileLineInfo) -> ProfileLineInfoView{
        let v:ProfileLineInfoView = Bundle.main.loadNibView(name: "ProfileLineInfoView")
        v.label1.text = "\(info.title):"
        v.label2.text = info.value
        return v
    }
}
