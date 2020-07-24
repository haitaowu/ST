//
//  ViewController.h
//  GSDK
//
//  Created by 猿史森林 on 2018/6/15.
//  Copyright © 2018年 Smarnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnecterManager.h"


typedef enum: NSInteger{
	NONPRINTER = 21,
	SPRINTER = 22,
	GPRINTER = 23
} PrinterType;


typedef void(^BleConnResultBlock)(ConnectState state,PrinterType type);



@interface BluetoothListController : UIViewController

@property(nonatomic,copy)ConnectDeviceState connectBlock;

@property(nonatomic,copy)BleConnResultBlock connResultBlock;


@end

