//
//  NSDate+Category.m
//  ST
//
//  Created by taotao on 2020/7/13.
//  Copyright © 2020 HTT. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)
	
/**
 * 根据指定格式返回当前日期的NSString
 */
+ (NSString*)currentDateStrBy:(NSString* _Nullable)formatStr
{
	if (formatStr == nil) {
		formatStr = @"yyyy-MM-dd hh:mm:ss";
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = formatStr;
	NSString *todayStr = [formatter stringFromDate:[NSDate date]];
	return todayStr;
}


@end
