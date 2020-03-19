//
//  DriCarInfoCell.swift
//  ST
//
//  Created by taotao on 2019/6/2.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

class DriCarInfoCell: BaseCell {
  @IBOutlet weak var txtLabel: UILabel!
	
  static let keysAry = ["blTempWork,是否为外调加班车：","arriveTime,计划时间：","truckNum,车牌：","truckType,车型：","truckCarNum,挂车号：","lineName,路由：","scanMan,操作人：","scanDate,发车时间：","sendsealScanAhead,封签号（后）：","sendsealScanMittertor,封签号（前侧）：","sendsealScanBackDoor,封签号（后侧）："]
  
  
  //MARK:- override
  override class func cellHeight(data: Any?) -> CGFloat{
    return 40;
  }
  
  
  //MARK:- update ui by model
	func updateUIBy(model: UnFinishedModel,indexPath: IndexPath) {
		let keyStr = DriCarInfoCell.keysAry[indexPath.row]
		let keyTitle = keyStr.components(separatedBy: ",")
		if let modelDic = model.toJSON(),let key = keyTitle.first,let title = keyTitle.last{
			if let valStr = modelDic[key] as? String{
				let string = title+valStr
				self.txtLabel.text = string
			}
		}
	}
  
  
    
}
