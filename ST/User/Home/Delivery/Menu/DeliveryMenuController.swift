//
//  DeliveryMenuController.swift
//  ST
//
//  Created by taotao on 2020/4/29.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation


class DeliveryMenuController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
  @IBOutlet weak var collectionView: UICollectionView!
	
	var menuAry:Array<Dictionary<String,String>>? = nil
	let kDeliType = "deliType"

	//MARK:- override methods
	override func viewDidLoad() {
		
		self.title = "派件预报"
		self.setupCollectionView()
		let sendFlag = DeliverForeCastControl.DeliveryType.send.rawValue
		let arriveFlag = DeliverForeCastControl.DeliveryType.arrive.rawValue
		let recordFlag = DeliverForeCastControl.DeliveryType.record.rawValue
		self.menuAry = [
			[kName:"中心发件预报",kDeliType:sendFlag,kStory:"BaseUI",kId:"DeliverForeCastControl",kBgColor:"color",kICon:"icon"],
			[kName:"网点到件预报",kDeliType:arriveFlag,kStory:"BaseUI",kId:"DeliverForeCastControl",kBgColor:"color",kICon:"icon"],
			[kName:"网点录单预报",kDeliType:recordFlag,kStory:"BaseUI",kId:"DeliverForeCastControl",kBgColor:"color",kICon:"icon"],
		]
	}
	
	
	//MARK:- setup base view
	func setupCollectionView(){
		self.collectionView.register(PrintMenuItem.itemNib(), forCellWithReuseIdentifier: PrintMenuItem.reuseID())
	}
	
  
	//MARK:- UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return PrintMenuItem.itemSize()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return PrintMenuItem.itemMargin
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return PrintMenuItem.itemMargin
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: PrintMenuItem.itemMargin, left: PrintMenuItem.itemMargin, bottom: 0, right: PrintMenuItem.itemMargin)
	}
	
	//MARK:- UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let model = self.menuAry?[indexPath.item]{
			let story = model[kStory]!
			let identifier = model[kId]!
			let type = model[kDeliType]!
			let storyboard = UIStoryboard.init(name: story, bundle: nil)
			let control = storyboard.instantiateViewController(withIdentifier: identifier)
			if let control = control as? DeliverForeCastControl{
				let deliType = DeliverForeCastControl.DeliveryType(rawValue: type)!
				control.deliType = deliType
			}
			control.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(control, animated: true)
		}
	}
	
	//MARK:- UICollectionViewDataSource
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.menuAry?.count ?? 0
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item:PrintMenuItem = collectionView.dequeueReusableCell(withReuseIdentifier: PrintMenuItem.reuseID(), for: indexPath) as! PrintMenuItem
		if let model = self.menuAry?[indexPath.item]{
			item.updateUI(model: model)
		}
		return item
	}
	
	
	
	

}
