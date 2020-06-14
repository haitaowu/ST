//
//  MasterBillPrinter.m
//  BTDemo
// 发件网点、寄件客户存根打印
//  Created by ligl on 15-07-21.
//

#import "MasterBillPrinter.h"
#import "SPRTPrint.h"
#import "UIImage+Extension.h"
#import "SVProgressHUD.h"

//for issc
static NSString *const kWriteCharacteristicUUID_cj = @"49535343-8841-43F4-A8D4-ECBE34729BB3";
static NSString *const kReadCharacteristicUUID_cj = @"49535343-1E4D-4BD9-BA61-23C647249616";
static NSString *const kServiceUUID_cj = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
//for ivt
static NSString *const kFlowControlCharacteristicUUID = @"ff03";
static NSString *const kWriteCharacteristicUUID = @"ff02";
static NSString *const kReadCharacteristicUUID = @"ff01";
static NSString *const kServiceUUID = @"ff00";
//




#define kBillCodeKey            @"billCode"
#define kSendMan            	@"SEND_MAN"
#define kSendManPhone           @"SEND_MAN_PHONE"
#define kSendManAddress	        @"SEND_MAN_ADDRESS"
#define kAcceptMan	            @"ACCEPT_MAN"	//收件人
#define kAcceptManPhone         @"ACCEPT_MAN_PHONE" //收件人电话
#define kAcceptManAddress  	    @"ACCEPT_MAN_ADDRESS" //收件人地址
#define kDestination            @"DESTINATION"  //目的地

#define kGoodsName	            @"GOODS_NAME"   //货物名称
#define kGoodsPiece		        @"PIECE_NUMBER" //件数
#define kCalWeight		        @"SETTLEMENT_WEIGHT" //结算重量
#define kExpressType		    @"DISPATCH_MODE" //送货方式
#define kSendDate			    @"SEND_DATE" //寄件时间

#define kPaiedMoney			    @"TOPAYMENT" //到付款
#define kInsureVal			    @"INSURE_VALUE" //保价金额
#define kFreight			    @"FREIGHT" //运费




@interface MasterBillPrinter (){
	
}

@property(strong,nonatomic)CBCentralManager *centralManager;
@property(strong,nonatomic)CBPeripheral *selectedPeripheral;
@property(nonatomic,strong) NSThread *thread;
@property(nonatomic,assign) NSInteger managerState;
@property (weak, nonatomic) IBOutlet UIButton *connStateBtn;
@property (weak, nonatomic) IBOutlet UIButton *printBtn;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property(nonatomic,strong) NSArray *billCodes;


@end

@implementation MasterBillPrinter



- (void)viewDidLoad
{
    [super viewDidLoad];
	 cmd=0;
	 mtu = 20;
	 credit = 0;
	 response = 1;
	 cjFlag=1;           // qzfeng 2016/05/10
	
    if (self.billSN != nil) {
        self.reloadBtn.hidden = NO;
        [self reqPrintBillInfo];
    }else{
        self.reloadBtn.hidden = YES;
    }

    self.managerState = CBManagerStateUnknown;
	  //初始化后会调用代理CBCentralManagerDelegate 的 - (void)centralManagerDidUpdateState:(CBCentralManager *)central
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.title = @"打印运单";
    
    [self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
    [self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startScanConnectPrinter];
}

- (void)viewDidUnload
{
    [self setDeviceListTableView:nil];
    [super viewDidUnload];
}

- (void)startScanConnectPrinter{
    if (self.centralManager.isScanning == YES) {
        return;
    }
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopScanPeripheral) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(dismissConnectLoading) userInfo:nil repeats:NO];
}

- (void) stopScanPeripheral
{
    [self.centralManager stopScan];
    NSLog(@"stop scan");
}

- (void) dismissConnectLoading
{
    [SVProgressHUD dismiss];
}


#pragma mark - selectors
- (IBAction)tapToConnectBtn:(id)sender {
    if (self.managerState == CBManagerStatePoweredOn) {
        [self startScanConnectPrinter];
        [SVProgressHUD showWithStatus:@"连接打印机中..." maskType:SVProgressHUDMaskTypeBlack];
    }else{
        NSLog(@"打印机当前状态不可用");
    }
}

- (IBAction)tapReloadBillsData:(id)sender {
    [self reqPrintBillInfo];
}

- (IBAction)buttonPrintPNGorJPG:(id)sender {
	[self updateOperBtnsWithDisConnState];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self updateOperBtnsWithConnedState];
	});
	
	[self startPrintSiteTable];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self startPrintCustomerTable];
	});
	return;
	
    if (self.billInfo != nil) {
//        [self startPrintWithBillData:self.billInfo];
        self.thread = NULL;
    }else{
        [SVProgressHUD showInfoWithStatus:@"请重新加载运单数据"];
    }
}

#pragma mark - private methods
//发送秘钥
- (void)sendKeyChainToPrinter {
    Byte byte[] = {0x1B,0xFB,0x73,0x75,0x74,0x35,0x36,0x69,0x74,0x7A,0x78,0x00};
    NSData *data = [[NSData alloc] initWithBytes:byte length:12];
    if(![SPRTPrint printBin:data]){
        NSLog(@"Send Password Failed!");
    }else{
        NSLog(@"Send Password Success!");
    }
}

//打印机已经连接成功
- (void)updateOperBtnsWithConnedState
{
    [SVProgressHUD dismiss];
    self.connStateBtn.enabled = NO;
    self.printBtn.enabled = YES;
}

- (void)updateOperBtnsWithDisConnState
{
    self.connStateBtn.enabled = YES;
    self.printBtn.enabled = NO;
}

- (void)startPrintWithBillData:(NSDictionary*)billData
{
    NSString *billCodeStr = [billData objectForKey:kBillCodeKey];
    NSNumber *piecesNum = [billData objectForKey:kGoodsPiece];
    int maxIndex = [piecesNum intValue] - 1;
    NSArray *subCodesArra = [self subBillCodesWithBillData:billData];
    for(int index = 0; index < maxIndex ; index ++){
        int64_t seconds = index * 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *subCode = nil;
            if (index > (subCodesArra.count - 1)) {
                subCode = [subCodesArra firstObject];
            }else{
                subCode = [subCodesArra objectAtIndex:index];
            }
            NSString *indexStr = [NSString stringWithFormat:@"%d/%@",(index+2),piecesNum];
            [self printWithBillCode:billCodeStr subCode:subCode indexStr:indexStr];
        });
    }
}

///打印派件网点存根联的表格
- (void)startPrintSiteTable{
	[SPRTPrint pageSetup:800 pageHeightNum:500];
    int maxX = 800-10;
    int maxY = 500;
	int startX = 5;
	int startY = 10;
	int headerHeight = 180;
	int rowHeight = 75;
	int titleWidth = 80;
	int deltaX = 10 + 10;
	
    
    // 第一条横线--------------------------------
	 [SPRTPrint drawLine:2 startX:startX startY:startY endX:maxX endY:startY isFullline:false];
	
	//打印时间
	NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[self currentDateStr]];
	int sPrintDateW = 450;
	int sPrintDateH = 40;
	int sPrintDateX = startX + deltaX;
	int sPrintDateY = startY + headerHeight - sPrintDateH;
	[SPRTPrint drawText:sPrintDateX textY:sPrintDateY widthNum:sPrintDateW heightNum:sPrintDateH textStr:sPintDateTitle fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//派件网点存根联
	NSString *typeTitle = @"派件网点存根联:";
	int typeW = maxX - sPrintDateW - 60;
	int typeH = 40;
	int typeX = sPrintDateW + 60;
	int typeY = sPrintDateY;
	[SPRTPrint drawText:typeX textY:typeY widthNum:typeW heightNum:typeH textStr:typeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	NSString *billCode = @"8000017460324";
	int codeW = typeW;
	int codeH = 40;
	int codeX = typeX;
	int codeY = typeY - codeH;
	[SPRTPrint drawText:codeX textY:codeY widthNum:codeW heightNum:codeH textStr:billCode fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	// 横着的条码图形如果宽度不够就会导致打印出 bar Code data/parameter
    NSString *barCode = @"800001746032";
    int barCodeH = 80;
    int barCodeX = codeX - 80;
	int barCodeY = startY;
	[SPRTPrint drawBarCode:barCodeX startY:barCodeY textStr:barCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:barCodeH];
	
	
	// 第二条横线--------------------------------
	int start2Y = startY+headerHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start2Y endX:maxX endY:start2Y isFullline:false];
	
	//寄方
	NSString *senderTitle = @"寄方";
	int delataY = 10;
	int sTitleWidth = titleWidth;
	int sTitleHeight = rowHeight;
	int sTitleX = startX + deltaX;
	int sTitleY = startY + headerHeight + delataY;
	[SPRTPrint drawText:sTitleX textY:sTitleY widthNum:sTitleWidth heightNum:sTitleHeight textStr:senderTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	//收方
	NSString *receiverTitle = @"收方";
	int rTitleX = startX + deltaX;
	int rTitleY = sTitleY + rowHeight;
	int rTitleWidth = titleWidth;
	int rTitleHeight = rowHeight;
	[SPRTPrint drawText:rTitleX textY:rTitleY widthNum:rTitleWidth heightNum:rTitleHeight textStr:receiverTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//货物信息
	NSString *goodsTitle = @"货物信息";
	int goodsTitleY = rTitleY + rowHeight;
	int goodsTitleW = titleWidth  - 20;
	int goodsTitleX = startX + deltaX;
	int goodsTitleH = rowHeight;
	[SPRTPrint drawText:goodsTitleX textY:goodsTitleY widthNum:goodsTitleW heightNum:goodsTitleH textStr:goodsTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//收费信息
	NSString *feeTitle = @"收费信息";
	int feeTitleY = goodsTitleY + rowHeight;
	int feeTitleW = goodsTitleW;
	int feeTitleX = startX + deltaX;
	int feeTitleH = rowHeight;
	[SPRTPrint drawText:feeTitleX textY:feeTitleY widthNum:feeTitleW heightNum:feeTitleH textStr:feeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];

	// 第三条横线--------------------------------
	int start3Y = start2Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start3Y endX:maxX endY:start3Y isFullline:false];
	
	// 第四条横线--------------------------------
	int start4Y = start3Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start4Y endX:maxX endY:start4Y isFullline:false];
	
	// 第五条横线--------------------------------
	int start5Y = start4Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start5Y endX:maxX endY:start5Y isFullline:false];
	
	// 第六条横线--------------------------------
	int start6Y = start5Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start6Y endX:maxX endY:start6Y isFullline:false];
	
	//第一条竖线|||||||||||||||||||||||||||||
	int col1StartX = startX;
	[SPRTPrint drawLine:2 startX:col1StartX startY:startY endX:col1StartX endY:maxY isFullline:false];
	
	//第二条竖线|||||||||||||||||||||||||||||
	int col2StartX = col1StartX + titleWidth;
	int colo2StartY = startY + headerHeight;
	[SPRTPrint drawLine:2 startX:col2StartX startY:colo2StartY endX:col2StartX endY:maxY isFullline:false];
	
	
	//第三条竖线|||||||||||||||||||||||||||||
	int siteTextW = 160;
	int col3StartX = maxX - siteTextW;
	int colo3StartY = colo2StartY + rowHeight;
	int colo3EndY = colo3StartY + rowHeight;
	[SPRTPrint drawLine:2 startX:col3StartX startY:colo3StartY endX:col3StartX endY:colo3EndY isFullline:false];
	
	//寄件网点
	NSString *siteNameTitle = @"寄件网点:北京网点";
	int siteW = siteTextW;
	int siteH = rowHeight;
	int siteX = col3StartX;
	int siteY = rTitleY;
	[SPRTPrint drawText:siteX textY:siteY widthNum:siteW heightNum:siteH textStr:siteNameTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//第四条竖线|||||||||||||||||||||||||||||
	int col4StartX = col3StartX;
	int colo4StartY = colo3EndY + rowHeight;
	int colo4EndY = maxY;
	[SPRTPrint drawLine:2 startX:col4StartX startY:colo4StartY endX:col4StartX endY:colo4EndY isFullline:false];
	
	//收件客户签字
	NSString *signTitle = @"收件客户签字:";
	int signW = siteTextW;
	int signH = rowHeight;
	int signX = col3StartX;
	int signY = feeTitleY;
	[SPRTPrint drawText:signX textY:signY widthNum:signW heightNum:signH textStr:signTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//第五条竖线|||||||||||||||||||||||||||||
	int col5StartX = maxX;
	int colo5StartY = startY;
	int colo5EndY = maxY;
	[SPRTPrint drawLine:2 startX:col5StartX startY:colo5StartY endX:col5StartX endY:colo5EndY isFullline:false];
	
	[SPRTPrint print:0 skipNum:1];
}


///打印收件客户存根联的表格
- (void)startPrintCustomerTable{
	[SPRTPrint pageSetup:800 pageHeightNum:500];
    int maxX = 800-10;
    int maxY = 500;
	int startX = 5;
	int startY = 10;
	int headerHeight = 180;
	int rowHeight = 75;
	int titleWidth = 80;
	int deltaX = 10 + 10;
	
    
    // 第一条横线--------------------------------
	 [SPRTPrint drawLine:2 startX:startX startY:startY endX:maxX endY:startY isFullline:false];
	
	//打印时间
	NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[self currentDateStr]];
	int sPrintDateW = 450;
	int sPrintDateH = 40;
	int sPrintDateX = startX + deltaX;
	int sPrintDateY = startY + headerHeight - sPrintDateH;
	[SPRTPrint drawText:sPrintDateX textY:sPrintDateY widthNum:sPrintDateW heightNum:sPrintDateH textStr:sPintDateTitle fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//派件网点存根联
	NSString *typeTitle = @"收件客户存根联:";
	int typeW = maxX - sPrintDateW - 60;
	int typeH = 40;
	int typeX = sPrintDateW + 60;
	int typeY = sPrintDateY;
	[SPRTPrint drawText:typeX textY:typeY widthNum:typeW heightNum:typeH textStr:typeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	NSString *billCode = @"8000017460324";
	int codeW = typeW;
	int codeH = 40;
	int codeX = typeX;
	int codeY = typeY - codeH;
	[SPRTPrint drawText:codeX textY:codeY widthNum:codeW heightNum:codeH textStr:billCode fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	// 横着的条码图形
    NSString *barCode = @"800001746032";
    int barCodeH = 80;
    int barCodeX = codeX - 80;
	int barCodeY = startY;
	[SPRTPrint drawBarCode:barCodeX startY:barCodeY textStr:barCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:barCodeH];
	
	// 第二条横线--------------------------------
	int start2Y = startY+headerHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start2Y endX:maxX endY:start2Y isFullline:false];
	
	
	//寄方
	int delataY = 10;
	NSString *senderTitle = @"寄方";
	int sTitleWidth = titleWidth;
	int sTitleHeight = rowHeight;
	int sTitleX = startX + deltaX;
	int sTitleY = startY + headerHeight + delataY;
	[SPRTPrint drawText:sTitleX textY:sTitleY widthNum:sTitleWidth heightNum:sTitleHeight textStr:senderTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	//收方
	NSString *receiverTitle = @"收方";
	int rTitleX = startX + deltaX;
	int rTitleY = sTitleY + rowHeight;
	int rTitleWidth = titleWidth;
	int rTitleHeight = rowHeight;
	[SPRTPrint drawText:rTitleX textY:rTitleY widthNum:rTitleWidth heightNum:rTitleHeight textStr:receiverTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//货物信息
	NSString * goodsTitle = @"货物信息";
	int goodsTitleY = rTitleY + rowHeight;
	int goodsTitleW = titleWidth  - 20;;
	int goodsTitleX = startX + deltaX;
	int goodsTitleH = rowHeight;
	[SPRTPrint drawText:goodsTitleX textY:goodsTitleY widthNum:goodsTitleW heightNum:goodsTitleH textStr:goodsTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//收费信息
	NSString *payTitle = @"付费信息";
	int payTitleY = goodsTitleY + rowHeight;
	int payTitleW = titleWidth - 20;
	int payTitleX = startX + deltaX;
	int payTitleH = rowHeight;
	[SPRTPrint drawText:payTitleX textY:payTitleY widthNum:payTitleW heightNum:payTitleH textStr:payTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	// 第三条横线--------------------------------
	int start3Y = start2Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start3Y endX:maxX endY:start3Y isFullline:false];
	
	// 第四条横线--------------------------------
	int start4Y = start3Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start4Y endX:maxX endY:start4Y isFullline:false];
	
	// 第五条横线--------------------------------
	int start5Y = start4Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start5Y endX:maxX endY:start5Y isFullline:false];
	
	// 第六条横线--------------------------------
	int start6Y = start5Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start6Y endX:maxX endY:start6Y isFullline:false];
	
	//第一条竖线|||||||||||||||||||||||||||||
	int col1StartX = startX;
	[SPRTPrint drawLine:2 startX:col1StartX startY:startY endX:col1StartX endY:maxY isFullline:false];
	
	//第二条竖线|||||||||||||||||||||||||||||
	int col2StartX = col1StartX + titleWidth;
	int colo2StartY = startY + headerHeight;
	[SPRTPrint drawLine:2 startX:col2StartX startY:colo2StartY endX:col2StartX endY:maxY isFullline:false];
	

	//第三条竖线|||||||||||||||||||||||||||||
	int col5StartX = maxX;
	int colo5StartY = startY;
	int colo5EndY = maxY;
	[SPRTPrint drawLine:2 startX:col5StartX startY:colo5StartY endX:col5StartX endY:colo5EndY isFullline:false];
	
	[SPRTPrint print:0 skipNum:1];
}





- (void)printWithBillCode:(NSString*)billCode subCode:(NSString*)subCode indexStr:(NSString*)indexStr
{
    [SPRTPrint pageSetup:800 pageHeightNum:500];
    int maxX = 800-10;
    int maxY = 500;
    int topLogHeight = 130;
    //第一条竖线的x值|||||||||||||||||||||||||||||
    int col1x = 80;
    // 第一条横线--------------------------------
    int line1Y = topLogHeight;
    [SPRTPrint drawLine:2 startX:col1x startY:line1Y endX:maxX endY:line1Y isFullline:false];
    
    // iOS flag
    NSString *iOSStr = @"iOS";
    int flagWH = 40;
    int flagY = 5;
    int flagX = maxX - flagWH;
    [SPRTPrint drawText:(flagX) textY:(flagY) widthNum:flagWH heightNum:flagWH textStr:iOSStr fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];

   
    // 第二条横线--------------------------------
    int line2Y = line1Y+110;
    [SPRTPrint drawLine:2 startX:col1x startY:(120+120) endX:maxX endY:(120+120) isFullline:false];
    
    int verticalMargin = 60;
    // 第三条横线--------------------------------
    int line3Y = line2Y+verticalMargin;
    [SPRTPrint drawLine:2 startX:col1x startY:line3Y endX:maxX endY:line3Y isFullline:false];
    
    // 第四条横线--------------------------------
    int line4Y = line3Y+verticalMargin;
    [SPRTPrint drawLine:2 startX:col1x startY:line4Y endX:maxX endY:line4Y isFullline:false];
    
    int verticalShortMargin = (maxY - line4Y) / 3;
    //第三条竖线的x |||||||||||||||||||||||||||||
    int col3x = 320;
    
    // 第五条横线--------------------------------
    int line5Y = line4Y+verticalShortMargin;
    [SPRTPrint drawLine:2 startX:col1x startY:line5Y endX:col3x endY:line5Y isFullline:false];
    
    // 第六条横线--------------------------------
    int line6Y = line5Y+verticalShortMargin;
    [SPRTPrint drawLine:2 startX:0 startY:line6Y endX:col3x endY:line6Y isFullline:false];
    
    int barCodeStrWidth = 300;
    //第一条竖线 |||||||||||||||||||||||||||||
    [SPRTPrint drawLine:2 startX:col1x startY:line1Y endX:col1x endY:line6Y isFullline:false];
    
    int aLet3StrWidth = ((maxX - 60) / 2) / 11 ;
    int aLet4StrBoldWidth = ((maxX - 60) / 2) / 7;
    int aLet5StrBoldWidth = ((maxX - 60) / 2) / 6;
    int aLet3NumWidth = ((maxX - 60) / 2) / 22 ;
    
	
    // 寄件网点；
    NSString *sendSite = [self.billInfo objectForKey:kSendManAddress];
    int sendArrSiteWidth = (maxX - col1x) / 2;
    int sendSiteY = (topLogHeight+25);
//    int sendSiteMargin = (sendArrSiteWidth - (int)sendSite.length * aLet3StrWidth)/2;
    int sendSiteMargin = (sendArrSiteWidth - (int)sendSite.length * aLet4StrBoldWidth)/2;
    int sendSiteX = col1x + sendSiteMargin;
    if (sendSite != nil) {
        [SPRTPrint drawText:sendSiteX textY:sendSiteY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:sendSite fontSizeNum:4 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    // 寄件网点编号
    NSString *sendCode = [self.billInfo objectForKey:@"sendCode"];
    if (sendCode != nil) {
//        int sendCodeY = sendSiteY + 40;
        int sendCodeY = sendSiteY + 50;
        int sendCodeMargin = (sendArrSiteWidth - (int)sendCode.length * aLet3NumWidth)/2;
        int sendCodeX = col1x + sendCodeMargin;
        [SPRTPrint drawText:sendCodeX textY:sendCodeY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:sendCode fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    //运单号
    NSString *billCodeTxt = [self.billInfo objectForKey:kBillCodeKey];
    if (billCodeTxt != nil) {
        int billCodeMargin = (barCodeStrWidth - (int)billCodeTxt.length * aLet3NumWidth)/2;
        int billCodeTxtX = col1x + billCodeMargin;
        [SPRTPrint drawText:billCodeTxtX textY:(line2Y + 20) widthNum:barCodeStrWidth heightNum:verticalMargin textStr:billCodeTxt fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    }
    
    //第二条竖线|||||||||||||||||||||||||||||
    int col2x = col3x / 2;
    [SPRTPrint drawLine:2 startX:col2x startY:line4Y endX:col2x endY:line5Y isFullline:false];
    
    //第三条竖线|||||||||||||||||||||||||||||
    [SPRTPrint drawLine:2 startX:col3x startY:line4Y endX:col3x endY:maxY isFullline:false];
    // 详细地址内容
    NSString *adrTxt = [self.billInfo objectForKey:kSendManAddress];
    if (adrTxt != nil) {
        int adrTxtW = maxX - col1x;
        int margin = (adrTxtW - (int)adrTxt.length * aLet3StrWidth)/2;
        int startX = col1x + margin;
        [SPRTPrint drawText:startX textY:(line3Y + 15) widthNum:adrTxtW heightNum:verticalMargin textStr:adrTxt fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    }
    
    //第四条竖线|||||||||||||||||||||||||||||
    int col4x = barCodeStrWidth + col1x;
    [SPRTPrint drawLine:2 startX:col4x startY:line2Y endX:col4x endY:line3Y isFullline:false];
    
    //第五条竖线|||||||||||||||||||||||||||||
    int siteWidth = (maxX - col1x) / 2;
    int col5x = siteWidth + col1x;
    [SPRTPrint drawLine:2 startX:col5x startY:line1Y endX:col5x endY:line2Y isFullline:false];
    
    // 目的网点；
    NSString *arriveSite = [self.billInfo objectForKey:kSendManAddress];
    int arrSiteY = (topLogHeight+25);
    if (arriveSite != nil) {
//        int arrSiteMargin = (siteWidth - (int)arriveSite.length * aLet3StrWidth)/2;
        int arrSiteMargin = (siteWidth - (int)arriveSite.length * aLet4StrBoldWidth)/2;
        int arrSiteX = col5x + arrSiteMargin;
        [SPRTPrint drawText:arrSiteX textY:arrSiteY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:arriveSite fontSizeNum:4 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    // 目的网点编号
    NSString *dispatchCode = [self.billInfo objectForKey:@"dispatchCode"];
    if (dispatchCode != nil) {
//        int arriveSiteCodeY = arrSiteY + 40;
        int arriveSiteCodeY = arrSiteY + 50;
        int arriveSiteCodeMargin = (siteWidth - (int)dispatchCode.length * aLet3NumWidth)/2;
        int arriveSiteCodeX = col5x + arriveSiteCodeMargin;
        [SPRTPrint drawText:arriveSiteCodeX textY:arriveSiteCodeY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:dispatchCode fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    //派送方式
    NSString *sendgoodsType = [self.billInfo objectForKey:@"sendgoodsType"];
    if (sendgoodsType != nil) {
        int width = col2x - col1x;
        int margin = (width - (int)sendgoodsType.length * aLet3StrWidth)/2;
        int x =  margin + col1x;
        int y = line4Y + 10;
        [SPRTPrint drawText:x textY:y widthNum:col2x heightNum:verticalShortMargin textStr:sendgoodsType fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    //物品名称
    NSString *goodsName = [self.billInfo objectForKey:@"goodsName"];
    if (goodsName != nil) {
        int width = col3x - col2x;
        int margin = (width - (int)goodsName.length * aLet3StrWidth)/2;
        int x =  margin + col2x;
        int y = line4Y + 10;
        [SPRTPrint drawText:x textY:y widthNum:width heightNum:verticalShortMargin textStr:goodsName fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    }
    
    //分件数/总件数:
    int width = col3x - col1x;
    int margin = (width - (int)indexStr.length * aLet3StrWidth)/2;
    int x =  margin + col1x;
    int y = line5Y + 10;
    [SPRTPrint drawText:x textY:(y) widthNum:width heightNum:verticalShortMargin textStr:indexStr fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    //打印日期
    NSString *currentDateStr = [self currentDateStr];
    if (currentDateStr != nil) {
        int width = col3x;
        int x =  50;
        int y = line6Y + 15;
        [SPRTPrint drawText:x textY:y widthNum:width heightNum:verticalShortMargin textStr:currentDateStr fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    }

    //最顶部的竖线|||||||||||||||||||||||||||||
    int topVerticalLinex = col5x - 100;
//    [SPRTPrint drawLine:2 startX:topVerticalLinex startY:0 endX:topVerticalLinex endY:line1Y isFullline:false];
    //目的网点所属中心
    NSString *dispatchCenter = [self.billInfo objectForKey:@"dispatchCenter"];
    if (dispatchCenter != nil) {
        int dispatchW = maxX - topVerticalLinex;
        int dispatchMargin = (dispatchW - (int)dispatchCenter.length * aLet5StrBoldWidth)/2;
        int dispatchX = topVerticalLinex + dispatchMargin;
        int dispatchY = 30;
        [SPRTPrint drawText:dispatchX textY:dispatchY widthNum:dispatchW heightNum:line1Y textStr:dispatchCenter fontSizeNum:5 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    // 横着的条码图形
    NSString *barCode = [billCode stringByAppendingFormat:@"%@",subCode];
    int barCodeH = 80;
    int barCodeX = col3x + 20;
    int barCodeY = line4Y + 20;
    if (barCode != nil) {
        [SPRTPrint drawBarCode:(barCodeX) startY:barCodeY textStr:barCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:barCodeH];
    }
    
    //横着的条码数字字符串
    int barNumY = barCodeY + 80;
    int barNumX = barCodeX + 85;
    NSString *barCodeNumStr = [billCode stringByAppendingFormat:@" %@",subCode];
     [SPRTPrint drawText:(barNumX) textY:(barNumY) textStr:barCodeNumStr fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    // 竖着的条码图形
    int barCodeVerticalMargin = 20;
    int verticalBarCodeH = col1x - barCodeVerticalMargin;
    int barCodeVerticalX = (int)(barCodeVerticalMargin * 0.5);
    int varCodeVerticalY = line6Y - 15;
    if (barCode != nil) {
        [SPRTPrint drawBarCode:(barCodeVerticalX) startY:varCodeVerticalY textStr:barCode typeNum:1 roateNum:1 lineWidthNum:2 heightNum:verticalBarCodeH];
    }

    //第六条竖线
    int col6x = col5x + 200;
    [SPRTPrint drawLine:2 startX:col6x startY:line2Y endX:col6x endY:line3Y isFullline:false];;
    
    //重量
    id  weight = [self.billInfo objectForKey:kCalWeight];
    NSString *weightTxt = [NSString stringWithFormat:@"%@KG",weight];
    if(weightTxt != nil){
        int weightW = col6x - col4x;
        int weightMargin = (weightW - (int)weightTxt.length * aLet3NumWidth)/2;
        int weightX = col4x + weightMargin;
        [SPRTPrint drawText:weightX textY:(line2Y + 20) widthNum:weightW heightNum:verticalMargin textStr:weightTxt fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    }
    
   //录单时间
    NSString *billDateTxt = [self billDateWithData:self.billInfo];
    if (billDateTxt != nil) {
        int regDateTxtW = maxX - col6x;
        [SPRTPrint drawText:(col6x+15) textY:(line2Y + 20) widthNum:regDateTxtW heightNum:verticalMargin textStr:billDateTxt fontSizeNum:2 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }

    

    //顶部线框
//    [SPRTPrint drawLine:2 startX:0 startY:0 endX:maxX endY:0 isFullline:false];
    
    //左部线框
    [SPRTPrint drawLine:2 startX:0 startY:line6Y endX:0 endY:maxY isFullline:false];
    
    //右部线框
    [SPRTPrint drawLine:2 startX:maxX startY:line1Y endX:maxX endY:maxY isFullline:false];
    
    //底部线框
    [SPRTPrint drawLine:2 startX:0 startY:maxY endX:maxX endY:maxY isFullline:false];
    
    [SPRTPrint print:0 skipNum:1];
}

//录单时间
- (NSString*)billDateWithData:(NSDictionary*)data
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *billDateStr = [data objectForKey:kSendDate];
    NSDate *billDate = [formatter dateFromString:billDateStr];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *formatBillDateStr = [formatter stringFromDate:billDate];
    formatBillDateStr = [NSString stringWithFormat:@"%@",formatBillDateStr];
    return formatBillDateStr;
}

//打印时间
- (NSString*)currentDateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    return todayStr;
}

- (NSArray *)subBillCodesWithBillData:(NSDictionary*)billInfo
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *subBillCodeStr = [billInfo objectForKey:@"billCodeSub"];
    NSCharacterSet *semicolonCharSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    subBillCodeStr = [subBillCodeStr stringByTrimmingCharactersInSet:semicolonCharSet];
    NSArray *subCodesArra = [subBillCodeStr componentsSeparatedByCharactersInSet:semicolonCharSet];
    NSString *billCode = [billInfo objectForKey:@"billCode"];
    for (NSString *codeStr in subCodesArra) {
        NSString *subCodeStr = [codeStr stringByReplacingOccurrencesOfString:billCode withString:@""];
        if (subCodeStr.length > 0) {
            [array addObject:subCodeStr];
        }
    }
    return array;
}

#pragma mark - request server
- (void)reqPrintBillInfo
{
    [SVProgressHUD showWithStatus:@"加载运单数据" maskType:SVProgressHUDMaskTypeBlack];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURL *url = [NSURL URLWithString:@"http://58.215.182.251:5889/AndroidService/m8/qryBillSub.do"];
    NSMutableURLRequest *mutRequest = [NSMutableURLRequest requestWithURL:url];
    mutRequest.HTTPMethod = @"POST";
//    NSString *pieceNumber = self.billInfo[@"pieceNumber"];
    NSString *billCode = self.billSN;
    NSString *paramsStr = [NSString stringWithFormat:@"billCode=%@",billCode];
    NSData *bodyData = [paramsStr dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:bodyData];
    mutRequest.HTTPBodyStream = inputStream;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:mutRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        id thread = [NSThread currentThread];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        if (error) {
            NSLog(@"respose error = %@",error);
        }else{
            NSError *jsonError = nil;
            NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            if (jsonError) {
                NSLog(@"jsonError = %@",jsonError);
            }else{
                NSLog(@"response dict = %@",respDict);
                id billInfos = [respDict objectForKey:@"data"];
                if ([billInfos count] > 0) {
                    NSLog(@"billInfo = %@",billInfos);
//                    self.billCodes = billCodes;
                    self.billInfo = [billInfos firstObject];
                }
            }
        }
    }];
    
    [dataTask resume];
}

#pragma  mark -- CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * state = nil;
		switch ([central state])
		{
			case CBManagerStateUnsupported:
				state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
				break;
			case CBManagerStateUnauthorized:
				state = @"The app is not authorized to use Bluetooth Low Energy.";
				break;
			case CBManagerStatePoweredOff:
                [SVProgressHUD showInfoWithStatus:@"请先打开蓝牙哦"];
				state = @"Bluetooth is currently powered off.";
				break;
			case CBManagerStatePoweredOn:
				state = @"work";
				break;
			case CBManagerStateUnknown:
			default:
			;
		}
    self.managerState = [central state];
		NSLog(@"Central manager state: %@", state); 
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (peripheral)
    {
        NSLog(@"foundDevice. name[%s],RSSI[%d]\n",peripheral.name.UTF8String,peripheral.RSSI.intValue);
        if ( [peripheral.name isEqualToString:@"L51 BT Printer"] )
        {
            self.selectedPeripheral = peripheral;
            [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
            [self stopScanPeripheral];
            NSLog(@"start to connect to L51 BT Printer ");
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"has connected");
        //[mutableData setLength:0];
    self.selectedPeripheral.delegate = self;
    //此时设备已经连接上了  你要做的就是找到该设备上的指定服务 调用完该方法后会调用代理CBPeripheralDelegate（现在开始调用另一个代理的方法了）的
    //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
    
    // qzfeng begin 2016/05/10
    [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID_cj]]];
    // qzfeng end 2016/05/10
    if (self.selectedPeripheral.state == CBPeripheralStateConnected) {
        activeDevice = peripheral;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendKeyChainToPrinter];
//            [self updateOperBtnsWithConnedState];
        });
    }
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    [self alertMessage:@"连接断开！"];
    [self updateOperBtnsWithDisConnState];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //此时连接发生错误
    NSLog(@"connected periphheral failed");
    [self alertMessage:@"连接失败！"];
    [self updateOperBtnsWithDisConnState];
}


#pragma mark -- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:error
{
		if (error==nil) 
		{
			NSLog(@"Write edata failed!");
			return;
		}
		NSLog(@"Write edata success!");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error==nil) 
    {
        //在这个方法中我们要查找到我们需要的服务  然后调用discoverCharacteristics方法查找我们需要的特性
        //该discoverCharacteristics方法调用完后会调用代理CBPeripheralDelegate的
        //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        for (CBService *service in peripheral.services) 
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) 
            {
                cjFlag=0;           // qzfeng 2016/05/10
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                [peripheral discoverCharacteristics:nil forService:service];
            }
            else if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID_cj]])
            {
                cjFlag=1;       // qzfeng 2016/05/10
                [peripheral discoverCharacteristics:nil forService:service];
            }
            // qzfeng end 2016/05/10
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error==nil) {
        //在这个方法中我们要找到我们所需的服务的特性 然后调用setNotifyValue方法告知我们要监测这个服务特性的状态变化
        //当setNotifyValue方法调用后调用代理CBPeripheralDelegate的- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        for (CBCharacteristic *characteristic in service.characteristics) 
        {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) 
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeReadCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFlowControlCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeFlowControlCharacteristic = characteristic;
                credit = 0;
                response = 1;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID_cj]]) {
            // qzfeng begin 2016/05/10
            
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID_cj]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeReadCharacteristic = characteristic;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
		NSLog(@"enter didUpdateNotificationStateForCharacteristic!");
    if (error==nil) 
    {
        //调用下面的方法后 会调用到代理的- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
		[self updateOperBtnsWithConnedState];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value; 
    NSLog(@"read data=%@!",data);
    if (characteristic == activeFlowControlCharacteristic) {
        NSData * data = [characteristic value];
        NSUInteger len = [data length];
        int bytesRead = 0;
        if (len > 0) {
            unsigned char * measureData = (unsigned char *) [data bytes];
            unsigned char field = * measureData;
            measureData++;
            bytesRead++;
            if(field == 2){
                unsigned char low  = * measureData;
                measureData++;
                mtu =  low + (* measureData << 8);
            }
            if(field == 1){
                if(credit < 5) {
                    credit += * measureData;
                }
            }
        }
    }
}


-(void) alertMessage:(NSString *)msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"关闭" 
                                         otherButtonTitles:nil];
    [alert show];

}
@end
