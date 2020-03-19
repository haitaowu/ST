//
//  DriHeavQueryCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class DriHeavQueryCell: BaseCell {
  
  //MARK:- properties
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var routeLabel: UILabel!
  
  
  //MARK:- public methods
  public func updateUI(model :SimpleCodable) -> Void{
	if let heavModel = model as? HeavyRecModel{
		//堵车流水号
		self.numLabel.text = heavModel.truckCode
		//发车日期
		self.dateLabel.text = heavModel.sendDate
		//路由
		self.routeLabel.text = heavModel.lineName
	}else if let damModel = model as? DamRecModel{
		//车损流水号
		self.numLabel.text = damModel.vehicleDamageCode
		//发车日期
		self.dateLabel.text = damModel.sendDate
		//路由
		self.routeLabel.text = damModel.lineName
	}
	
  }
  
}
