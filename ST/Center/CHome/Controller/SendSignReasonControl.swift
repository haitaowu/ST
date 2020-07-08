//  SendSignReasonControl.swift
//  ST
//
//  Created by taotao on 2019/7/29.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import ActionSheetPicker_3_0
import Alamofire


typealias SubmitReasonBlock = (Bool,[String:String])->Void


class SendSignReasonControl: UITableViewController{
	
  let SectIdxLateReason = 0
	let SectIdxSealReason = 1
	let SectIdxSubmit = 2
	

	var submitBlock:SubmitReasonBlock?
  
  ///提交的参数
	var params:[String:String]?
	var imgs:Array<UIImage>?
	
	
  @IBOutlet weak var lateReaTxtView: CustomTextView!
  var needLateRea:Bool = false
  
  @IBOutlet weak var sealReaTxtView: CustomTextView!
//  是否需要封号异常的说明
  var needSealRea:Bool = false

	

  //MARK:- overrides
  override func viewDidLoad() {
    self.view.addDismissGesture()
		self.lateReaTxtView.placeholder = "输入超时的原因"
		self.sealReaTxtView.placeholder = "输入封签号不一致的原因"
  }
	
  
  //MARK:-  selectors
  //提交
  @IBAction func clickConfirmItem(_ sender: Any) {
		
	let paramsSend = self.paramsSend()
    if let block = self.submitBlock,paramsSend != nil{
      block(true,paramsSend!)
    }
  }
	
	@IBAction func clickCancelBtn(_ sender: Any) {
		
    if let block = self.submitBlock{
      block(false,[:])
    }

  }
	
  
  //MARK:- UITableView data souce
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == SectIdxLateReason {
			if self.needLateRea{
				return 2
			}else{
				return 0
			}
		}else if section == SectIdxSealReason {
				if self.needSealRea{
					return 2
				}else{
					return 0
				}
		}else{
			return super.tableView(tableView, numberOfRowsInSection: section)
		}
	}
	
  //MARK:- UITableViewDelegate
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath.section == SectIdxLateReason){
			if indexPath.row == 1 {
				return 120
			}else{
				return 44
			}
		}else if indexPath.section == SectIdxSealReason {
      if indexPath.row == 1 {
				return 120
			}else{
				return 44
			}
    }else{
      return 50
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.001
  }
	
	override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		if indexPath.section == SectIdxLateReason {
			return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: SectIdxLateReason))
		}else if indexPath.section == SectIdxSealReason {
			return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: SectIdxSealReason))
		}else{
			return super.tableView(tableView, indentationLevelForRowAt: indexPath)
		}
	}
	
  
  //MARK:- request parameter helper
  private func paramsSend()-> [String: String]?{
    
    var params:[String:String] = [:]
		if self.needLateRea {
			if let lateReason = self.lateReaTxtView.text,lateReason.isEmpty == false {
				params["lateReason"] = lateReason
			}else{
				self.remindUser(msg: "请输入超时原因")
				return nil
			}
		}
		
		if self.needSealRea {
			if let sealReason = self.sealReaTxtView.text,sealReason.isEmpty == false {
				params["comesealAtypismReason"] = sealReason
			}else{
				self.remindUser(msg: "请输入封签号不一致原因")
				return nil
			}
		}
    return params
  }
	
	
	
  
  //MARK:- request server
	///发车签到数据
//  func submitSendSignData(params:[String: String]) -> Void {
//    let req = SendCarSignReq(params: params)
//    STNetworking<RespMsg>(stRequest:req) {
//      [unowned self] resp in
//      if resp.stauts == Status.Success.rawValue{
//        self.remindUser(msg: "提交成功")
//        self.navigationController?.popViewController(animated: true)
//      }else if resp.stauts == Status.NetworkTimeout.rawValue{
//        self.remindUser(msg: "网络超时，请稍后尝试")
//      }else{
//        var msg = resp.msg
//        if resp.stauts == Status.PasswordWrong.rawValue{
//          msg = "提交错误"
//        }
//        self.remindUser(msg: msg)
//      }
//      }?.resume()
//  }
//
  
  
}
