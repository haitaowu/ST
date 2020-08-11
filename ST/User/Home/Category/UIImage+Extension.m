//
//  UIImage+Extension.m
//  PotatoMall
//
//  Created by taotao on 25/02/2017.
//  Copyright © 2017 taotao. All rights reserved.
//
#import <CoreGraphics/CoreGraphics.h>
#import "UIImage+Extension.h"


@implementation UIImage (Extension)
+(UIImage*)imageWithColor:(UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage*)thumbImgWithSize:(CGSize)thumbSize
{
    UIGraphicsBeginImageContext(thumbSize);
    [self drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
