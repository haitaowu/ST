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
#import "BluetoothListController.h"
#import "TscCommand.h"

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
@property(nonatomic,assign) PrinterType printerType;
@property (weak, nonatomic) IBOutlet UILabel *connState;


@property(nonatomic,assign) int barCodeWidth;


@end

@implementation MasterBillPrinter



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"打印运单";
	self.barCodeWidth = 110;
	self.printerType = NONPRINTER;
	cmd=0;
	mtu = 20;
	credit = 0;
	response = 1;
	cjFlag=1;           // qzfeng 2016/05/10
	self.reloadBtn.hidden = YES;
	

//    if (self.billSN != nil) {
//        self.reloadBtn.hidden = NO;
//        [self reqPrintBillInfo];
//    }else{
//        self.reloadBtn.hidden = YES;
//    }

	[self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
	[self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
	
	
	return;
    self.managerState = CBManagerStateUnknown;
	  //初始化后会调用代理CBCentralManagerDelegate 的 - (void)centralManagerDidUpdateState:(CBCentralManager *)central
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self startScanConnectPrinter];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[Manager close];
	NSLog(@"viewWill Disappear....");
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
		}
		[self updateConnectState:state printerType:type];
	};
	
//	listControl.connectBlock = ^(ConnectState state) {
//		if (CONNECT_STATE_CONNECTED == state) {
//			//			   [weakSelf.navigationController popViewControllerAnimated:YES];
//		}
//
//		[self updateConnectState:state];
//	};
	[self.navigationController pushViewController:listControl animated:YES];


	return;
    if (self.managerState == CBManagerStatePoweredOn) {
        [self startScanConnectPrinter];
        [SVProgressHUD showWithStatus:@"连接打印机中..." maskType:SVProgressHUDMaskTypeBlack];
    }else{
        NSLog(@"打印机当前状态不可用");
    }
}

- (IBAction)tapReloadBillsData:(id)sender {
//    [self reqPrintBillInfo];
}

///start to print bill
- (IBAction)startToPrint:(id)sender {
//	[self updateOperBtnsWithDisConnState];
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		[self updateOperBtnsWithConnedState];
//	});
	
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


//GPRinter发件网点存根联标签打印命令
//-(NSData *)tscCommand{
//    int maxX = 800-10;
//    int maxY = 535;
//    int startX = 2;
//    int startY = 15;
//    int headerHeight = 180;
//    int rowHeight = 85;
//    int titleWidth = 80;
//    int lineWeight = 2;
//    TscCommand *command = [[TscCommand alloc]init];
//    [command addSize:maxX :maxY];
//    [command addGapWithM:2 withN:0];
//    [command addReference:0 :0];
//    [command addTear:@"ON"];
//    [command addQueryPrinterStatus:ON];
//    [command addCls];
//    //
//    [command addBox:startX :startY :maxX :maxY :lineWeight];
//
//    // 框内第一条横线--------------------------------
//    int start1Y = startY + headerHeight;
//    [command addBar:startX :start1Y :maxX :lineWeight];
//
//
//    // 框内第二条横线--------------------------------
//    int start2Y = start1Y + rowHeight;
//    [command addBar:startX :start2Y :maxX :lineWeight];
//
//    // 框内第三条横线--------------------------------
//    int start3Y = start2Y + rowHeight;
//    [command addBar:startX :start3Y :maxX :lineWeight];
//
//    // 框内第四条横线--------------------------------
//    int start4Y = start3Y + rowHeight;
//    [command addBar:startX :start4Y :maxX :lineWeight];
//
//    //第一条竖线|||||||||||||||||||||||||||||
//    int col1StartX = startX + titleWidth;
//    int col1Height = maxY - start1Y;
//    [command addBar:col1StartX :start1Y :lineWeight :col1Height];
//
//    //第二条竖线|||||||||||||||||||||||||||||
//    int siteTextW = 160;
//    int col2StartX = maxX - siteTextW;
//    int col2Height = rowHeight;
//    int col2Y = start2Y;
//    [command addBar:col2StartX :col2Y :lineWeight :col2Height];
//
//
//    //第三条竖线|||||||||||||||||||||||||||||
//    int col3StartX = col2StartX;
//    int col3Height = rowHeight;
//    int col3Y = start4Y;
//    [command addBar:col3StartX :col3Y :lineWeight :col3Height];
//
//    [command addPrint:1 :1];
//    return [command getCommand];
//}




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



//当前时间
- (NSString*)currentDateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    return todayStr;
}


// ji jian di zhi / shou jian ren dizhi
- (NSString*)addressDetail:(NSDictionary*)billInfo type:(NSString*)adrType{
  NSArray* keys;
  if ([adrType isEqualToString:@"1"]) {
    //ji jian di zhi
    keys = @[@"PROVINCE",@"CITY",@"BOROUGH",@"SEND_MAN_ADDRESS"];
  }else{
    //shou jian di zhi
    keys = @[@"PROVINCE_NAME",@"CITY_NAME",@"COUNTY_NAME",@"ACCEPT_MAN_ADDRESS"];
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
  NSString *name = [billInfo objectForKey:@"GOODS_NAME"];
  if (name != nil) {
    goods = [goods stringByAppendingFormat:@"名称:%@、",name];
  }
  NSString *pieces = [billInfo objectForKey:@"PIECE_NUMBER"];
  if (pieces != nil) {
    goods = [goods stringByAppendingFormat:@"件数:%@、",pieces];
  }
  NSString *weight = [billInfo objectForKey:@"SETTLEMENT_WEIGHT"];
  if (weight != nil) {
    goods = [goods stringByAppendingFormat:@"重量:%@、",weight];
  }
  NSString *tranType = [billInfo objectForKey:@"DISPATCH_MODE"];
  if (tranType != nil) {
    goods = [goods stringByAppendingFormat:@"送货方式:%@、",tranType];
  }
  NSString *sign = [billInfo objectForKey:@"BL_RETURN_BILL"];
  if (sign != nil) {
    goods = [goods stringByAppendingFormat:@"签回单标识:%@、",sign];
  }
  NSString *storage = [billInfo objectForKey:@"BL_INTO_WAREHOUSE"];
  if (storage != nil) {
    goods = [goods stringByAppendingFormat:@"进仓标识:%@、",storage];
  }
  
  NSString *date = [billInfo objectForKey:@"SEND_DATE"];
  if (date != nil) {
    goods = [goods stringByAppendingFormat:@"寄件日期:%@",date];
  }

  return goods;
}

///pai jian wang dian huo wu xin xi
- (NSString*)sendGoodsInfo:(id)billInfo
{
  NSString *goods = @"";
  NSString *name = [billInfo objectForKey:@"GOODS_NAME"];
  if (name != nil) {
    goods = [goods stringByAppendingFormat:@"名称:%@、",name];
  }
  NSString *pieces = [billInfo objectForKey:@"PIECE_NUMBER"];
  if (pieces != nil) {
    goods = [goods stringByAppendingFormat:@"件数:%@、",pieces];
  }
  NSString *weight = [billInfo objectForKey:@"SETTLEMENT_WEIGHT"];
  if (weight != nil) {
    goods = [goods stringByAppendingFormat:@"重量:%@、",weight];
  }
  NSString *tranType = [billInfo objectForKey:@"DISPATCH_MODE"];
  if (tranType != nil) {
    goods = [goods stringByAppendingFormat:@"送货方式:%@、",tranType];
  }
  
  NSString *weightCount = [billInfo objectForKey:@"OVER_WEIGHT_PIECE"];
  if (weightCount != nil) {
    goods = [goods stringByAppendingFormat:@"超重件数:%@、",weightCount];
  }
  
  NSString *overSize = [billInfo objectForKey:@"BL_OVER_LONG"];
  if (overSize != nil) {
    goods = [goods stringByAppendingFormat:@"超长标识:%@、",overSize];
  }
  
  NSString *rCode = [billInfo objectForKey:@"R_BILLCODE"];
  if (rCode != nil) {
    goods = [goods stringByAppendingFormat:@"回单编号:%@、",rCode];
  }
  NSString *storageCode = [billInfo objectForKey:@"STORAGENO"];
  if (storageCode != nil) {
    goods = [goods stringByAppendingFormat:@"进仓编号:%@、",storageCode];
  }
  
  NSString *date = [billInfo objectForKey:@"SEND_DATE"];
  if (date != nil) {
    goods = [goods stringByAppendingFormat:@"寄件日期:%@",date];
  }

  return goods;
}


///fei yong
- (NSString*)feesTxtBy:(id)billInfo
{
  NSString *fees = @"";
  NSString *payType = [billInfo objectForKey:@"PAYMENT_TYPE"];
  if (payType != nil) {
    fees = [fees stringByAppendingFormat:@"%@:",payType];
    NSString *cash = [billInfo objectForKey:@"FREIGHT"];
    if (payType != nil) {
      fees = [fees stringByAppendingFormat:@"%@、",cash];
    }
  }
  NSString *count = [billInfo objectForKey:@"INSURE_VALUE"];
  if (count != nil) {
    fees = [fees stringByAppendingFormat:@"保价金额:%@、",count];
  }
  NSString *pay = [billInfo objectForKey:@"FREIGHT"];
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
///打印发件网点存根联的表格
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
	
	//发件网点存根联
	NSString *typeTitle = @"发件网点存根联:";
	int typeW = maxX - sPrintDateW - 60;
	int typeH = 40;
	int typeX = sPrintDateW + 60;
	int typeY = sPrintDateY;
	[SPRTPrint drawText:typeX textY:typeY widthNum:typeW heightNum:typeH textStr:typeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	
	NSString *billCode = [self strValueOf:self.billInfo key:@"BILL_CODE"];
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
	NSString *sPhone = [self strValueOf:self.billInfo key:@"SEND_MAN_PHONE"];
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
	NSString *rPhone = [self strValueOf:self.billInfo key:@"ACCEPT_MAN_PHONE"];
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
	
	//目的网点
	NSString *destination = [self strValueOf:self.billInfo key:@"DESTINATION"];
	NSString *siteNameTitle = [@"目的网点:" stringByAppendingFormat:@"%@",destination];
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
	
	//寄件客户签字
	NSString *signTitle = @"寄件客户签字:";
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




///打印寄件客户存根联的表格
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
	
	//寄件客户存根联
	NSString *typeTitle = @"寄件客户存根联:";
	int typeW = maxX - sPrintDateW - 60;
	int typeH = 40;
	int typeX = sPrintDateW + 60;
	int typeY = sPrintDateY;
	[SPRTPrint drawText:typeX textY:typeY widthNum:typeW heightNum:typeH textStr:typeTitle fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
	
	NSString *billCode = [self strValueOf:self.billInfo key:@"BILL_CODE"];
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
	NSString *sPhone = [self strValueOf:self.billInfo key:@"SEND_MAN_PHONE"];
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
	NSString *rPhone = [self strValueOf:self.billInfo key:@"ACCEPT_MAN_PHONE"];
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


#pragma mark- GPPrinter
//寄件客户存根联标签打印命令
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
    NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[self currentDateStr]];
    int sPrintDateH = 40;
    int sPrintDateX = startX + deltaX;
    int sPrintDateY = startY + headerHeight - sPrintDateH + 10;
    //打印时间
    [command addTextwithX:sPrintDateX withY:sPrintDateY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:sPintDateTitle];
    
    //打印条形码，和数字
    int barCodeWith = 280;
	int barCodeX = maxX - barCodeWith - startX;
    int barCodeY = startY;
	NSString *billCode = [self strValueOf:self.billInfo key:@"BILL_CODE"];
    [command add1DBarcode:barCodeX :barCodeY :@"CODE128" :80 :1 :0 :2 :4 :billCode];
    
    
    //发件网点存根联
    NSString *typeTitle = @"寄件客户存根联:";
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
    NSString *sPhone = [self strValueOf:self.billInfo key:@"SEND_MAN_PHONE"];
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
     NSString *rPhone = [self strValueOf:self.billInfo key:@"ACCEPT_MAN_PHONE"];
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
    
    [command addPrint:1 :1];
    return [command getCommand];
}



//发件网点存根联标签打印命令
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
	NSString *sPintDateTitle = [@"打印时间:" stringByAppendingString:[self currentDateStr]];
    int sPrintDateH = 40;
    int sPrintDateX = startX + deltaX;
    int sPrintDateY = startY + headerHeight - sPrintDateH + 10;
    //打印时间
    [command addTextwithX:sPrintDateX withY:sPrintDateY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:sPintDateTitle];
    
    //打印条形码，和数字
    int barCodeWith = 280;
    int barCodeX = maxX - barCodeWith - startX;
    int barCodeY = startY;
	NSString *billCode = [self strValueOf:self.billInfo key:@"BILL_CODE"];
    [command add1DBarcode:barCodeX :barCodeY :@"CODE128" :80 :1 :0 :2 :4 :billCode];
    
    
    //发件网点存根联
    NSString *typeTitle = @"发件网点存根联:";
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
    NSString *sPhone = [self strValueOf:self.billInfo key:@"SEND_MAN_PHONE"];
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
     NSString *rPhone = [self strValueOf:self.billInfo key:@"ACCEPT_MAN_PHONE"];
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
    int col2Y = start2Y;
    [command addBar:col2StartX :col2Y :lineWeight :col2Height];
    
    //目的网点
    NSString *siteNameTitle = @"目的网点:";
    int siteX = col2StartX + 5;
    int siteY = col2Y + deltaY;
     [command addTextwithX:siteX withY:siteY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:siteNameTitle];
    
    NSString *destination = [self strValueOf:self.billInfo key:@"DESTINATION"];
//    NSString *destination = @"目的网点B1";
    int siteInfoX = siteX;
    int siteInfoY = siteY + (rowHeight / 2);
    [command addTextwithX:siteInfoX withY:siteInfoY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:destination];
    
    //第三条竖线|||||||||||||||||||||||||||||
    int col3StartX = col2StartX;
    int col3Height = rowHeight;
    int col3Y = start4Y;
    [command addBar:col3StartX :col3Y :lineWeight :col3Height];
    
    //寄件客户签字
    NSString *signTitle = @"寄件客户签字：";
    int signX = col3StartX + 5;
    int signY = col3Y + deltaY;
    [command addTextwithX:signX withY:signY withFont:titleFontStr withRotation:0 withXscal:1 withYscal:1 withText:signTitle];
    
    [command addPrint:1 :1];
    return [command getCommand];
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
//    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
//                                                   message:msg
//                                                  delegate:self
//                                         cancelButtonTitle:@"关闭" 
//                                         otherButtonTitles:nil];
//    [alert show];
	
	UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
	[alertControl addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		
	}]];
	
	[self presentViewController:alertControl animated:YES completion:nil];
}




@end
