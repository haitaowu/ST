//
//  TicketPrintPreController.h
//  BTDemo
//
//  Created by ligl on 15-07-21.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import <UIKit/UIKit.h>

typedef enum :NSInteger{
	LatePrintNO = 0,
	LatePrintYES
} LatePrintFlag;




@interface TicketPrintPreController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UITableView *deviceListTableView;

- (void) stopScanPeripheral;

@property(nonatomic,strong) id billInfo;
@property(nonatomic,copy) NSString *billSN;
@property(nonatomic,assign) LatePrintFlag printFlag;



@end
