//
//  QrInterface.swift
//  ST
//
//  Created by yunchou on 2016/11/8.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import PKHUD

protocol QrInterface:QRCodeReaderViewDelegate {
    func onReadQrCode(code:String)
}

extension QrInterface where Self:UIViewController{
    func openQrReader(){
        let vc = QRCodeReaderViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onReadQrCode(code:String){
    
    }
    
    func onQrCodeReaderSuccess(qrview:QRCodeReaderView,code:String){
        self.onReadQrCode(code: code)
        _ = self.navigationController?.popViewController(animated: true)
    }
    func onQrCodeReaderFail(qrview:QRCodeReaderView){
        _ = self.navigationController?.popViewController(animated: true)
        HUD.flash(HUDContentType.label("扫描失败，请稍后尝试"))
    }
    func onQrCodeReaderAccessRequired(qrview:QRCodeReaderView){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func onQrCodeReaderCancel(qrview:QRCodeReaderView){
        _ = self.navigationController?.popViewController(animated: true)
    }
}
