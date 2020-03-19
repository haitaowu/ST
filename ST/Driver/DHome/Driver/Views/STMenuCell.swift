//
//  STMenuCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

enum CellMenuType:String {
  case nav = "direction_nav",alert = "arrive_alert" ,heavy = "trafric_heav" ,damge = "car_dam",send = "send_car",arrive = "arriver_car"
}


class STMenuCell: BaseCell {
  @IBOutlet weak var menuImgView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!
  
  var menuType:String?
  
  
  //MARK:- init cell
  public func setupCell(dataStr: String,subTitle: String?) -> Void {
    let infos = dataStr.components(separatedBy: ",");
    if let imgName = infos.first{
      let img = UIImage(named: imgName)
      self.menuImgView.image = img;
    }
    
    if let title = infos.last {
      self.nameLabel.text = title;
    }
    
    if let txt = subTitle{
      self.subTitleLabel.isHidden = false
      self.subTitleLabel.text = txt
    }else{
      self.subTitleLabel.isHidden = true
    }
    
    menuType = infos.first;
  }
  
}
