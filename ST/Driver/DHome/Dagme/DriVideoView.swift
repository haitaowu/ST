//
//  DriVideoView.swift
//  ST
//
//  Created by taotao on 2019/6/17.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation
import Kingfisher


enum MediaItemType {
	case imgLoc,imgRemote,addBtn
}

typealias ReCaluateHeighBlock = (_ height:CGFloat) -> Void
typealias ClickItemBlock = (_ index:Int, _ typ:MediaItemType) -> Void
typealias DeleteMediaBlock = (_ index:Int) -> Void

//MARK:-  MediaBtn Class
class MediaBtn: UIButton {
	
	var btnType:MediaItemType = .addBtn
	var addAble:Bool = true
	public var deleteBlock:DeleteMediaBlock?
	
	//MARK:- lazy
	/*
	lazy var playBtnView:UIImageView = {
	let imgView = UIImageView.init(image: UIImage(named: "play_btn"))
	self.addSubview(imgView)
	return imgView
	}()
	*/
	
	lazy var deleteBtn:UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(named: "delete"), for: .normal)
		btn.addTarget(self, action: #selector(clickDeleteBtn), for: .touchUpInside)
		self.addSubview(btn)
		return btn
	}()
	
	convenience init(type:MediaItemType,obj:Any,tag:Int,addedAble:Bool) {
		self.init()
		self.btnType = type
		self.imageView?.contentMode = .scaleAspectFill
		if type == .imgRemote{
			let imgHolder = UIImage(named: "img_placeholder")
//			let url = URL.init(string: "http://www.ziticq.com/upload/image/20190919/5d82e5dd1f193.png")
			if let picUrl = obj as? String,let url = URL.init(string:picUrl){
				self.kf.setImage(with: url, for: .normal, placeholder: imgHolder, options: nil, progressBlock: nil, completionHandler: nil)
			}
		}else if type == .imgLoc,let img = obj as? UIImage{
			self.setImage(img, for: .normal)
		}else if type == .addBtn{
			let img = UIImage(named: "plus")
			self.setImage(img, for: .normal)
		}else{
			//            self.playBtnView.isHidden = true
		}
		
		if type == .addBtn || type == .imgRemote{
			self.deleteBtn.isHidden = true
			//        }else if addedAble == false{
			//            self.deleteBtn.isHidden = true
		}else{
			self.deleteBtn.isHidden = false
		}
		self.tag = tag
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		/*
		if self.playBtnView.isHidden == false{
		let size = self.frame.size
		let centerX = size.width * 0.5
		let centerY = size.height * 0.5
		let centerPoint = CGPoint(x: centerX, y: centerY)
		self.playBtnView.center = centerPoint
		}
		*/
		
		if self.deleteBtn.isHidden == false{
			let wh:CGFloat = 25;
			let x = self.frame.size.width - wh;
			let frame = CGRect(x: x, y: 0, width: wh, height: wh)
			self.deleteBtn.frame = frame
		}
	}
	
	//MARK: - selectors
	@objc func clickDeleteBtn() -> Void {
		print("click Delete btn....")
		if let block = self.deleteBlock {
			block(self.tag)
		}
	}
	
}





//MARK:-  DriVideoView Class
class DriVideoView: UIView {
	
	static let size = UIScreen.main.bounds.size
	static let columnCount:CGFloat = 3
	static let horizontalSpacing:CGFloat = 10
	static let verticalSpacing:CGFloat = 10
	
	
	var itemType:MediaItemType = .addBtn
	var imgsAry:Array<Any>?
	
	public var clickBlock:ClickItemBlock?
	public var updateBlock:DeleteMediaBlock?
	
	var itemsAry:Array<UIButton> = Array<UIButton>()
	
	
	
	//MARK:- public
	public func updateUI(imgs: Array<Any> ,type: MediaItemType, addAble:Bool){
		self.itemType = type
		self.imgsAry = imgs
		for item in self.itemsAry{
			item.removeFromSuperview()
		}
		
		for (idx,obj) in imgs.enumerated(){
			var item:MediaBtn?
			if (addAble && (idx == (imgs.count - 1))){
				item = MediaBtn.init(type: .addBtn, obj: obj, tag: idx,addedAble: addAble)
			}else{
				item = MediaBtn.init(type: type, obj: obj, tag: idx,addedAble: addAble)
			}
			if let btn = item{
				btn.addTarget(self, action: #selector(clickItemBtn), for: .touchUpInside)
				btn.tag = idx
				self.itemsAry.append(btn)
				let itemWH = DriVideoView.itemWH()
				let colIdx = DriVideoView.columnIdxBy(count: idx)
				let x = CGFloat(colIdx) * (itemWH + DriVideoView.horizontalSpacing) + DriVideoView.horizontalSpacing
				let rowIdx = DriVideoView.rowsIdxBy(count: idx)
				let y = CGFloat(rowIdx) * (itemWH + DriVideoView.verticalSpacing) + DriVideoView.verticalSpacing
				let frame = CGRect(x: x, y: y, width: itemWH, height: itemWH)
				btn.frame = frame
				self.itemsAry.append(btn)
				self.addSubview(btn)
				btn.deleteBlock = {
					[unowned self] idx in
					self.imgsAry?.remove(at: idx)
					if let block = self.updateBlock{
						block(idx)
					}
				}
			}
		}
	}
	
	//点击图片
	@objc func clickItemBtn(sender:MediaBtn) -> Void {
		let idx = sender.tag
		if let block = self.clickBlock{
			block(idx,sender.btnType)
		}
	}
	
	//当前的索引为第几列
	static func columnIdxBy(count: Int) -> Int {
		return count % Int(columnCount)
	}
	
	//当前的索引为第几行
	static func rowsIdxBy(count: Int) -> Int {
		return count / Int(columnCount)
	}
	
	//count 共占几行
	static func rowsNumIdxBy(count: Int) -> Int {
		return (count + Int(columnCount) - 1) / Int(columnCount)
	}
	
	//item 的宽高
	static func itemWH() -> CGFloat{
		let margins = horizontalSpacing * (columnCount + 1)
		let itemWH = (size.width - margins) / columnCount
		return CGFloat(itemWH)
	}
	
	//items 的高
	static func viewHeightBy(itemCount:Int) -> CGFloat{
		if itemCount == 0{
			return 0
		}else{
			let itemWH = DriVideoView.itemWH()
			let rowIdx = DriVideoView.rowsNumIdxBy(count: itemCount)
			let margins = verticalSpacing * (CGFloat(rowIdx) + 1)
			let height = itemWH * CGFloat(rowIdx) + margins;
			return height
		}
	}
	
	
	
	
}
