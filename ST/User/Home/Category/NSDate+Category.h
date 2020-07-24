//
//  NSDate+Category.h
//  ST
//
//  Created by taotao on 2020/7/13.
//  Copyright © 2020 HTT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Category)
/**
 * 根据指定格式返回当前日期的NSString
 */
+ (NSString*)currentDateStrBy:(NSString* _Nullable)formatStr;

@end

NS_ASSUME_NONNULL_END
