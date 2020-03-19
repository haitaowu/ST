//
//  WangdianCell.swift
//  ST
//
//  Created by yunchou on 2016/11/20.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class WangdianCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    var wangdian:SiteInfo? = nil{
        didSet{
            label1.text = wangdian?.siteName ?? ""
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
