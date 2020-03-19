//
//  NoticeCell.swift
//  ST
//
//  Created by taotao on 2017/9/11.
//  Copyright © 2017年 dajiazhongyi. All rights reserved.
//

import UIKit

class NoticeCell: UITableViewCell {

    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var noticeData:NSDictionary? {
        didSet{
            self.updateUI();
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusBtn.layer.borderColor = UIColor.black.cgColor
        self.statusBtn.layer.borderWidth = 1
        self.statusBtn.isSelected = true
    }

    //MARK:- setup ui
    func updateUI(){
        if let data = self.noticeData{
            if let path = data.value(forKey: "FILE_PATH") {
                let pathStr = path as? String
                if (pathStr?.isEmpty)!{
                    self.statusBtn.isSelected = false
                }else{
                    self.statusBtn.isSelected = true
                }
            }else{
                self.statusBtn.isSelected = false
            }
            
            let TITLE = data.value(forKey: "TITLE") as? String;
            if TITLE != nil{
                self.titleLabel.text = TITLE;
            }else{
                self.titleLabel.text = "";
            }
        }
    }
    
}
