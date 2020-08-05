//
//  TicketPrintPreController.m
//  BTDemo
//
//  Created by ligl on 15-07-21.
//

#import "TicketPrintPreController.h"
#import "SPRTPrint.h"
#import "UIImage+Extension.h"
#import "SVProgressHUD.h"
#import "BluetoothListController.h"
#import "TscCommand.h"
#import "NSDate+Category.h"
#import <BRPickerView/BRPickerView.h>


//for issc
static NSString *const kWriteCharacteristicUUID_cj = @"49535343-8841-43F4-A8D4-ECBE34729BB3";
static NSString *const kReadCharacteristicUUID_cj = @"49535343-1E4D-4BD9-BA61-23C647249616";
static NSString *const kServiceUUID_cj = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
//for ivt
static NSString *const kFlowControlCharacteristicUUID = @"ff03";
static NSString *const kWriteCharacteristicUUID = @"ff02";
static NSString *const kReadCharacteristicUUID = @"ff01";
static NSString *const kServiceUUID = @"ff00";

CBPeripheral *activeDevice;
CBCharacteristic *activeWriteCharacteristic;
CBCharacteristic *activeReadCharacteristic;
CBCharacteristic *activeFlowControlCharacteristic;

int cmd=0;
int mtu = 20;
int credit = 0;
int response = 1;
// qzfeng 2016/05/10
int cjFlag=1;


#define kBillCodeKey            @"billCode"
#define kSubCodeKey            	@"billCodeSub"
#define kSendSiteKey            @"sendSite"
#define kDispatchCenterKey      @"dispatchCenter" //目的网点所属中心
#define kDispatchCodeKey      	@"dispatchCode" //目的网点所属编号
#define kSendgoodsTypeKey      	@"sendgoodsType" //派送方式
#define kGoodsNameKey      		@"goodsName" //物品名称
#define kSendCodeKey      		@"sendCode" //寄件网点编号
#define kAcceptAdrKey           @"acceptManAddress"
#define kArriveSiteKey          @"arriveSite"
#define kWeightKey              @"weight"
#define kPieceNumKey            @"pieceNumber"
#define kRegisterDateKey        @"registerDate"



@interface TicketPrintPreController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property(strong,nonatomic)CBCentralManager *centralManager;
@property(strong,nonatomic)CBPeripheral *selectedPeripheral;
@property(nonatomic,strong) NSThread *thread;
@property(nonatomic,assign) NSInteger managerState;
@property (weak, nonatomic) IBOutlet UIButton *connStateBtn;
@property (weak, nonatomic) IBOutlet UIButton *printBtn;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property(nonatomic,strong) NSArray *billCodes;
@property(nonatomic,assign) PrinterType printerType;
@property (weak, nonatomic) IBOutlet UILabel *connState;
@property (weak, nonatomic) IBOutlet UIPickerView *pagePicker;
@property(nonatomic,strong) NSMutableArray *pagesAry;
@property(nonatomic,strong) NSArray *endPagesAry;
@property(nonatomic,assign) NSRange pageRange;


@end

@implementation TicketPrintPreController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"打印";
    
	cmd=0;
	mtu = 20;
	credit = 0;
	response = 1;
	cjFlag=1;           // qzfeng 2016/05/10
  
  [self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
  [self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
  
    if (self.billSN != nil) {
        self.reloadBtn.hidden = NO;
        [self reqPrintBillInfo];
    }else{
		[self reloadPagePickerView];
        self.reloadBtn.hidden = YES;
    }
    
	
	
	return;
   /*
    self.managerState = CBManagerStateUnknown;
	  //初始化后会调用代理CBCentralManagerDelegate 的 - (void)centralManagerDidUpdateState:(CBCentralManager *)central
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.title = @"打印运单";
    
    [self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
    [self.printBtn setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
	*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self startScanConnectPrinter];
}

- (void)viewDidUnload
{
    [self setDeviceListTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[Manager close];
	NSLog(@"viewWill Disappear....");
}


- (void)reloadPagePickerView
{
	int num = [[self.billInfo objectForKey:@"pieceNumber"] intValue];
    self.pagesAry = [NSMutableArray arrayWithCapacity:num];
    for(int idx = 0 ; idx < num ; idx++){
        int row = idx + 1;
        [self.pagesAry addObject:@(row)];
    }
    [self.pagePicker reloadAllComponents];
	[self.pagePicker selectRow:(num-1) inComponent:1 animated:NO];
}


- (void)startScanConnectPrinter{
    if (self.centralManager.isScanning == YES) {
        return;
    }
	/*
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopScanPeripheral) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(dismissConnectLoading) userInfo:nil repeats:NO];
	 */
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
	NSArray *dataAry = @[@"斯普瑞特",@"佳博",@"汉印"];
	__weak typeof(self) weakSelf = self;
	[BRStringPickerView showPickerWithTitle:@"" dataSourceArr:dataAry selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
		PrinterType type;
		switch (resultModel.index) {
			case 0:
				type = SPRINTER;
				break;
			case 1:
				type = GPRINTER;
				break;
			case 2:
				type = HPRINTER;
				break;
			default:
				type = SPRINTER;
				break;
		}
		[weakSelf showPrinterListViewBy:type];
	}];
	
}

/**
 *gen ju da yin lei xing ji xuan ze
 */
- (void)showPrinterListViewBy:(PrinterType)printerType
{
	BluetoothListController *listControl = [[BluetoothListController alloc] init];
	  __weak typeof(self) weakSelf = self;
	listControl.printerType = printerType;
	  listControl.connResultBlock = ^(ConnectState state, PrinterType type) {
		  if (CONNECT_STATE_CONNECTED == state) {
			  UIViewController *control = weakSelf.navigationController.viewControllers.lastObject;
			  if (control != weakSelf) {
				  [weakSelf.navigationController popViewControllerAnimated:YES];
			  }
		  }
		  [self updateConnectState:state printerType:type];
	  };
	[self.navigationController pushViewController:listControl animated:YES];
}


- (IBAction)tapReloadBillsData:(id)sender {
    [self reqPrintBillInfo];
}

- (IBAction)buttonPrintPNGorJPG:(id)sender {
	if (self.printerType == SPRINTER) {
		[self sendKeyChainToPrinter];
		[self startSPrintByBillInfo:self.billInfo];
	}else if (self.printerType == GPRINTER) {
		[self startGPrintByBillInfo:self.billInfo];
	}else{
		NSLog(@"hello HPrinter to print");
	}
}


#pragma mark - private methods
//发送密钥
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


///GPrinter print
- (void)startGPrintByBillInfo:(NSDictionary*)billData
{
	NSString *billCodeStr = [billData objectForKey:kBillCodeKey];
	NSNumber *piecesNum = [billData objectForKey:kPieceNumKey];
	NSInteger startPage = [self.pagePicker selectedRowInComponent:0];
	NSInteger startNum = [self.pagesAry[startPage] integerValue];
	NSInteger endPage = [self.pagePicker selectedRowInComponent:1];
	NSInteger ednNum = [self.endPagesAry[endPage] integerValue];
	
	NSArray *subCodesArra = [self subBillCodesWithBillData:billData];
	if ([subCodesArra count] > 0) {
		for (NSInteger idx = startNum; idx <= ednNum; idx++) {
			NSString *subCode = [subCodesArra objectAtIndex:(idx-1)];
			NSString *indexStr = [NSString stringWithFormat:@"%ld/%@",(long)idx,piecesNum];
			NSData *printData = [self GPrinterData:billCodeStr subCode:subCode indexStr:indexStr];
			[Manager write:printData];
		}
	}else{
		NSString *indexStr = [NSString stringWithFormat:@"1/%@",piecesNum];
		NSString *subCode = @"";
		NSData *printData = [self GPrinterData:billCodeStr subCode:subCode indexStr:indexStr];
		[Manager write:printData];
	}
}



///sprinter printer
- (void)startSPrintByBillInfo:(NSDictionary*)billData
{
    NSString *billCodeStr = [billData objectForKey:kBillCodeKey];
    NSNumber *piecesNum = [billData objectForKey:kPieceNumKey];
	NSArray *subCodesArra = [self subBillCodesWithBillData:billData];
	NSInteger startPage = [self.pagePicker selectedRowInComponent:0];
	NSInteger startNum = [self.pagesAry[startPage] integerValue];
	NSInteger endPage = [self.pagePicker selectedRowInComponent:1];
	NSInteger ednNum = [self.endPagesAry[endPage] integerValue];
	
	if ([subCodesArra count] > 0) {
		for (NSInteger idx = startNum; idx <= ednNum; idx++) {
			NSString *subCode = [subCodesArra objectAtIndex:(idx-1)];
			NSString *indexStr = [NSString stringWithFormat:@"%ld/%@",(long)idx,piecesNum];
			[self printWithBillCode:billCodeStr subCode:subCode indexStr:indexStr];
		}
	}else{
		NSString *indexStr = [NSString stringWithFormat:@"1/%@",piecesNum];
		NSString *subCode = @"";
		[self printWithBillCode:billCodeStr subCode:subCode indexStr:indexStr];
	}
}



#pragma mark - GPRrinter
- (NSData *)GPrinterData:(NSString*)billCode subCode:(NSString*)subCode indexStr:(NSString*)indexStr
{
	int maxX = 800 - 10;
    int maxY = 535;
	int topLogHeight = 160;
	int verticalBarCodeWidth = 90;
	int col1X = verticalBarCodeWidth;
    int lineWeight = 2;
	int startX = 2;
	int startY = 3;
	int deltaX = 10;
	int deltaY = 10 + 5;
	int sitesHeight = 110;
	int rowHeight = 60;
	
	
	
    NSString *titleFontStr = @"TSS32.BF2";
    NSString *txtFontStr = @"TSS24.BF2";
    
    
    TscCommand *command = [[TscCommand alloc] init];
    [command addSize:maxX :maxY];
	[command addGapWithM:2 withN:0];
	[command addReference:0 :0];
	[command addTear:@"ON"];
	[command addQueryPrinterStatus:ON];
	[command addCls];
	
	// 左上角寄件网点 到 右下角地址的框 --->
	int box1SX = col1X;
	int box1SY = topLogHeight;
	int box1EX = maxX;
	int box1EY = box1SY + sitesHeight + rowHeight * 2;
	[command addBox:box1SX :box1SY :box1EX :box1EY :lineWeight];
	
	//寄件/目的网点之间的竖线
	int sitesW = (maxX - box1SX) / 2;
	int sitesLineX = box1SX + sitesW;
	int sitesLineY = box1SY;
	
	[command addBar:sitesLineX :sitesLineY :lineWeight :sitesHeight];
	//end <---
	
	//tiao xing ma
	//	NSString *barCode = [billCode stringByAppendingFormat:@"%@",subCode];
	NSString *barCode = subCode;
	int barCodeWidth = 240;
	int barCode0X = col1X - startX - 3;
    int barCode0Y = startY + topLogHeight + 20;
    [command add1DBarcode:barCode0X :barCode0Y :@"CODE128" :80 :0 :90 :2 :4 :barCode];
	
	//mu di wang dian suo shu zhong xin
	NSString *dispatchCenter = [self.billInfo objectForKey:kDispatchCenterKey];
    if (dispatchCenter != nil) {
		int centerX = (maxX / 2);
		int centerY = 40;
		[command addTextwithX:centerX withY:centerY withFont:titleFontStr withRotation:0 withXscal:2 withYscal:2 withText:dispatchCenter];
    }
	
	//ji jian wang dian
	NSString *sendSite = [self.billInfo objectForKey:kSendSiteKey];
	if (sendSite != nil) {
		int sendX = box1SX + deltaX;
		int sendY = box1SY + deltaY;
		[command addTextwithX:sendX withY:sendY withFont:titleFontStr withRotation:0 withXscal:2 withYscal:2 withText:sendSite];
	}
	
	//ji jian wang dian bian hao
	NSString *sendCode = [self.billInfo objectForKey:kSendCodeKey];
    if (sendCode != nil) {
		int sCodeX = box1SX + deltaX + 10;
		int sCodeY = box1SY + (sitesHeight / 2) + 25;
		[command addTextwithX:sCodeX withY:sCodeY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:sendCode];
	}
	
	//mu di wang dian
	NSString *arriveSite = [self.billInfo objectForKey:kArriveSiteKey];
    if (arriveSite != nil) {
		int sCodeX = sitesLineX + deltaX ;
		int sCodeY = box1SY + deltaY;
		[command addTextwithX:sCodeX withY:sCodeY withFont:titleFontStr withRotation:0 withXscal:2 withYscal:2 withText:arriveSite];
	}
	
	//mu di wang dian bian hao
	NSString *dispatchCode = [self.billInfo objectForKey:kDispatchCodeKey];
    if (dispatchCode != nil) {
		int aCodeX = sitesLineX + deltaX + 10;
		int aCodeY = box1SY + (sitesHeight / 2) + 25;
		[command addTextwithX:aCodeX withY:aCodeY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:dispatchCode];
	}
	
	// 左上角运单号 到 右下角YYY-MM-dd的框 --->
	int box2X = col1X;
	int box2Y = box1SY + sitesHeight;
	int box2EX = box1EX;
	int box2EY = box2Y + rowHeight;
	[command addBox:box2X :box2Y :box2EX :box2EY :lineWeight];
	
	//左上角运单号 到 右下角YYY-MM-dd的框内的两条竖线
	int billCodeBorderW = 320;
	int lin1X = box1SX + billCodeBorderW;
	int line1Y = box1SY + sitesHeight;
	[command addBar:lin1X :line1Y :lineWeight :rowHeight];
	
	int weightW = (maxX - box1SX - billCodeBorderW) / 2;
	int line2X = lin1X + weightW;
	int line2Y = line1Y;
	[command addBar:line2X :line2Y :lineWeight :rowHeight];
	
	//yun dan hao
	NSString *billCodeTxt = [self.billInfo objectForKey:kBillCodeKey];
	if (billCodeTxt != nil) {
		int billX = box2X + deltaX;
		int billY = box2Y + deltaY + 5;
		[command addTextwithX:billX withY:billY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:billCodeTxt];
	}
	
	//weight
	id  weight = [self.billInfo objectForKey:kWeightKey];
	int weightX = lin1X + deltaX;
	if(weight != nil){
		int weightY = box2Y + deltaY + 5;
		NSString *weightTxt = [NSString stringWithFormat:@"%@KG",weight];
		[command addTextwithX:weightX withY:weightY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:weightTxt];
	}
	
	//lu dan ri qi
	NSString *billDateTxt = [self billDateWithData:self.billInfo];
	if (billDateTxt != nil) {
		int dateX = line2X + deltaX;
		int dateY = box2Y + deltaY + 5;
		[command addTextwithX:dateX withY:dateY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:billDateTxt];
	}
	
	NSString *adrTxt = [self.billInfo objectForKey:kAcceptAdrKey];
    if (adrTxt != nil) {
		int adrX = box1SX + deltaX;
		int adrY = box2EY + deltaY + 5;
       [command addTextwithX:adrX withY:adrY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:adrTxt];
    }
	//end <---
	
	
	int secRowHeight = (maxY - box1EY) / 3;
	
	// 左上角:派送方式 -> 右下角计数的框 --->
	int barCodeBoxderW = 400;
	int box3SX = col1X;
	int box3SY = box1EY;
	int box3EX = maxX - barCodeBoxderW;
	int box3EY = box1EY + secRowHeight * 2;
	[command addBox:box3SX :box3SY :box3EX :box3EY :lineWeight];
	
	//竖线||||||||||||||||||||||||||||
	int line3Width = (box3EX - box3SX) / 2;
	int line3X = box3SX + line3Width;
	int line3Y = box3SY;
	[command addBar:line3X :line3Y :lineWeight :secRowHeight];
	
	//heng xian -----------
	int line4X = box3SX;
	int line4Y = box3SY + secRowHeight;
	int line4W = box3EX - box3SX;
	[command addBar:line4X :line4Y :line4W :lineWeight];

	// pai song fang shi
	NSString *sendgoodsType = [self.billInfo objectForKey:kSendgoodsTypeKey];
    if (sendgoodsType != nil) {
		int typeX = box1SX + deltaX;
		int typeY = box3SY + deltaY;
		[command addTextwithX:typeX withY:typeY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:sendgoodsType];
	}
	
	//wu ping ming cheng
	NSString *goodsName = [self.billInfo objectForKey:kGoodsNameKey];
	if (goodsName != nil) {
		int nameX = line3X + deltaX;
		int nameY = box3SY + deltaY;
		[command addTextwithX:nameX withY:nameY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:goodsName];
	}
	
	//jian shu
	int indexX = box1SX + deltaX;
	int indexY = line4Y + deltaY;
	[command addTextwithX:indexX withY:indexY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:indexStr];
	//end <---
	
	
	// 左下角日期的框 --->
	int leftDX = startX;
	int letDY = box3EY;
	int leftEX = box3EX;
	int leftEY = maxY;
	[command addBox:leftDX :letDY :leftEX :leftEY :lineWeight];
	
	
	//da yin ri qi
	NSString *currentDateStr = [self currentDateStr];
	if (currentDateStr != nil) {
		int pDateX = leftDX + deltaX;
		int pDateY = letDY + deltaY;
		[command addTextwithX:pDateX withY:pDateY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:currentDateStr];
	}
	
	//end <---
	
	//you xia jiao tiao xing ma de kuang
	int barCodeBorderX = leftEX;
	int barCodeBorderY = box1EY;
	int barCodeBorderEX = box1EX;
	int barCodeBorderEY = leftEY;
	[command addBox:barCodeBorderX :barCodeBorderY :barCodeBorderEX :barCodeBorderEY :lineWeight];
	
	//you xia jiao tiao xing ma
	int barLeftSpace = (barCodeBoxderW - barCodeWidth) / 2;
	int barCodeX = barCodeBorderX + barLeftSpace;
    int barCodeY = barCodeBorderY + deltaY + 10;
	int barCodeHeight = 80;
    [command add1DBarcode:barCodeX :barCodeY :@"CODE128" :barCodeHeight :0 :0 :2 :4 :barCode];
	
	int barCodeNumWidth = 140;
	int barNumLeftSpace = (barCodeBoxderW - barCodeNumWidth) / 2;
	int barNumCodeX = barCodeBorderX + barNumLeftSpace;
	int barNumCodeY = barCodeY + barCodeHeight + 3;
	[command addTextwithX:barNumCodeX withY:barNumCodeY withFont:txtFontStr withRotation:0 withXscal:1 withYscal:1 withText:barCode];
	
	[command addPrint:1 :1];
	return [command getCommand];
}



#pragma mark - SPrinter printer
- (void)printWithBillCode:(NSString*)billCode subCode:(NSString*)subCode indexStr:(NSString*)indexStr
{
    [SPRTPrint pageSetup:800 pageHeightNum:500];
    int maxX = 800-10;
    int maxY = 500;
    int topLogHeight = 130;
    //第一条竖线的x值
    int col1x = 80;
    // 第一条横线
    int line1Y = topLogHeight;
    [SPRTPrint drawLine:2 startX:col1x startY:line1Y endX:maxX endY:line1Y isFullline:false];
    
    // iOS flag
    NSString *iOSStr = @"iOS";
    int flagWH = 40;
    int flagY = 5;
    int flagX = maxX - flagWH;
    [SPRTPrint drawText:(flagX) textY:(flagY) widthNum:flagWH heightNum:flagWH textStr:iOSStr fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];

   
    // 第二条横线
    int line2Y = line1Y+110;
    [SPRTPrint drawLine:2 startX:col1x startY:(120+120) endX:maxX endY:(120+120) isFullline:false];
    
    int verticalMargin = 60;
    // 第三条横线
    int line3Y = line2Y+verticalMargin;
    [SPRTPrint drawLine:2 startX:col1x startY:line3Y endX:maxX endY:line3Y isFullline:false];
    
    // 第四条横线
    int line4Y = line3Y+verticalMargin;
    [SPRTPrint drawLine:2 startX:col1x startY:line4Y endX:maxX endY:line4Y isFullline:false];
    
    int verticalShortMargin = (maxY - line4Y) / 3;
    //第三条竖线的x
    int col3x = 320;
    
    // 第五条横线
    int line5Y = line4Y+verticalShortMargin;
    [SPRTPrint drawLine:2 startX:col1x startY:line5Y endX:col3x endY:line5Y isFullline:false];
    
    // 第六条横线
    int line6Y = line5Y+verticalShortMargin;
    [SPRTPrint drawLine:2 startX:0 startY:line6Y endX:col3x endY:line6Y isFullline:false];
    
    int barCodeStrWidth = 300;
    //第一条竖线
    [SPRTPrint drawLine:2 startX:col1x startY:line1Y endX:col1x endY:line6Y isFullline:false];
    
    int aLet3StrWidth = ((maxX - 60) / 2) / 11 ;
    int aLet4StrBoldWidth = ((maxX - 60) / 2) / 7;
    int aLet5StrBoldWidth = ((maxX - 60) / 2) / 6;
    int aLet3NumWidth = ((maxX - 60) / 2) / 22 ;
    
    // 寄件网点；
    NSString *sendSite = [self.billInfo objectForKey:kSendSiteKey];
    int sendArrSiteWidth = (maxX - col1x) / 2;
    int sendSiteY = (topLogHeight+25);
//    int sendSiteMargin = (sendArrSiteWidth - (int)sendSite.length * aLet3StrWidth)/2;
    int sendSiteMargin = (sendArrSiteWidth - (int)sendSite.length * aLet4StrBoldWidth)/2;
    int sendSiteX = col1x + sendSiteMargin;
    if (sendSite != nil) {
        [SPRTPrint drawText:sendSiteX textY:sendSiteY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:sendSite fontSizeNum:4 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    // 寄件网点编号
	NSString *sendCode = [self.billInfo objectForKey:kSendCodeKey];
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
    
    //第二条竖线
    int col2x = col3x / 2;
    [SPRTPrint drawLine:2 startX:col2x startY:line4Y endX:col2x endY:line5Y isFullline:false];
    
    //第三条竖线
    [SPRTPrint drawLine:2 startX:col3x startY:line4Y endX:col3x endY:maxY isFullline:false];
    // 详细地址内容
    NSString *adrTxt = [self.billInfo objectForKey:kAcceptAdrKey];
    if (adrTxt != nil) {
        int adrTxtW = maxX - col1x;
        int margin = (adrTxtW - (int)adrTxt.length * aLet3StrWidth)/2;
        int startX = col1x + margin;
        [SPRTPrint drawText:startX textY:(line3Y + 15) widthNum:adrTxtW heightNum:verticalMargin textStr:adrTxt fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    }
    
    //第四条竖线
    int col4x = barCodeStrWidth + col1x;
    [SPRTPrint drawLine:2 startX:col4x startY:line2Y endX:col4x endY:line3Y isFullline:false];
    
    //第五条竖线
    int siteWidth = (maxX - col1x) / 2;
    int col5x = siteWidth + col1x;
    [SPRTPrint drawLine:2 startX:col5x startY:line1Y endX:col5x endY:line2Y isFullline:false];
    
    // 目的网点；
    NSString *arriveSite = [self.billInfo objectForKey:kArriveSiteKey];
    int arrSiteY = (topLogHeight+25);
    if (arriveSite != nil) {
//        int arrSiteMargin = (siteWidth - (int)arriveSite.length * aLet3StrWidth)/2;
        int arrSiteMargin = (siteWidth - (int)arriveSite.length * aLet4StrBoldWidth)/2;
        int arrSiteX = col5x + arrSiteMargin;
        [SPRTPrint drawText:arrSiteX textY:arrSiteY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:arriveSite fontSizeNum:4 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    // 目的网点编号
    NSString *dispatchCode = [self.billInfo objectForKey:kDispatchCodeKey];
    if (dispatchCode != nil) {
//        int arriveSiteCodeY = arrSiteY + 40;
        int arriveSiteCodeY = arrSiteY + 50;
        int arriveSiteCodeMargin = (siteWidth - (int)dispatchCode.length * aLet3NumWidth)/2;
        int arriveSiteCodeX = col5x + arriveSiteCodeMargin;
        [SPRTPrint drawText:arriveSiteCodeX textY:arriveSiteCodeY widthNum:sendArrSiteWidth heightNum:topLogHeight textStr:dispatchCode fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    //派送方式
    NSString *sendgoodsType = [self.billInfo objectForKey:kSendgoodsTypeKey];
    if (sendgoodsType != nil) {
        int width = col2x - col1x;
        int margin = (width - (int)sendgoodsType.length * aLet3StrWidth)/2;
        int x =  margin + col1x;
        int y = line4Y + 10;
        [SPRTPrint drawText:x textY:y widthNum:col2x heightNum:verticalShortMargin textStr:sendgoodsType fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    //物品名称
    NSString *goodsName = [self.billInfo objectForKey:kGoodsNameKey];
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

    //最顶部的竖线
    int topVerticalLinex = col5x - 100;
//    [SPRTPrint drawLine:2 startX:topVerticalLinex startY:0 endX:topVerticalLinex endY:line1Y isFullline:false];
    //目的网点所属中心
    NSString *dispatchCenter = [self.billInfo objectForKey:kDispatchCenterKey];
    if (dispatchCenter != nil) {
        int dispatchW = maxX - topVerticalLinex;
        int dispatchMargin = (dispatchW - (int)dispatchCenter.length * aLet5StrBoldWidth)/2;
        int dispatchX = topVerticalLinex + dispatchMargin;
        int dispatchY = 30;
        [SPRTPrint drawText:dispatchX textY:dispatchY widthNum:dispatchW heightNum:line1Y textStr:dispatchCenter fontSizeNum:5 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    }
    
    // 横着的条码图形
//    NSString *barCode = [billCode stringByAppendingFormat:@"%@",subCode];
	NSString *barCode = subCode;
    int barCodeH = 80;
    int barCodeX = col3x + 20;
    int barCodeY = line4Y + 20;
    if (barCode != nil) {
        [SPRTPrint drawBarCode:(barCodeX) startY:barCodeY textStr:barCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:barCodeH];
    }
    
    //横着的条码数字字符串
    int barNumY = barCodeY + 80;
    int barNumX = barCodeX + 85;
     [SPRTPrint drawText:(barNumX) textY:(barNumY) textStr:barCode fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
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
    id  weight = [self.billInfo objectForKey:kWeightKey];
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
    NSString *billDateStr = [data objectForKey:kRegisterDateKey];
    NSDate *billDate = [formatter dateFromString:billDateStr];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *formatBillDateStr = [formatter stringFromDate:billDate];
    formatBillDateStr = [NSString stringWithFormat:@"%@",formatBillDateStr];
    return formatBillDateStr;
}

//打印时间
- (NSString*)currentDateStr
{
	return [NSDate currentDateStrBy:nil];
}

- (NSArray *)subBillCodesWithBillData:(NSDictionary*)billInfo
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *subBillCodeStr = [billInfo objectForKey:kSubCodeKey];
    NSCharacterSet *semicolonCharSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    subBillCodeStr = [subBillCodeStr stringByTrimmingCharactersInSet:semicolonCharSet];
    NSArray *subCodesArra = [subBillCodeStr componentsSeparatedByCharactersInSet:semicolonCharSet];
//	NSString *billCode = [billInfo objectForKey:kBillCodeKey];
    for (NSString *codeStr in subCodesArra) {
//        NSString *subCodeStr = [codeStr stringByReplacingOccurrencesOfString:billCode withString:@""];
        if (codeStr.length > 0) {
            [array addObject:codeStr];
        }
    }
    return array;
}

#pragma mark -  UIPickerViewDataSource,
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.pagesAry count];
    }else{
        NSInteger selectedRow = [pickerView selectedRowInComponent:0];
        NSInteger loc = selectedRow;
        NSInteger len = self.pagesAry.count - loc;
        NSRange range = NSMakeRange(loc, len);
		self.endPagesAry = [self.pagesAry subarrayWithRange:range];
		self.pageRange = range;
        return [self.endPagesAry count];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSNumber *page;
	if (component == 0) {
		page = self.pagesAry[row];
	}else{
		page = self.endPagesAry[row];
	}
    return [NSString stringWithFormat:@"%@",page];
}


#pragma mark - request server
- (void)reqPrintBillInfo
{
    [SVProgressHUD showWithStatus:@"加载运单数据" maskType:SVProgressHUDMaskTypeBlack];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
#if DEBUG
	//测试环境的服务器
	NSString *urlStr = @"http://58.215.182.252:8610/AndroidServiceSTIOS/m8/qryBillSub.do";
#else
	//生产环境服务器
	NSString *urlStr = @"http://58.215.182.251:5889/AndroidService/m8/qryBillSub.do";
#endif

	__weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:urlStr];
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
						weakSelf.billInfo = [billInfos firstObject];
						[weakSelf reloadPagePickerView];
					}
				}
			}
		});
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
            [self updateOperBtnsWithConnedState];
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
            }
            else
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]]) 
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeReadCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFlowControlCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeFlowControlCharacteristic = characteristic;
                credit = 0;
                response = 1;
            }
            
            // qzfeng begin 2016/05/10
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID_cj]]) {
            
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
