//
//  YuangongPicker.swift
//  ST
//
//  Created by yunchou on 2016/11/20.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

protocol YuangongPickerInterface:YuangongPickerViewControllerDelegate {
    func showYuangongPicker()
    func onYuangongSelect(item:Employee)
}

extension YuangongPickerInterface where Self:UIViewController{
    func showYuangongPicker(){
        let picker = YuangongPickerViewController(nibName: "YuangongPickerViewController", bundle: nil)
        picker.hidesBottomBarWhenPushed = true
        picker.delegate = self
        self.navigationController?.pushViewController(picker, animated: true)
    }
    func yuangongPickerViewControllerCancel(vc:YuangongPickerViewController){
        _ = self.navigationController?.popViewController(animated: true)
    }
    func yuangongPickerViewControllerSelect(vc:YuangongPickerViewController,item:Employee){
        self.onYuangongSelect(item: item)
        _ = self.navigationController?.popViewController(animated: true)
    }
}
