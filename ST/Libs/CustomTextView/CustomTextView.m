//
//  CustomTextView.m
//  TextViewDemo
//
//  Created by taotao on 6/6/16.
//  Copyright © 2016 taotao. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

#pragma mark - override methods
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.placeholder = @"没有内容";
    self.holderColor = [UIColor lightGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleChanged) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)drawRect:(CGRect)rect
{
    if ([self hasText]) {
        return;
    }else{
        if (self.placeholder != nil) {
            CGFloat width = rect.size.width;
            CGFloat height = 20;
            CGFloat y = (rect.size.height - height) * 0.5;
            CGRect placerRect = CGRectMake(5, y, width, height);
            UIFont *font = [UIFont systemFontOfSize:15];
            UIColor *holderColor = self.holderColor == nil?[UIColor grayColor]:self.holderColor;
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:holderColor,NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
            [self.placeholder drawInRect:placerRect withAttributes:attributes];
        }else{
            return;
        }
    }
}


#pragma mark -  setter and getter methods 
- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    [self setNeedsDisplay];
}

- (void)setHolderColor:(UIColor *)holderColor
{
    _holderColor = holderColor;
    [self setNeedsDisplay];
}
- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

#pragma mark - selector 
- (void)titleChanged
{
    [self setNeedsDisplay];
}





@end
