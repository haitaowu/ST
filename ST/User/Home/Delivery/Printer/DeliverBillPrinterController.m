//
//  DeliverBillPrinterController.m
//  BTDemo
// 派件网点、收件客户存根打印
//  Created by ligl on 15-07-21.
//

#import "DeliverBillPrinterController.h"
#import "SPRTPrint.h"
#import "UIImage+Extension.h"
#import "SVProgressHUD.h"
#import "BluetoothListController.h"
#import "TscCommand.h"
#import "NSDate+Category.h"



#define kBillCodeKey            @"billCode"
#define kSendMan            	@"sendMan"
#define kSendManPhone           @"sendManPhone"
#define kSendManAddress	        @"sendManAddress" //寄件人地址
#define kAcceptMan	            @"acceptMan"	//收件人
#define kAcceptManPhone         @"acceptManPhone" //收件人电话
#define kAcceptManAddress  	    @"acceptManAddress" //收件人地址
#define kDestination            @"DESTINATION"  //目的地

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

#define kPaiedMoney			    @"paymentType" //到付款
#define kInsureVal			    @"insureValue" //保价金额
#define kFreight			    @"freight" //运费




@interface DeliverBillPrinterController (){
}

@property(strong,nonatomic)CBCentralManager *centralManager;
@property(strong,nonatomic)CBPeripheral *selectedPeripheral;
@property(nonatomic,assign) NSInteger managerState;
@property (weak, nonatomic) IBOutlet UIButton *connStateBtn;
@property (weak, nonatomic) IBOutlet UIButton *printBtn;
@property(nonatomic,assign) PrinterType printerType;
@property (weak, nonatomic) IBOutlet UILabel *connState;


@property(nonatomic,assign) int barCodeWidth;


@end

@implementation DeliverBillPrinterController



- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"打印派单";
  self.barCodeWidth = 110;
  self.printerType = NONPRINTER;
  cmd=0;
  mtu = 20;
  credit = 0;
  response = 1;
  cjFlag=1;           // qzfeng 2016/05/10
  
	[self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
	[self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];

}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[Manager close];
	NSLog(@"viewWill Disappear....");
}



- (void)updateConnectState:(ConnectState)state printerType:(PrinterType)type{
    dispatch_async(dispatch_get_main_queue(), ^{
		self.printerType = type;
        switch (state) {
            case CONNECT_STATE_CONNECTING:
                self.connState.text = @"连接状态：连接中....";
                break;
			case CONNECT_STATE_CONNECTED:
			{
                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
				self.printBtn.enabled = YES;
				NSString *name = Manager.bleConnecter.connPeripheral.name;
				NSString *title = @"连接状态：";
				title = [title stringByAppendingFormat:@"%@已连接",name];
                self.connState.text = title;
				break;
			}
            case CONNECT_STATE_FAILT:
                [SVProgressHUD showErrorWithStatus:@"连接失败"];
                self.connState.text = @"连接状态：连接失败";
                break;
            case CONNECT_STATE_DISCONNECT:
			{
//				NSString *name = Manager.bleConnecter.connPeripheral.name;
//				NSString *title = [@"断开连接设备:" stringByAppendingFormat:@"%@",name];
				NSString *title = @"已断开连接设备";
                [SVProgressHUD showInfoWithStatus:title];
                self.connState.text = @"连接状态：断开连接";
                break;
			}
            default:
                self.connState.text = @"连接状态：连接超时";
                break;
        }
    });
}


#pragma mark - selectors
- (IBAction)tapToConnectBtn:(id)sender {
	BluetoothListController *listControl = [[BluetoothListController alloc] init];
	__weak typeof(self) weakSelf = self;
	listControl.connResultBlock = ^(ConnectState state, PrinterType type) {
		if (CONNECT_STATE_CONNECTED == state) {
      if (type == weakSelf.printerType) {
//        [weakSelf.navigationController popViewControllerAnimated:YES];
      }
		}
		[self updateConnectState:state printerType:type];
	};
  [self.navigationController pushViewController:listControl animated:YES];
  
}


///start to print bill
- (IBAction)startToPrint:(id)sender {
	if (self.printerType == SPRINTER) {
		[self sendKeyChainToPrinter];
		[self startPrintSiteTable];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self startPrintCustomerTable];
		});
	}else{
		[Manager write:[self siteLabelCommand]];
		[Manager write:[self senderLabelCommand]];
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


// paijian di zhi / shou jian ren dizhi
- (NSString*)addressDetail:(NSDictionary*)billInfo type:(NSString*)adrType{
  NSArray* keys;
  if ([adrType isEqualToString:@"1"]) {
    //paijian di zhi
//    keys = @[@"PROVINCE",@"CITY",@"BOROUGH",@"SEND_MAN_ADDRESS"];
	  keys = @[kSendManAddress];
  }else{
    //shou jian di zhi
//    keys = @[@"PROVINCE_NAME",@"CITY_NAME",@"COUNTY_NAME",@"ACCEPT_MAN_ADDRESS"];
	  keys = @[kAcceptManAddress];
  }

  NSString *adr = @"";
  for (NSString* keyStr in keys) {
    NSString *valueStr = [billInfo objectForKey:keyStr];
    if (valueStr != nil) {
      adr = [adr stringByAppendingFormat:@"%@",valueStr];
    }
  }
  return adr;
}

///jian ke hu huo wu xin xi ji
- (NSString*)goodsInfo:(id)billInfo
{
  NSString *goods = @"";
  NSString *name = [billInfo objectForKey:kGoodsName];
  if ((name != nil) && (name.length > 0)){
    goods = [goods stringByAppendingFormat:@"名称:%@、",name];
  }
  NSString *pieces = [billInfo objectForKey:kGoodsPiece];
  if (pieces != nil){
    goods = [goods stringByAppendingFormat:@"件数:%@、",pieces];
  }
  NSString *weight = [billInfo objectForKey:kCalWeight];
  if (weight != nil) {
    goods = [goods stringByAppendingFormat:@"重量:%@、",weight];
  }
  NSString *tranType = [billInfo objectForKey:kExpressType];
	if ((tranType != nil) && (tranType.length > 0)){
    goods = [goods stringByAppendingFormat:@"送货方式:%@、",tranType];
  }
  NSString *sign = [billInfo objectForKey:kBlReturnBill];
  if (sign != nil){
    goods = [goods stringByAppendingFormat:@"签回单标识:%@、",sign];
  }
	
  NSString *storage = [billInfo objectForKey:kInStorage];
  if (storage != nil){
    goods = [goods stringByAppendingFormat:@"进仓标识:%@、",storage];
  }
  
  NSString *date = [billInfo objectForKey:kSendDate];
  if (date != nil) {
    goods = [goods stringByAppendingFormat:@"寄件日期:%@",date];
  }

  return goods;
}

///pai jian wang dian huo wu xin xi
- (NSString*)sendGoodsInfo:(id)billInfo
{
  NSString *goods = @"";
  NSString *name = [billInfo objectForKey:kGoodsName];
  if ((name != nil) && (name.length > 0)){
    goods = [goods stringByAppendingFormat:@"名称:%@、",name];
  }
  NSString *pieces = [billInfo objectForKey:kGoodsPiece];
  if (pieces != nil){
    goods = [goods stringByAppendingFormat:@"件数:%@、",pieces];
  }
  NSString *weight = [billInfo objectForKey:kCalWeight];
  if (weight != nil) {
    goods = [goods stringByAppendingFormat:@"重量:%@、",weight];
  }
  NSString *tranType = [billInfo objectForKey:kExpressType];
  if ((tranType != nil)  && (tranType.length > 0)){
    goods = [goods stringByAppendingFormat:@"送货方式:%@、",tranType];
  }
  
  NSString *weightCount = [billInfo objectForKey:kOverWeightPiece];
  if (weightCount != nil){
    goods = [goods stringByAppendingFormat:@"超重件数:%@、",weightCount];
  }
  
  NSString *overSize = [billInfo objectForKey:@"BL_OVER_LONG"];
  if (overSize != nil) {
    goods = [goods stringByAppendingFormat:@"超长标识:%@、",overSize];
  }
  
  NSString *rCode = [billInfo objectForKey:kRbillCode];
  if ((rCode != nil) && (rCode.length > 0)){
    goods = [goods stringByAppendingFormat:@"回单编号:%@、",rCode];
  }
	
  NSString *storageCode = [billInfo objectForKey:kStorageno];
  if ((storageCode != nil) && (storageCode.length > 0) ){
    goods = [goods stringByAppendingFormat:@"进仓编号:%@、",storageCode];
  }
  
  NSString *date = [billInfo objectForKey:kSendDate];
  if ((date != nil) && (date.length > 0)){
    goods = [goods stringByAppendingFormat:@"寄件日期:%@",date];
  }

  return goods;
}


///fei yong
- (NSString*)feesTxtBy:(id)billInfo
{
  NSString *fees = @"";
  NSString *payType = [billInfo objectForKey:kPaiedMoney];
  if (payType != nil) {
    fees = [fees stringByAppendingFormat:@"%@:",payType];
    NSString *cash = [billInfo objectForKey:kFreight];
    if (payType != nil) {
      fees = [fees stringByAppendingFormat:@"%@、",cash];
    }
  }
  NSString *count = [billInfo objectForKey:kInsureVal];
  if (count != nil) {
    fees = [fees stringByAppendingFormat:@"保价金额:%@、",count];
  }
  NSString *pay = [billInfo objectForKey:kFreight];
  if (pay != nil) {
    fees = [fees stringByAppendingFormat:@"运费:%@",pay];
  }
  return fees;
}


///string return value
- (NSString*)strValueOf:(NSDictionary*)billInfo key:(NSString*)keyStr
{
  id value = [billInfo objectForKey:keyStr];
  if (value == nil) {
    return @"";
  }else{
    return [NSString stringWithFormat:@"%@",value];
  }
}



#pragma mark- SPrinter
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
	NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[NSDate currentDateStrBy:nil]];
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
	
	
	NSString *billCode = [self strValueOf:self.billInfo key:kBillCodeKey];
//	NSString *billCode = @"8000056666671";
	int codeW = typeW;
	int codeH = 40;
	int codeX = typeX;
	int codeY = typeY - codeH;
	[SPRTPrint drawText:codeX textY:codeY widthNum:codeW heightNum:codeH textStr:billCode fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	// 横着的条码图形如果宽度不够就会导致打印出 bar Code data/parameter
    NSString *barCode = billCode;
    int barCodeH = 80;
	int barCodeX = codeX - self.barCodeWidth;
	int barCodeY = startY;
	[SPRTPrint drawBarCode:barCodeX startY:barCodeY textStr:barCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:barCodeH];
	
	// 第二条横线--------------------------------
	int start2Y = startY+headerHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start2Y endX:maxX endY:start2Y isFullline:false];
	
	
	//寄方 start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString *senderTitle = @"寄方";
	int delataY = 10;
	int sTitleWidth = titleWidth;
	int sTitleHeight = rowHeight;
	int sTitleX = startX + deltaX;
	int sTitleY = startY + headerHeight + delataY;
	[SPRTPrint drawText:sTitleX textY:sTitleY widthNum:sTitleWidth heightNum:sTitleHeight textStr:senderTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//phone
	NSString *sPhone = [self strValueOf:self.billInfo key:kSendManPhone];
	int sPhoneW = maxX - titleWidth;
	int sPhoneH = rowHeight / 2;
	int sPhoneX = titleWidth + deltaX;
	int sPhoneY = sTitleY;
	[SPRTPrint drawText:sPhoneX textY:sPhoneY widthNum:sPhoneW heightNum:sPhoneH textStr:sPhone fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//address
	NSString *sAdress = [self addressDetail:self.billInfo type:@"1"];
	int sAdrW = sPhoneW;
	int sAdrH = sPhoneH;
	int sAdrX = sPhoneX;
	int sAdrY = sPhoneY + sPhoneH;
	[SPRTPrint drawText:sAdrX textY:sAdrY widthNum:sAdrW heightNum:sAdrH textStr:sAdress fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//寄方 end==========================================
	
	
	//收方start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString *receiverTitle = @"收方";
	int rTitleX = startX + deltaX;
	int rTitleY = sTitleY + rowHeight;
	int rTitleWidth = titleWidth;
	int rTitleHeight = rowHeight;
	[SPRTPrint drawText:rTitleX textY:rTitleY widthNum:rTitleWidth heightNum:rTitleHeight textStr:receiverTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//phone
	NSString *rPhone = [self strValueOf:self.billInfo key:kAcceptManPhone];
	int rPhoneW = maxX - titleWidth;
	int rPhoneH = rowHeight / 2;
	int rPhoneX = titleWidth + deltaX;
	int rPhoneY = rTitleY;
	[SPRTPrint drawText:rPhoneX textY:rPhoneY widthNum:rPhoneW heightNum:rPhoneH textStr:rPhone fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//address
	NSString *rAddress = [self addressDetail:self.billInfo type:@"0"];
	int rAdrW = rPhoneW;
	int rAdrH = rPhoneH;
	int rAdrX = rPhoneX;
	int rAdrY = rPhoneY + rPhoneH;
	[SPRTPrint drawText:rAdrX textY:rAdrY widthNum:rAdrW heightNum:rAdrH textStr:rAddress fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//收方 end==========================================
	
	
	//货物信息start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString *goodsTitle = @"货物信息";
	int goodsTitleY = rTitleY + rowHeight;
	int goodsTitleW = titleWidth  - 20;
	int goodsTitleX = startX + deltaX;
	int goodsTitleH = rowHeight;
	[SPRTPrint drawText:goodsTitleX textY:goodsTitleY widthNum:goodsTitleW heightNum:goodsTitleH textStr:goodsTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//hu wu xin xi
	NSString *goods = [self sendGoodsInfo:self.billInfo];
	int goodsW = maxX - titleWidth - 10;
	int goodsH = rowHeight;
	int goodsX = titleWidth + deltaX;
	int goodsY = goodsTitleY;
	[SPRTPrint drawText:goodsX textY:goodsY widthNum:goodsW heightNum:goodsH textStr:goods fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//货物信息 end==========================================
	
	
	//收费信息start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString *feeTitle = @"收费信息";
	int feeTitleY = goodsTitleY + rowHeight;
	int feeTitleW = goodsTitleW;
	int feeTitleX = startX + deltaX;
	int feeTitleH = rowHeight;
	[SPRTPrint drawText:feeTitleX textY:feeTitleY widthNum:feeTitleW heightNum:feeTitleH textStr:feeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//shou fei xin xi
	NSString *fee = [self feesTxtBy:self.billInfo];
	int feeW = maxX - titleWidth;
	int feeH = rowHeight;
	int feeX = titleWidth + deltaX;
	int feeY = feeTitleY;
	[SPRTPrint drawText:feeX textY:feeY widthNum:feeW heightNum:feeH textStr:fee fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//收费信息 end==========================================
	

	// 第三条横线--------------------------------
	int start3Y = start2Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start3Y endX:maxX endY:start3Y isFullline:false];
	
	// 第四条横线--------------------------------
	int start4Y = start3Y + rowHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start4Y endX:maxX endY:start4Y isFullline:false];
	
	// 第五条横线--------------------------------
	int start5Y = start4Y + rowHeight + startY;
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
	int colo3StartY = colo2StartY;
	int colo3EndY = colo3StartY + rowHeight;
	[SPRTPrint drawLine:2 startX:col3StartX startY:colo3StartY endX:col3StartX endY:colo3EndY isFullline:false];
	
	//寄件网点
	NSString *destination = [self strValueOf:self.billInfo key:kDestination];
	NSString *siteNameTitle = [@"寄件网点:" stringByAppendingFormat:@"%@",destination];
	int siteW = siteTextW;
	int siteH = rowHeight;
	int siteX = col3StartX;
	int siteY = colo3StartY;
	[SPRTPrint drawText:siteX textY:siteY widthNum:siteW heightNum:siteH textStr:siteNameTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//第四条竖线|||||||||||||||||||||||||||||
	int col4StartX = col3StartX;
	int colo4StartY = start5Y;
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
	NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[NSDate currentDateStrBy:nil]];
	int sPrintDateW = 450;
	int sPrintDateH = 40;
	int sPrintDateX = startX + deltaX;
	int sPrintDateY = startY + headerHeight - sPrintDateH;
	[SPRTPrint drawText:sPrintDateX textY:sPrintDateY widthNum:sPrintDateW heightNum:sPrintDateH textStr:sPintDateTitle fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	//收件客户存根联
	NSString *typeTitle = @"收件客户存根联:";
	int typeW = maxX - sPrintDateW - 60;
	int typeH = 40;
	int typeX = sPrintDateW + 60;
	int typeY = sPrintDateY;
	[SPRTPrint drawText:typeX textY:typeY widthNum:typeW heightNum:typeH textStr:typeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	NSString *billCode = [self strValueOf:self.billInfo key:kBillCodeKey];
	int codeW = typeW;
	int codeH = 40;
	int codeX = typeX;
	int codeY = typeY - codeH;
	[SPRTPrint drawText:codeX textY:codeY widthNum:codeW heightNum:codeH textStr:billCode fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	// 横着的条码图形
    NSString *barCode = billCode;
    int barCodeH = 80;
	int barCodeX = codeX - self.barCodeWidth;
	int barCodeY = startY;
	[SPRTPrint drawBarCode:barCodeX startY:barCodeY textStr:barCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:barCodeH];
	
	// 第二条横线--------------------------------
	int start2Y = startY+headerHeight;
	[SPRTPrint drawLine:2 startX:startX startY:start2Y endX:maxX endY:start2Y isFullline:false];
	
	
	//寄方start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	int delataY = 10;
	NSString *senderTitle = @"寄方";
	int sTitleWidth = titleWidth;
	int sTitleHeight = rowHeight;
	int sTitleX = startX + deltaX;
	int sTitleY = startY + headerHeight + delataY;
	[SPRTPrint drawText:sTitleX textY:sTitleY widthNum:sTitleWidth heightNum:sTitleHeight textStr:senderTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//phone
	NSString *sPhone = [self strValueOf:self.billInfo key:kSendManPhone];
	int sPhoneW = maxX - titleWidth;
	int sPhoneH = rowHeight / 2;
	int sPhoneX = titleWidth + deltaX;
	int sPhoneY = sTitleY;
	[SPRTPrint drawText:sPhoneX textY:sPhoneY widthNum:sPhoneW heightNum:sPhoneH textStr:sPhone fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//address
	NSString *sAdress = [self addressDetail:self.billInfo type:@"1"];;
	int sAdrW = sPhoneW;
	int sAdrH = sPhoneH;
	int sAdrX = sPhoneX;
	int sAdrY = sPhoneY + sPhoneH;
	[SPRTPrint drawText:sAdrX textY:sAdrY widthNum:sAdrW heightNum:sAdrH textStr:sAdress fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//寄方 end==========================================
	
	//收方start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString *receiverTitle = @"收方";
	int rTitleX = startX + deltaX;
	int rTitleY = sTitleY + rowHeight;
	int rTitleWidth = titleWidth;
	int rTitleHeight = rowHeight;
	[SPRTPrint drawText:rTitleX textY:rTitleY widthNum:rTitleWidth heightNum:rTitleHeight textStr:receiverTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//phone
	NSString *rPhone = [self strValueOf:self.billInfo key:kAcceptManPhone];
	int rPhoneW = maxX - titleWidth;
	int rPhoneH = rowHeight / 2;
	int rPhoneX = titleWidth + deltaX;
	int rPhoneY = rTitleY;
	[SPRTPrint drawText:rPhoneX textY:rPhoneY widthNum:rPhoneW heightNum:rPhoneH textStr:rPhone fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//address
	NSString *rAddress = [self addressDetail:self.billInfo type:@"0"];;
	int rAdrW = rPhoneW;
	int rAdrH = rPhoneH;
	int rAdrX = rPhoneX;
	int rAdrY = rPhoneY + rPhoneH;
	[SPRTPrint drawText:rAdrX textY:rAdrY widthNum:rAdrW heightNum:rAdrH textStr:rAddress fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//收方end==========================================
	
	//货物信息start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString * goodsTitle = @"货物信息";
	int goodsTitleY = rTitleY + rowHeight;
	int goodsTitleW = titleWidth  - 20;;
	int goodsTitleX = startX + deltaX;
	int goodsTitleH = rowHeight;
	[SPRTPrint drawText:goodsTitleX textY:goodsTitleY widthNum:goodsTitleW heightNum:goodsTitleH textStr:goodsTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//huo wu xin xi
	NSString *goods = [self goodsInfo:self.billInfo];
	int goodsW = maxX - titleWidth - 10;
	int goodsH = rowHeight;
	int goodsX = titleWidth + deltaX;
	int goodsY = goodsTitleY;
	[SPRTPrint drawText:goodsX textY:goodsY widthNum:goodsW heightNum:goodsH textStr:goods fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//货物信息 end==========================================
	
	//付费信息start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	NSString *payTitle = @"付费信息";
	int payTitleY = goodsTitleY + rowHeight;
	int payTitleW = titleWidth - 20;
	int payTitleX = startX + deltaX;
	int payTitleH = rowHeight;
	[SPRTPrint drawText:payTitleX textY:payTitleY widthNum:payTitleW heightNum:payTitleH textStr:payTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//shou fei xin xi
	NSString *pay = [self feesTxtBy:self.billInfo];
	int payW = maxX - titleWidth;
	int payH = rowHeight;
	int payX = titleWidth + deltaX;
	int payY = payTitleY;
	[SPRTPrint drawText:payX textY:payY widthNum:payW heightNum:payH textStr:pay fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	//付费信息 end==========================================
	
	
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
	int start6Y = start5Y + rowHeight + startY;
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


#pragma mark- GPPrinter
//收件客户存根联标签打印命令
-(NSData *)senderLabelCommand{
    int maxX = 800-10;
    int maxY = 535;
    int startX = 2;
    int startY = 15;
    int headerHeight = 180;
    int rowHeight = 85;
    int titleWidth = 80;
    int lineWeight = 2;
    int deltaX = 10;
    NSString *titleFontStr = @"TSS24.BF2";
    NSString *txtFontStr = @"TSS20.BF2";
    
    
    TscCommand *command = [[TscCommand alloc] init];
    [command addSize:maxX :maxY];
    [command addGapWithM:2 withN:0];
    [command addReference:0 :0];
    [command addTear:@"ON"];
    [command addQueryPrinterStatus:ON];
    [command addCls];
    //
    [command addBox:startX :startY :maxX :maxY :lineWeight];
    
    //打印时间
    NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[NSDate currentDateStrBy:nil]];
    int sPrintDateH = 40;
    int sPrintDateX = startX + deltaX;
    int sPrintDateY = startY + headerHeight - sPrintDateH + 10;
    //打印时间
    [command addTextwithX:sPrintDateX withY:sPrintDateY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:sPintDateTitle];
    
    //打印条形码，和数字
    int barCodeWith = 280;
	int barCodeX = maxX - barCodeWith - startX;
    int barCodeY = startY;
	NSString *billCode = [self strValueOf:self.billInfo key:kBillCodeKey];
    [command add1DBarcode:barCodeX :barCodeY :@"CODE128" :80 :1 :0 :2 :4 :billCode];
    
    
    //派件网点存根联
    NSString *typeTitle = @"收件客户存根联:";
    int typeX = barCodeX;
    int typeY = sPrintDateY;
    [command addTextwithX:typeX withY:typeY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:typeTitle];
    
    
    // 框内第一条横线--------------------------------
    int start1Y = startY + headerHeight;
    [command addBar:startX :start1Y :maxX :lineWeight];
    

    //寄方
    NSString *senderTitle = @"寄方";
    int deltaY = 10;
    int sTitleX = startX + deltaX;
    int sTitleY = start1Y + deltaY;
    //打印寄方
    [command addTextwithX:sTitleX withY:sTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:senderTitle];
    //phone
    NSString *sPhone = [self strValueOf:self.billInfo key:kSendManPhone];
//    NSString *sPhone = @"18028324243";
    int sPhoneX = titleWidth + deltaX;
    int sPhoneY = sTitleY;
    [command addTextwithX:sPhoneX withY:sPhoneY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:sPhone];
    
    //address
    NSString *sAdress = [self addressDetail:self.billInfo type:@"1"];
//    NSString *sAdress = @"江苏省无锡市小区";
    int sAdrX = sPhoneX;
    int sAdrY = sPhoneY + (rowHeight / 2);
    [command addTextwithX:sAdrX withY:sAdrY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:sAdress];
    
    // 框内第二条横线--------------------------------
    int start2Y = start1Y + rowHeight;
    [command addBar:startX :start2Y :maxX :lineWeight];
     
     //收方
     NSString *receiverTitle = @"收方";
     int rTitleX = sTitleX;
     int rTitleY = start2Y + deltaX;
     [command addTextwithX:rTitleX withY:rTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:receiverTitle];
     //phone
     NSString *rPhone = [self strValueOf:self.billInfo key:kAcceptManPhone];
//     NSString *rPhone = @"18028324233";
     int rPhoneX = titleWidth + deltaX;
     int rPhoneY = rTitleY;
     [command addTextwithX:rPhoneX withY:rPhoneY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:rPhone];
    
    //address
    NSString *rAddress = [self addressDetail:self.billInfo type:@"0"];
//    NSString *rAddress = @"江苏省无锡市小区shoufang";
    int rAdrX = rPhoneX;
    int rAdrY = rPhoneY + (rowHeight / 2);
    [command addTextwithX:rAdrX withY:rAdrY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:rAddress];
    
    // 框内第三条横线--------------------------------
    int start3Y = start2Y + rowHeight;
    [command addBar:startX :start3Y :maxX :lineWeight];
    
    //货物信息
    NSString *goodsTitle = @"货物";
    int goodsTitleX = sTitleX;
    int goodsTitleY = start3Y + deltaY;
    [command addTextwithX:goodsTitleX withY:goodsTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:goodsTitle];
    
    
    NSString *goodsTitle2 = @"信息";
    int goodsTitle2Y = goodsTitleY + (rowHeight/2);
    [command addTextwithX:goodsTitleX withY:goodsTitle2Y withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:goodsTitle2];
    
    //hu wu xin xi
    NSString *goods = [self goodsInfo:self.billInfo];
//    NSString *goods = @"将根据股份奖励计划发行 2664 万股新股份，拟授予不少于 29700 位受奖励人士。以 532.81 港元";
    int goodsX = titleWidth + deltaX;
    int goodsY = goodsTitleY;
    int letterMaxLen = 38;
    if (goods.length > letterMaxLen) {
        NSString *line1 = [goods substringToIndex:letterMaxLen];
        [command addTextwithX:goodsX withY:goodsY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:line1];
        
        NSString *line2 = [goods substringFromIndex:letterMaxLen];
        int goods2Y = goodsTitle2Y;
        [command addTextwithX:goodsX withY:goods2Y withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:line2];
    }else{
        [command addTextwithX:goodsX withY:goodsY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:goods];
    }
    

    // 框内第四条横线--------------------------------
    int start4Y = start3Y + rowHeight;
    [command addBar:startX :start4Y :maxX :lineWeight];
    
    //收费信息
    NSString *feeTitle = @"收费";
    int feeTitleX = sTitleX;
    int feeTitleY = start4Y + deltaY;
    [command addTextwithX:feeTitleX withY:feeTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:feeTitle];
    
    NSString *feeTitle2 = @"信息";
    int feeTitle2Y = feeTitleY + (rowHeight/2);
    [command addTextwithX:goodsTitleX withY:feeTitle2Y withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:feeTitle2];
    
    //shou fei xin xi
    NSString *fee = [self feesTxtBy:self.billInfo];
//    NSString *fee = @"现金：现金保价，金额：3000，运费：0";
    int feeX = titleWidth + deltaX;
    int feeY = feeTitleY;
    [command addTextwithX:feeX withY:feeY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:fee];
    
    
    //第一条竖线|||||||||||||||||||||||||||||
    int col1StartX = startX + titleWidth;
    int col1Height = maxY - start1Y;
    [command addBar:col1StartX :start1Y :lineWeight :col1Height];
    
    [command addPrint:1 :1];
    return [command getCommand];
}



//派件网点存根联标签打印命令
-(NSData *)siteLabelCommand{
    int maxX = 800-10;
    int maxY = 535;
    int startX = 2;
    int startY = 15;
    int headerHeight = 180;
    int rowHeight = 85;
    int titleWidth = 80;
    int lineWeight = 2;
    int deltaX = 10;
    NSString *titleFontStr = @"TSS24.BF2";
    NSString *txtFontStr = @"TSS20.BF2";
    
    
    TscCommand *command = [[TscCommand alloc] init];
    [command addSize:maxX :maxY];
    [command addGapWithM:2 withN:0];
    [command addReference:0 :0];
    [command addTear:@"ON"];
    [command addQueryPrinterStatus:ON];
    [command addCls];
	
    //
    [command addBox:startX :startY :maxX :maxY :lineWeight];
    
    //打印时间
	NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[NSDate currentDateStrBy:nil]];
    int sPrintDateH = 40;
    int sPrintDateX = startX + deltaX;
    int sPrintDateY = startY + headerHeight - sPrintDateH + 10;
    //打印时间
    [command addTextwithX:sPrintDateX withY:sPrintDateY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:sPintDateTitle];
    
    //打印条形码，和数字
    int barCodeWith = 280;
    int barCodeX = maxX - barCodeWith - startX;
    int barCodeY = startY;
	NSString *billCode = [self strValueOf:self.billInfo key:kBillCodeKey];
    [command add1DBarcode:barCodeX :barCodeY :@"CODE128" :80 :1 :0 :2 :4 :billCode];
    
    
    //派件网点存根联
    NSString *typeTitle = @"派件网点存根联:";
    int typeX = barCodeX;
    int typeY = sPrintDateY;
    [command addTextwithX:typeX withY:typeY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:typeTitle];
    
    
    // 框内第一条横线--------------------------------
    int start1Y = startY + headerHeight;
    [command addBar:startX :start1Y :maxX :lineWeight];
    

    //寄方
    NSString *senderTitle = @"寄方";
    int deltaY = 10;
    int sTitleX = startX + deltaX;
    int sTitleY = start1Y + deltaY;
    //打印寄方
    [command addTextwithX:sTitleX withY:sTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:senderTitle];
    //phone
    NSString *sPhone = [self strValueOf:self.billInfo key:kSendManPhone];
//    NSString *sPhone = @"18028324243";
    int sPhoneX = titleWidth + deltaX;
    int sPhoneY = sTitleY;
    [command addTextwithX:sPhoneX withY:sPhoneY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:sPhone];
    
    //address
    NSString *sAdress = [self addressDetail:self.billInfo type:@"1"];
//    NSString *sAdress = @"江苏省无锡市小区";
    int sAdrX = sPhoneX;
    int sAdrY = sPhoneY + (rowHeight / 2);
    [command addTextwithX:sAdrX withY:sAdrY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:sAdress];
    
    // 框内第二条横线--------------------------------
    int start2Y = start1Y + rowHeight;
    [command addBar:startX :start2Y :maxX :lineWeight];
     
     //收方
     NSString *receiverTitle = @"收方";
     int rTitleX = sTitleX;
     int rTitleY = start2Y + deltaX;
     [command addTextwithX:rTitleX withY:rTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:receiverTitle];
     //phone
     NSString *rPhone = [self strValueOf:self.billInfo key:kAcceptManPhone];
//     NSString *rPhone = @"18028324233";
     int rPhoneX = titleWidth + deltaX;
     int rPhoneY = rTitleY;
     [command addTextwithX:rPhoneX withY:rPhoneY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:rPhone];
    
    //address
    NSString *rAddress = [self addressDetail:self.billInfo type:@"0"];
//    NSString *rAddress = @"江苏省无锡市小区shoufang";
    int rAdrX = rPhoneX;
    int rAdrY = rPhoneY + (rowHeight / 2);
    [command addTextwithX:rAdrX withY:rAdrY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:rAddress];
    
    // 框内第三条横线--------------------------------
    int start3Y = start2Y + rowHeight;
    [command addBar:startX :start3Y :maxX :lineWeight];
    
    //货物信息
    NSString *goodsTitle = @"货物";
    int goodsTitleX = sTitleX;
    int goodsTitleY = start3Y + deltaY;
    [command addTextwithX:goodsTitleX withY:goodsTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:goodsTitle];
    
    
    NSString *goodsTitle2 = @"信息";
    int goodsTitle2Y = goodsTitleY + (rowHeight/2);
    [command addTextwithX:goodsTitleX withY:goodsTitle2Y withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:goodsTitle2];
    
    //hu wu xin xi
    NSString *goods = [self sendGoodsInfo:self.billInfo];
//    NSString *goods = @"将根据股份奖励计划发行 2664 万股新股份，拟授予不少于 29700 位受奖励人士。以 532.81 港元";
    int goodsX = titleWidth + deltaX;
    int goodsY = goodsTitleY;
    int letterMaxLen = 38;
    if (goods.length > letterMaxLen) {
        NSString *line1 = [goods substringToIndex:letterMaxLen];
        [command addTextwithX:goodsX withY:goodsY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:line1];
        
        NSString *line2 = [goods substringFromIndex:letterMaxLen];
        int goods2Y = goodsTitle2Y;
        [command addTextwithX:goodsX withY:goods2Y withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:line2];
    }else{
        [command addTextwithX:goodsX withY:goodsY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:goods];
    }
    

    
    // 框内第四条横线--------------------------------
    int start4Y = start3Y + rowHeight;
    [command addBar:startX :start4Y :maxX :lineWeight];
    
    //收费信息
    NSString *feeTitle = @"收费";
    int feeTitleX = sTitleX;
    int feeTitleY = start4Y + deltaY;
    [command addTextwithX:feeTitleX withY:feeTitleY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:feeTitle];
    
    NSString *feeTitle2 = @"信息";
    int feeTitle2Y = feeTitleY + (rowHeight/2);
    [command addTextwithX:goodsTitleX withY:feeTitle2Y withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:feeTitle2];
    
    //shou fei xin xi
    NSString *fee = [self feesTxtBy:self.billInfo];
//    NSString *fee = @"现金：现金保价，金额：3000，运费：0";
    int feeX = titleWidth + deltaX;
    int feeY = feeTitleY;
    [command addTextwithX:feeX withY:feeY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:fee];
    
    
    //第一条竖线|||||||||||||||||||||||||||||
    int col1StartX = startX + titleWidth;
    int col1Height = maxY - start1Y;
    [command addBar:col1StartX :start1Y :lineWeight :col1Height];
    
    
    //第二条竖线|||||||||||||||||||||||||||||
    int siteTextW = 160;
    int col2StartX = maxX - siteTextW;
    int col2Height = rowHeight;
    int col2Y = start1Y;
    [command addBar:col2StartX :col2Y :lineWeight :col2Height];
    
    //寄件网点
    NSString *siteNameTitle = @"寄件网点:";
    int siteX = col2StartX + 5;
    int siteY = col2Y + deltaY;
     [command addTextwithX:siteX withY:siteY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:siteNameTitle];
    
    NSString *destination = [self strValueOf:self.billInfo key:@"DESTINATION"];
//    NSString *destination = @"寄件网点B1";
    int siteInfoX = siteX;
    int siteInfoY = siteY + (rowHeight / 2);
    [command addTextwithX:siteInfoX withY:siteInfoY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:destination];
    
    //第三条竖线|||||||||||||||||||||||||||||
    int col3StartX = col2StartX;
    int col3Height = rowHeight;
    int col3Y = start4Y;
    [command addBar:col3StartX :col3Y :lineWeight :col3Height];
    
    //收件客户签字
    NSString *signTitle = @"收件客户签字：";
    int signX = col3StartX + 5;
    int signY = col3Y + deltaY;
    [command addTextwithX:signX withY:signY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:signTitle];
    
    [command addPrint:1 :1];
    return [command getCommand];
}




@end
