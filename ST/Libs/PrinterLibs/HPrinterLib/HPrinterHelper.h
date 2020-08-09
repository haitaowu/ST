//
//  HPrinterHelper.h
//  Alamofire
//
//  Created by taotao on 2020/8/6.
//

#import <Foundation/Foundation.h>
#import <PrinterSDK/PrinterSDK.h>


//子单打印的key
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

//派件
#define kSendMan            	@"sendMan"
#define kSendManPhone           @"sendManPhone"
#define kSendManAddress	        @"sendManAddress" //寄件人地址
#define kAcceptMan	            @"acceptMan"	//收件人
#define kAcceptManPhone         @"acceptManPhone" //收件人电话
#define kAcceptManAddress  	    @"acceptManAddress" //收件人地址
#define kDestination            @"sendSite"  //寄件网点

#define kGoodsName	            @"goodsName"   //货物名称
#define kGoodsPiece		        @"pieceNumber" //件数
#define kCalWeight		        @"settlementWeight" //结算重量
#define kExpressType		    @"dispatchMode" //送货方式
#define kSendDate			    @"sendDate" //寄件时间
#define kBlReturnBill			@"blReturnBill" //签回单标识
#define kInStorage				@"blIntoWarehouse" //进仓标识
#define kOverWeightPiece		@"overWeightPiece" //超重件数
#define kBlOverLong				@"blOverLong" //超长标识
#define kRbillCode				@"rbillCode" //回单编号
#define kStorageno				@"storageno" //进仓编号

#define kPaymentType		    @"paymentType" //支付方式
#define kPaiedMoney			    @"topayment" //到付款
#define kInsureVal			    @"insureValue" //保价金额
#define kFreight			    @"freight" //运费



//主单打印 key

#define kMBillCodeKey            @"BILL_CODE"
#define kMSendMan                @"SEND_MAN"
#define kMSendManPhone           @"SEND_MAN_PHONE"
#define kMSendManAddress            @"SEND_MAN_ADDRESS"
#define kMAcceptMan                @"ACCEPT_MAN"    //收件人
#define kMAcceptManPhone         @"ACCEPT_MAN_PHONE" //收件人电话
#define kMAcceptManAddress          @"ACCEPT_MAN_ADDRESS" //收件人地址
#define kMDestination            @"DESTINATION"  //目的地

#define kMGoodsName                @"GOODS_NAME"   //货物名称
#define kMGoodsPiece                @"PIECE_NUMBER" //件数
#define kMCalWeight                @"SETTLEMENT_WEIGHT" //结算重量
#define kMExpressType            @"DISPATCH_MODE" //送货方式
#define kMSendDate                @"SEND_DATE" //寄件时间

#define kMPaiedMoney                @"TOPAYMENT" //到付款
#define kMInsureVal                @"INSURE_VALUE" //保价金额
#define kMFreight                @"FREIGHT" //运费
#define kMPaymentType             @"PAYMENT_TYPE" //zhi fu fang shi
#define kMReturnBill             @"BL_RETURN_BILL" //hui dan biaoshi
#define kMInstoreage                @"BL_INTO_WAREHOUSE" // jin cang biao shi

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


/**
 *fa jian wang dian jijian kehu
 */
- (void)printMasterBillWith:(id)data;

+ (NSString*)strValueOf:(NSDictionary*)billInfo key:(NSString*)keyStr;

// ji jian di zhi / shou jian ren dizhi
+ (NSString*)addressDetail:(NSDictionary*)billInfo type:(NSString*)adrType;

///ji jian ke hu huo wu xin xi
+ (NSString*)goodsInfo:(id)billInfo;

///pai jian wang dian huo wu xin xi
+ (NSString*)sendGoodsInfo:(id)billInfo;


///zhu dan fei yong
+ (NSString*)feesTxtBy:(id)billInfo;


// paijian di zhi / shou jian ren dizhi
+ (NSString*)paiAddressDetail:(NSDictionary*)billInfo type:(NSString*)adrType;

///jian ke hu huo wu xin xi ji
+ (NSString*)paiGoodsInfo:(id)billInfo;

///pai jian wang dian huo wu xin xi
+ (NSString*)paiSendGoodsInfo:(id)billInfo;


///fei yong
+ (NSString*)paiFeesTxtBy:(id)billInfo;

/**
 *pai jian wang dian jijian shoujian ren
 */
- (void)printPaiBillWith:(id)data;


@end

NS_ASSUME_NONNULL_END
