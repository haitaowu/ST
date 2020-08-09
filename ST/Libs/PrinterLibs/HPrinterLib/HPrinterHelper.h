//
//  HPrinterHelper.h
//  Alamofire
//
//  Created by taotao on 2020/8/6.
//

#import <Foundation/Foundation.h>
#import <PrinterSDK/PrinterSDK.h>



#define kBillCodeKey            @"billCode"
#define kSubCodeKey                @"billCodeSub"
#define kSendSiteKey            @"sendSite"
#define kDispatchCenterKey      @"dispatchCenter" //目的网点所属中心
#define kDispatchCodeKey          @"dispatchCode" //目的网点所属编号
#define kSendgoodsTypeKey          @"sendgoodsType" //派送方式
#define kGoodsNameKey              @"goodsName" //物品名称
#define kSendCodeKey              @"sendCode" //寄件网点编号
#define kAcceptAdrKey           @"acceptManAddress"
#define kArriveSiteKey          @"arriveSite"
#define kWeightKey              @"weight"
#define kPieceNumKey            @"pieceNumber"
#define kRegisterDateKey        @"registerDate"


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
