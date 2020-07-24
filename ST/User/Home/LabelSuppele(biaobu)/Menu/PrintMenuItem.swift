//
//  PrintMenuItem.swift
//  ST
//
//  Created by taotao on 2020/4/29.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation



class PrintMenuItem: UICollectionViewCell {
  @IBOutlet weak var container: UIView!
  @IBOutlet weak var iConView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var subLabel: UILabel!
  

	
  static let mainSize = UIScreen.main.bounds.size
	static let colNum:CGFloat = 2
	static let whRatio:CGFloat = 2
	static let itemMargin:CGFloat = 10
	


  //MARK:- class methods
	class func reuseID()->String{
		return "PrintMenuItemID"
	}
	
	class func itemNib()->UINib{
		let nib = UINib.init(nibName: "PrintMenuItem", bundle: nil)
		return nib
	}
	
	class func itemSize() ->CGSize{
		let itemWith = (mainSize.width - itemMargin*(colNum+1)) / colNum
		let itemHight = itemWith / whRatio
		return CGSize(width: itemWith, height: itemHight)
	}
  
  
  class func RandomColor() -> UIColor{
    let randomRed = CGFloat(arc4random() % 255) / 255.0
    let randomGreen = CGFloat(arc4random() % 255) / 255.0
    let randomBlue = CGFloat(arc4random() % 255) / 255.0
    let color = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
		
    return color
  }
  
	//MARK:- override methods
  override func awakeFromNib() {
    self.container.addCorner(radius: 10)
    self.iConView.addCorner(radius: 20)
		self.container.backgroundColor = UIColor(hexString: "48B0D6")
  }
  
  
  //MARK:- public methods
  func updateUI(model:Dictionary<String,String>) -> Void {
    let title = model["name"]
    self.nameLabel.text = title
    let subTitle = model["subTitle"]
    self.subLabel.text = subTitle
  }
  
  
  
  
}


