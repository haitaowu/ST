//
//  HPrinterHelper.h
//  Alamofire
//
//  Created by taotao on 2020/8/6.
//

#import <Foundation/Foundation.h>
#import <PrinterSDK/PrinterSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface HPrinterHelper : NSObject<NSCopying,NSMutableCopying>
+ (HPrinterHelper*)sharedInstance;
/**
 *disconnect to printer
 */
- (void)disconnectCurrentPrinter;

/**
 *printerConnected
 */
- (PTPrinter*)currentPrinter;


/**
 *zidan print with
 */
- (void)printWithData:(id)data startPage:(NSInteger)startPage endPage:(NSInteger)endPage;

/**
 *录单时间
 */
+ (NSString*)billDateWithData:(NSDictionary*)data;

/**
 *zi dan shu zu
 */
+ (NSArray *)subBillCodesWithBillData:(NSDictionary*)billInfo;




@end

NS_ASSUME_NONNULL_END
