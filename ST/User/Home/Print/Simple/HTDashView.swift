//
//  HTDashView.swift
//  ST
//
//  Created by taotao on 2018/4/18.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit

class HTDashView:UIView
{
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.setupDashLine();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setupDashLine();
    }
    
    
    //MARK:- setup ui
    public func setupDashLine() -> Void {
        let border = CAShapeLayer.init();
        border.lineWidth = 0.8;
        border.fillColor = UIColor.clear.cgColor;
        border.strokeColor = UIColor.gray.cgColor;
        let size = UIScreen.main.bounds.size;
        let width = size.width - 5 * 2;
        let height = self.bounds.size.height;
        let rect = CGRect(x: 0, y: 0, width: width, height: height);
        border.path = UIBezierPath.init(roundedRect: rect, cornerRadius: 5).cgPath;
        border.lineDashPattern = [4,2];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true;
        self.layer .addSublayer(border);
    }
}
