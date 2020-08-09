//
//  HPrinterHelper.m
//  Alamofire
//
//  Created by taotao on 2020/8/6.
//

#import "HPrinterHelper.h"
#import "NSDate+Category.h"




@implementation HPrinterHelper

static HPrinterHelper *instance;

+ (HPrinterHelper*)sharedInstance{
    return [[self alloc] init];
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return instance;
}


#pragma mark- public
/**
 *disconnect to printer
 */
- (void)disconnectCurrentPrinter
{
    PTDispatcher *manager = [PTDispatcher share];
    [manager unconnectPrinter:manager.printerConnected];
}

/**
 *printerConnected
 */
- (PTPrinter*)currentPrinter
{
    return [PTDispatcher share].printerConnected;
}

/**
 *录单时间
 */
+ (NSString*)billDateWithData:(NSDictionary*)data
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *billDateStr = [data objectForKey:kRegisterDateKey];
    NSDate *billDate = [formatter dateFromString:billDateStr];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *formatBillDateStr = [formatter stringFromDate:billDate];
    formatBillDateStr = [NSString stringWithFormat:@"%@",formatBillDateStr];
    return formatBillDateStr;
}


/**
 *zi dan shu zu
 */
+ (NSArray *)subBillCodesWithBillData:(NSDictionary*)billInfo
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *subBillCodeStr = [billInfo objectForKey:kSubCodeKey];
    NSCharacterSet *semicolonCharSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    subBillCodeStr = [subBillCodeStr stringByTrimmingCharactersInSet:semicolonCharSet];
    NSArray *subCodesArra = [subBillCodeStr componentsSeparatedByCharactersInSet:semicolonCharSet];
    for (NSString *codeStr in subCodesArra) {
        if (codeStr.length > 0) {
            [array addObject:codeStr];
        }
    }
    return array;
}

/**
 *print with
 */
- (void)printWithData:(id)data startPage:(NSInteger)startPage endPage:(NSInteger)endPage
{
    NSArray *subCodeAry = [HPrinterHelper subBillCodesWithBillData:data];
    if (subCodeAry.count > 0) {
        for(NSInteger startIdx = startPage; startIdx <= endPage; startIdx++){
            if ((startIdx-1) >= subCodeAry.count) {
                break;
            }else{
                NSString *subCode = [subCodeAry objectAtIndex:(startIdx-1)];
                NSString *indexString = [NSString stringWithFormat:@"%ld/%ld",(long)startIdx,(long)endPage];
                [self startPrintBy:data subBillCode:subCode indexStr:indexString];
            }
        }
    }else{
        NSString *subCode = [data objectForKey:kBillCodeKey];
        [self startPrintBy:data subBillCode:subCode indexStr:@"1/1"];
    }

}


#pragma mark- private print zi dan
/**
 *zidan dayin
 */
- (void)startPrintBy:(id)billInfo subBillCode:(NSString*) subCode indexStr:(NSString*)indexStr
{
    NSInteger startX = 5;
    NSInteger deltaX = 5;
    NSInteger deltaY = 5*3;
    NSInteger startY = 10;
    NSInteger offsetX = 15;
    NSInteger pageWidth = 790;
    NSInteger pageHeight = 550;
    NSInteger maxBoxWidth = pageWidth - startX * 2;
    //    NSInteger maxBoxHeight = pageHeight - startY * 2;
    int lineWeight = 2;
    NSInteger topLogHeight = 160;
    NSInteger vBarCodeWidth = 90;
    NSInteger col1X = vBarCodeWidth + startX;
    //jijian fajian wang dian
    NSInteger sitesHeight = 110;
    NSInteger rowHeight = 60;
    
    PTCPCLTextFontName txtFont = PTCPCLTextFont7;
    PTCPCLTextFontName siteFont = PTCPCLTextFont4;
    
    PTCommandCPCL *command = [[PTCommandCPCL alloc] init];
    
    [command cpclLabelWithOffset:offsetX hRes:PTCPCLLabelResolution100 vRes:PTCPCLLabelResolution100 height:pageHeight quantity:1];
    [command cpclPageWidth:pageWidth];
    
    NSInteger lineSpacing = 1;
    //mu di wang dian suo shu zhong xin
    NSString *dispatchCenter = [billInfo objectForKey:kDispatchCenterKey];
    if (dispatchCenter != nil) {
        NSInteger centerX = pageWidth / 2;
        NSInteger centerY = startY;
        NSInteger safeHeight = topLogHeight;
        NSInteger width = centerX;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:siteFont fontSize:0 xPos:centerX yPos:centerY center:YES safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:dispatchCenter];
    }
    
    
    // 左上角寄件网点 到 右下角地址的框☐ --->
    NSInteger box1SX = col1X;
    NSInteger box1SY = topLogHeight;
    NSInteger box1EX = maxBoxWidth + startX;
    NSInteger box1EY = box1SY + sitesHeight + rowHeight * 2;
    [command cpclBoxWithXPos:box1SX yPos:box1SY xEnd:box1EX yEnd:box1EY thickness:lineWeight];
    
    //寄件/目的网点之间的竖线
    NSInteger sitesW = (box1EX - box1SX) / 2;
    NSInteger sitesLineX = box1SX + sitesW;
    NSInteger sitesLineY = box1SY;
    NSInteger siteLineEndY = sitesLineY + sitesHeight;
    NSInteger siteLineEndX = sitesLineX;
    [command cpclLineWithXPos:sitesLineX yPos:sitesLineY xEnd:siteLineEndX yEnd:siteLineEndY thickness:lineWeight];
    
    NSInteger siteCodeHeight = 40;
    NSInteger siteDeltaY = 10;
    NSInteger sendSiteY = box1SY + siteDeltaY;
    //ji jian wang dian
    NSString *sendSite = [billInfo objectForKey:kSendSiteKey];
    if (sendSite != nil) {
        NSInteger x = box1SX;
        NSInteger safeHeight = sitesHeight - siteCodeHeight;
        NSInteger width = sitesW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:siteFont fontSize:0 xPos:x yPos:sendSiteY center:YES safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:sendSite];
    }
    
    //ji jian wang dian bian hao
    NSInteger sendSiteCodeY = box1SY + sitesHeight - siteCodeHeight;
    NSString *sendCode = [billInfo objectForKey:kSendCodeKey];
    if (sendCode != nil) {
        NSInteger x = box1SX;
        NSInteger safeHeight = siteCodeHeight;
        NSInteger width = sitesW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 xPos:x yPos:sendSiteCodeY center:YES safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:sendCode];
    }
    
    
    //mu di wang dian
    NSInteger arriSiteX = box1SX + sitesW;
    NSString *arriveSite = [billInfo objectForKey:kArriveSiteKey];
    if (arriveSite != nil) {
        NSInteger y = sendSiteY;
        NSInteger safeHeight = siteCodeHeight;
        NSInteger width = sitesW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:siteFont fontSize:0 xPos:arriSiteX yPos:y center:YES safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:arriveSite];
    }
    
    //mu di wang dian bian hao
    NSString *dispatchCode = [billInfo objectForKey:kDispatchCodeKey];
    if (dispatchCode != nil) {
        NSInteger x = arriSiteX;
        NSInteger y = sendSiteCodeY;
        NSInteger safeHeight = siteCodeHeight;
        NSInteger width = sitesW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 xPos:x yPos:y center:YES safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:dispatchCode];
    }
    
    //end <---
    

    
    // 左上角运单号 到 右下角YYY-MM-dd的框 --->
    NSInteger box2X = col1X;
    NSInteger box2Y = box1SY + sitesHeight;
    NSInteger box2EX = box1EX;
    NSInteger box2EY = box2Y + rowHeight;
    [command cpclBoxWithXPos:box2X yPos:box2Y xEnd:box2EX yEnd:box2EY thickness:lineWeight];
    
    //左运单号 到 右YYY-MM-dd的框内的两条竖线
    NSInteger billCodeBoxW = 320;
    NSInteger line1SX = box1SX + billCodeBoxW;
    NSInteger line1SY = box1SY + sitesHeight;
    NSInteger line1EX = line1SX;
    NSInteger line1EY = line1SY + rowHeight;
    [command cpclBoxWithXPos:line1SX yPos:line1SY xEnd:line1EX yEnd:line1EY thickness:lineWeight];
    
    
    NSInteger weightW = (box1EX - line1EX) / 2;
    NSInteger line1_0SX = line1SX + weightW;
    NSInteger line1_0SY = line1SY;
    NSInteger line1_0EX = line1_0SX;
    NSInteger line1_0EY = line1SY + rowHeight;
    [command cpclBoxWithXPos:line1_0SX yPos:line1_0SY xEnd:line1_0EX yEnd:line1_0EY thickness:lineWeight];
    //end <---
    
    //yun dan hao
    NSString *billCodeTxt = [billInfo objectForKey:kBillCodeKey];
    if (billCodeTxt != nil) {
        NSInteger x = box2X + deltaX;
        NSInteger y = box2Y + deltaY;
        NSInteger safeHeight = rowHeight;
        NSInteger width = billCodeBoxW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(x) y:(y) safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:billCodeTxt];
    }
    
    //weight
    id  weight = [billInfo objectForKey:kWeightKey];
    NSInteger weithX = box1SX + billCodeBoxW;
    if(weight != nil){
        NSString *weightStr = [NSString stringWithFormat:@"%@",weight];
        NSInteger y = box2Y + deltaY;
        NSInteger safeHeight = rowHeight;
        NSInteger width = weightW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(weithX+deltaX) y:(y) safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:weightStr];
    }
    
    
    //lu dan ri qi
    NSString *billDateTxt = [HPrinterHelper billDateWithData:billInfo];
    NSInteger billDateY = box2Y;
    if (billDateTxt != nil) {
        NSInteger x = weithX + weightW + deltaX;
        NSInteger safeHeight = rowHeight;
        NSInteger width = weightW;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(x) y:(billDateY+deltaY) safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:billDateTxt];
    }
    
    NSString *adrTxt = [billInfo objectForKey:kAcceptAdrKey];
    if (adrTxt != nil) {
        NSInteger x = box2X + deltaX;
        NSInteger y = billDateY + rowHeight + deltaY;
        NSInteger safeHeight = rowHeight;
        NSInteger width = box1EX - box1SX;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(x) y:(y) safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:adrTxt];
    }
    
    
    //paisongfangshi、mingchen、geshu hang gao
    NSInteger secRowHeight = (pageHeight - box1EY) / 3;
    
    // paisongfangshi xia mian hengxian--->
    NSInteger barCodeBoxderW = 400;
    NSInteger line2SX = box1SX;
    NSInteger line2SY = box1EY + secRowHeight;
    NSInteger line2EX = box1EX - barCodeBoxderW;
    NSInteger line2EY = line2SY;
    [command cpclLineWithXPos:line2SX yPos:line2SY xEnd:line2EX yEnd:line2EY thickness:lineWeight];
    
    //竖线||||||||||||||||||||||||||||
    NSInteger vLine3SX = box1SX;
    NSInteger vLine3SY = box1EY;
    NSInteger vLine3EX = vLine3SX;
    NSInteger vLine3EY = vLine3SY + secRowHeight * 2;
    [command cpclLineWithXPos:vLine3SX yPos:vLine3SY xEnd:vLine3EX yEnd:vLine3EY thickness:lineWeight];
    
    //竖线||||||||||||||||||||||||||||
    NSInteger vLine4Width = (line2EX - line2SX) / 2;
    NSInteger vLine4SX = line2SX + vLine4Width;
    NSInteger vLine4SY = box1EY;
    NSInteger vLine4EX = vLine4SX;
    NSInteger vLine4EY = line2SY;
    [command cpclLineWithXPos:vLine4SX yPos:vLine4SY xEnd:vLine4EX yEnd:vLine4EY thickness:lineWeight];
    //end <---
    
    // pai song fang shi
    NSString *sendgoodsType = [billInfo objectForKey:kSendgoodsTypeKey];
    NSInteger goodsTypeX = box2X;
    NSInteger goodsTypeY = box1EY;
    if (sendgoodsType != nil) {
        NSInteger safeHeight = secRowHeight;
        NSInteger width = vLine4Width;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(goodsTypeX+deltaX) y:(goodsTypeY+deltaY) safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:sendgoodsType];
    }
    
    //wu ping ming cheng
    NSString *goodsName = [billInfo objectForKey:kGoodsNameKey];
    NSInteger goodsNameX = vLine4SX;
    NSInteger goodsNameY = vLine4SY;
    if (goodsName != nil) {
        NSInteger safeHeight = secRowHeight;
        NSInteger width = vLine4Width;
        [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(goodsNameX+deltaX) y:(goodsNameY+deltaY) safeHeight:safeHeight width:width lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:goodsName];
    }
    
    //jian shu suo ye ma
    NSInteger pageX = vLine3SX;
    NSInteger pageY = line2SY;
    NSInteger pageSafeHeight = secRowHeight;
    NSInteger pageIdxWidth = (line2EX - line2SX);

    [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(pageX+deltaX) y:(pageY+deltaY) safeHeight:pageSafeHeight width:pageIdxWidth lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:indexStr];
    
    
    // 左下角日期的框 --->
    NSInteger leftDX = startX;
    NSInteger letDY = box1EY + secRowHeight * 2;
    NSInteger leftEX = line2EX;
    NSInteger leftEY = letDY + secRowHeight;
    [command cpclBoxWithXPos:leftDX yPos:letDY xEnd:leftEX yEnd:leftEY thickness:lineWeight];
   
    
    //da yin ri qi
    NSString *currentDateStr = [NSDate currentDateStrBy:nil];
    NSInteger pDateX = leftDX;
    NSInteger pDateY = letDY;
    NSInteger pDateSafeHeight = secRowHeight;
    NSInteger pDateWidth = (leftEX - leftDX);
    [command cpclAutoTextWithRotate:PTCPCLStyleRotation0 font:txtFont fontSize:0 x:(pDateX+deltaX) y:(pDateY+deltaY) safeHeight:pDateSafeHeight width:pDateWidth lineSpacing:lineSpacing fontScale:PTCPCLFontScale_1 text:currentDateStr];
    
    //you xia jiao bCode box ---------
    NSInteger barCodeSX = leftEX;
    NSInteger barCodeSY = box1EY;
    NSInteger barCodeEX = box1EX;
    NSInteger barCodeEY = leftEY;
    [command cpclBoxWithXPos:barCodeSX yPos:barCodeSY xEnd:barCodeEX yEnd:barCodeEY thickness:lineWeight];
    
    NSInteger hBarCodeX = barCodeSX;
    NSInteger hBarCodeY = barCodeSY + 5;
    NSInteger hBarCodeHeight = barCodeEY - barCodeSY - 40;
    [command cpclBarcodeTextWithFont:PTCPCLTextFont8 fontSize:0 offset:5];
    [command cpclBarcode:PTCPCLBarcodeStyleCode128 width:1 ratio:PTCPCLBarcodeBarRatio0 height:hBarCodeHeight x:(hBarCodeX+90) y:hBarCodeY barcode:subCode];
    [command cpclBarcodeTextOff];
    

    //zuo ce tiao xing ma vertical
    NSInteger vBarCodeX = startX;
    NSInteger vBarCodeY = letDY - 30;
    [command cpclBarcodeVertical:PTCPCLBarcodeStyleCode128 width:1 ratio:PTCPCLBarcodeBarRatio0 height:(vBarCodeWidth-5) x:vBarCodeX y:vBarCodeY barcode:subCode];
    
    
    
    //end <---
    
    
    NSData *commandData = [command cmdData];
    
    [command cpclForm];
    [command cpclPrint];
    
    [[PTDispatcher share] sendData:commandData];
}







@end
