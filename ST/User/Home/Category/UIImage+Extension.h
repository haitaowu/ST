//
//  UIImage+Extension.h
//  PotatoMall
//
//  Created by taotao on 25/02/2017.
//  Copyright © 2017 taotao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
// 通过颜色创建UIImage
+(UIImage*)imageWithColor:(UIColor*) color;
- (UIImage*)thumbImgWithSize:(CGSize)thumbSize;
@end
