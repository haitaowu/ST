//
//  UIImageExtension.swift
//  HTSwiftDemo
//
//  Created by taotao on 2017/8/28.
//  Copyright © 2017年 taotao. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    func compressImage(maxKB:Int) -> Data?{
        var scaleImg = self.scaleImage(image: self);
        var ratio:CGFloat = 1;
        var data = scaleImg.jpegData(compressionQuality: ratio)
        let maxtBytes = maxKB * 1024;
        if let compressData = data {
            while ((compressData.count > maxtBytes) && (ratio > 0.01)){
                data = scaleImg.jpegData(compressionQuality: ratio);
                scaleImg = UIImage(data: data!)!
                ratio = ratio - 0.1;
                NSLog("compressData count = \(compressData.count) = ratio = \(ratio)");
            }
        }else{
            return nil;
        }
        return data;
    }
    
    func scaleImage(image:UIImage) -> UIImage {
        let scaleWidth = image.size.width;
        let scaleHeight = image.size.height;
        let whRatio = scaleWidth / scaleHeight;
        let limitHeight:CGFloat = 200;
        let limitWidth = limitHeight * whRatio;
        let scaleSize = CGSize(width: limitWidth, height: limitHeight)
        UIGraphicsBeginImageContext(scaleSize)
        image.draw(in: CGRect(x: 0, y: 0, width: limitWidth, height: limitHeight))
        let scaleImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaleImg!;
    }
}
