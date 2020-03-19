//
//  HTAlertViewPrint.swift
//  ST
//
//  Created by taotao on 2018/4/18.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit


typealias SelectPrintBlock = ()->Void
typealias CancelPrintBlock = ()->Void

class HTAlertViewPrint:UIView{
   static let screenSize:CGSize = UIScreen.main.bounds.size;
    var printBlock:SelectPrintBlock? = nil;
    var cancelBlock:CancelPrintBlock? = nil;
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    
    public static func ShowAlertViewWith(printBlock:@escaping SelectPrintBlock,cancelBlock:@escaping CancelPrintBlock){
        if let array = Bundle.main.loadNibNamed("HTAlertViewPrint", owner: nil, options: nil){
            let alertView:HTAlertViewPrint = array[0] as! HTAlertViewPrint;
            alertView.frame = CGRect(x: 0, y: 0, width:screenSize.width, height: screenSize.height);
            alertView.printBlock = printBlock;
            alertView.cancelBlock = cancelBlock;
            alertView.showAlertView();
        }
    }
    
    //MARK:- private
    func showAlertView() -> Void {
        let window:UIWindow = UIApplication.shared.keyWindow!;
        self.alpha = 0.0;
        window.addSubview(self);
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0;
        };
    }
    
    func dismissView() -> Void {
        UIView.animate(withDuration: 0.3) {
            self.removeFromSuperview();
        }
    }
    
    //MARK:- selectors
    @IBAction func tapCoverView(sender: AnyObject) {
        self.dismissView();
    }
    
    //tap confirm button
    @IBAction func tapCancelBtn(_ sender: Any) {
        if let block = self.cancelBlock{
            block();
        }
        self.dismissView();
    }
    
    //tap confirm button
    @IBAction func tapPrintBtn(_ sender: Any) {
        if let block = self.printBlock{
            block();
        }
        self.dismissView();
    }
    
}
