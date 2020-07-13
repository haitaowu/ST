//
//  DeliverBillPrinterController.h
//  BTDemo
//
//  Created by ligl on 15-07-21.
//
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>



@interface DeliverBillPrinterController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) id billInfo;


@end
