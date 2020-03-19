//
//  PickerInputView.swift
//  ST
//
//  Created by yunchou on 2016/11/9.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit


protocol PickerInputViewModel {
    func componentsCount() -> Int
    func rowCountForComponent(c:Int) -> Int
    func titleForRow(row:Int,component:Int) -> String
}

protocol PickerInputViewModelDelegate:NSObjectProtocol {
    func onPickerInputViewIndexChagne(_ row:Int,_ component:Int)
    func onPickerInputViewRequestDismiss()
}

struct PickerInputViewSampleModel:PickerInputViewModel {
    func componentsCount() -> Int{ return 0 }
    func rowCountForComponent(c:Int) -> Int{ return 0 }
    func titleForRow(row:Int,component:Int) -> String{ return "" }
}
class PickerInputView:UIView{
    @IBOutlet weak var topContainer: UIView!
    var model:PickerInputViewModel = PickerInputViewSampleModel(){
        didSet{
            self.pickerView.reloadAllComponents()
        }
    }
    weak var delegate:PickerInputViewModelDelegate? = nil
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func confirmBtnClicked(_ sender: Any) {
        delegate?.onPickerInputViewRequestDismiss()
    }
    func selectedRow(inComponent:Int) -> Int{
        return pickerView.selectedRow(inComponent: inComponent)
    }
    func reloadComponent(c:Int){
        self.pickerView.reloadComponent(c)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderColor = UIColor.appLineColor
        self.topBorderWidth = 0.5
    }
}

extension PickerInputView:UIPickerViewDataSource,UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return model.componentsCount()
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return model.rowCountForComponent(c: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return model.titleForRow(row: row, component: component)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.delegate?.onPickerInputViewIndexChagne(row, component)
    }
}
