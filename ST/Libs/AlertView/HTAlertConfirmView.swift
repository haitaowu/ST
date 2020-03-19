//
//  HTAlertConfirmView.swift
//  ST
//
//  Created by taotao on 2018/4/18.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit


typealias SelectTitleBlock = (_ title:String)->Void

class HTAlertConfirmView:UIView,UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    
    @IBOutlet weak var pickView: UIPickerView!
    @IBOutlet weak var containerView: UIView!
    var titleBlock:SelectTitleBlock? = nil;
    let pickViewHeight:CGFloat = 250;
    var titles:Array<String>? = nil;
    var currentRow:Int = 0;
    
    static let screenSize:CGSize = UIScreen.main.bounds.size;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    
    public static func ShowAlertViewWithTitles(titles:Array<String>,block:@escaping SelectTitleBlock){
        if let array = Bundle.main.loadNibNamed("HTAlertConfirmView", owner: nil, options: nil){
            let alertView:HTAlertConfirmView = array[0] as! HTAlertConfirmView;
            alertView.frame = CGRect(x: 0, y: 0, width:screenSize.width, height: screenSize.height);
            alertView.titleBlock = block;
            alertView.titles = titles;
            alertView.pickView.reloadAllComponents();
            alertView.showAlertView();
        }
    }
    
    //MARK:- private
    func showAlertView() -> Void {
        self.pickView.showsSelectionIndicator = true;
        let window:UIWindow = UIApplication.shared.keyWindow!;
        self.alpha = 0.0;
        let screenSize:CGSize = UIScreen.main.bounds.size;
        self.containerView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: pickViewHeight);
        window.addSubview(self);
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0;
            let y:CGFloat = screenSize.height - self.pickViewHeight;
            self.containerView.frame = CGRect(x: 0, y:y , width: screenSize.width, height: self.pickViewHeight);
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
         self.dismissView();
    }
    
    //tap confirm button
    @IBAction func tapConfirmBtn(_ sender: Any) {
        if let block = self.titleBlock{
            if let titles = self.titles{
                let row:Int = self.pickView.selectedRow(inComponent: 0);
                let title = titles[row];
                block(title);
            }
        }
        self.dismissView();
    }
    
    //MARK:- UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let titles = self.titles{
            return titles.count;
        }else{
            return 0;
        }
    }
    
    //MARK:- UIPickerViewDelegate
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let titles = self.titles{
            return titles[row];
        }else{
            return nil;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40;
    }
    

}
