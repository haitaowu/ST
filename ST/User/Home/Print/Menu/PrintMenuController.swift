//
//  PrintMenuController.swift
//  ST
//
//  Created by taotao on 2020/4/29.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation


let kName = "name"
let kSubTitle = "subTitle"
let kStory = "storyboard"
let kId = "identifier"
let kBgColor = "bgColor"
let kICon = "icon"


class PrintMenuController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
  @IBOutlet weak var collectionView: UICollectionView!
	
	var menuAry:Array<Dictionary<String,String>>? = nil

	//MARK:- override methods
	override func viewDidLoad() {
		self.title = "标签补打"
		self.setupCollectionView()
		self.menuAry = [
			[kName:"主单打印",kSubTitle:"派",kStory:"BaseUI",kId:"MasterBillPrintControl",kBgColor:"color",kICon:"icon"],
			[kName:"子单打印",kSubTitle:"寄",kStory:"BaseUI",kId:"SubBillPrintControl",kBgColor:"color",kICon:"icon"],
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
      let storyboard = UIStoryboard.init(name: story, bundle: nil)
      let control = storyboard.instantiateViewController(withIdentifier: identifier)
      control.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(control, animated: true)
    }
  }
  
  //MARK:- UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.menuAry?.count ?? 0
  }
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		var item:PrintMenuItem = collectionView.dequeueReusableCell(withReuseIdentifier: PrintMenuItem.reuseID(), for: indexPath) as! PrintMenuItem
		if let model = self.menuAry?[indexPath.item]{
			item.updateUI(model: model)
		}
		return item
  }
	
	
  
  

}
