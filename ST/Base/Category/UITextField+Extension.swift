//
//  UITextField+Extension.swift
//  ST
//
//  Created by taotao on 2019/7/11.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation


extension UITextField{
    //MARK:-
    func addLeftSpaceView(width: CGFloat) -> Void {
        let frame = CGRect(x: 0, y: 0, width: width, height: self.vHeight())
        let spaceView = UIView(frame: frame)
        self.leftView = spaceView
        self.leftViewMode = .always
    }
    
    func addRightView(imgName: String) -> Void {
        let frame = CGRect(x: 0, y: 0, width: self.vHeight(), height: self.vHeight())
        let img = UIImage(named: imgName)
        let imgView = UIImageView(image: img)
        imgView.contentMode = .center
        imgView.frame = frame
        self.rightView = imgView
        self.rightViewMode = .always
    }
	
	func addRightBtn(imgName: String, action: Selector, target:Any?) -> Void{
		let typeImg = UIImage(named: imgName);
		let rightViewF = CGRect(x: 0, y: 0, width: 44, height: 44)
		let typeRightVeiw = UIButton.init(frame: rightViewF)
		typeRightVeiw.setImage(typeImg, for: .normal)
		typeRightVeiw.addTarget(action, action: action, for: .touchUpInside)
		self.rightView = typeRightVeiw
		self.rightViewMode = .always
		
	}
}
