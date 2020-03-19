//
//  YuangongCell.swift
//  ST
//
//  Created by yunchou on 2016/11/20.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class YuangongCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    var employee:Employee? = nil{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        self.label1.text = employee?.employeeCode ?? ""
        self.label2.text = employee?.employeeName ?? ""
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
