//
//  ViewController.m
//  GSDK
//
//  Created by 猿史森林 on 2018/6/15.
//  Copyright © 2018年 Smarnet. All rights reserved.
//

#import "BluetoothListController.h"
#import "SPRTPrint.h"
#import "SVProgressHUD.h"
#import <PrinterSDK/PrinterSDK.h>




#define BleManager  [PTDispatcher share]

//for issc
static NSString *const kWriteCharacteristicUUID_cj = @"49535343-8841-43F4-A8D4-ECBE34729BB3";
static NSString *const kReadCharacteristicUUID_cj = @"49535343-1E4D-4BD9-BA61-23C647249616";
static NSString *const kServiceUUID_cj = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
//for ivt
static NSString *const kFlowControlCharacteristicUUID = @"ff03";
static NSString *const kWriteCharacteristicUUID = @"ff02";
static NSString *const kReadCharacteristicUUID = @"ff01";
static NSString *const kServiceUUID = @"ff00";



@interface BluetoothListController ()<UITableViewDelegate,UITableViewDataSource,CBPeripheralDelegate>
@property(nonatomic,strong)NSMutableArray *devices;
@property(nonatomic,strong)NSMutableDictionary *dicts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BluetoothListController


#pragma mark - lazy properties
-(NSMutableArray *)devices {
    if (!_devices) {
        _devices = [[NSMutableArray alloc]init];
    }
    return _devices;
}

-(NSMutableDictionary *)dicts {
    if (!_dicts) {
        _dicts = [[NSMutableDictionary alloc]init];
    }
    return _dicts;
}


#pragma mark - overrides
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙列表";
}

/**
 *开始搜索蓝牙
 */
- (void)startToScanBlesByType{
	if(self.printerType == HPRINTER){
		[self startScanHPrinterBle];
	}else{
		if (Manager.bleConnecter == nil) {
			[Manager didUpdateState:^(NSInteger state) {
				switch (state) {
					case CBCentralManagerStateUnsupported:
						NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
						break;
					case CBCentralManagerStateUnauthorized:
						NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
						break;
					case CBCentralManagerStatePoweredOff:
						NSLog(@"Bluetooth is currently powered off.");
						break;
					case CBCentralManagerStatePoweredOn:
						[self startScanBlues];
						NSLog(@"Bluetooth power on");
						break;
					case CBCentralManagerStateUnknown:
					default:
						break;
				}
			}];
		} else {
			[self startScanBlues];
		}
	}
}

/**
 *han yin 查询蓝牙
 */
- (void)startScanHPrinterBle{
	[BleManager scanBluetooth];
	__weak typeof(self) weakSelf = self;
	[BleManager whenFindAllBluetooth:^(NSMutableArray<PTPrinter *> *blesAry) {
		NSLog(@"BleManager bluetoothCount -> %ld",blesAry.count);
		NSMutableArray *dataAry = [NSMutableArray array];
		for (PTPrinter *printer in blesAry) {
			if ([printer.name containsString:@"HM-"]) {
				[dataAry addObject:printer];
			}
		}
		weakSelf.devices = dataAry;
		[weakSelf.tableView reloadData];
	}];
}



/**
 *sprinter和jia bo da yin ji
 */
-(void)startScanBlues {
	__weak typeof (self) weakSelf = self;
    [Manager scanForPeripheralsWithServices:nil options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
        if (peripheral.name != nil) {
            NSLog(@"name -> %@",peripheral.name);
            NSUInteger oldCounts = [self.dicts count];
			if((weakSelf.printerType == GPRINTER) && [peripheral.name containsString:@"Printer_"]){
				[weakSelf.dicts setObject:peripheral forKey:peripheral.identifier.UUIDString];
			}else if ((weakSelf.printerType == SPRINTER) && [peripheral.name containsString:@"L51 BT"]) {
				[weakSelf.dicts setObject:peripheral forKey:peripheral.identifier.UUIDString];
			}
            if (oldCounts < [weakSelf.dicts count]) {
                [_tableView reloadData];
            }
        }
    }];
}


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self startToScanBlesByType];
}



-(void)viewDidDisappear:(BOOL)animated{
	if (self.printerType == HPRINTER) {
		[BleManager stopScanBluetooth];
	}else{
		[Manager stopScan];
	}
}




#pragma mark - bluetooth
-(void)connectDevice:(CBPeripheral *)peripheral {
	__weak typeof(self) weakSelf = self;
	NSDictionary *options  = nil;
	if([self isSPrinter:peripheral]){
		options = @{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES};
	}
	[Manager connectPeripheral:peripheral options:options timeout:2 connectBlack:^(ConnectState state) {
		if (state == CONNECT_STATE_CONNECTED) {
			[weakSelf hasConnectedToPeripheral:peripheral];
		}
		weakSelf.connResultBlock(state, _printerType);
	}];
}



-(void)startScanBlue {
    [Manager scanForPeripheralsWithServices:nil options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
        if (peripheral.name != nil) {
            NSLog(@"name -> %@",peripheral.name);
            NSUInteger oldCounts = [self.dicts count];
            [self.dicts setObject:peripheral forKey:peripheral.identifier.UUIDString];
            if (oldCounts < [self.dicts count]) {
                [_tableView reloadData];
            }
        }
    }];
}



#pragma mark - sprinter   peripheral
- (void)hasConnectedToPeripheral:(CBPeripheral*)peripheral
{
	if([self isSPrinter:peripheral] == NO){
		return ;
	}
	
	activeDevice = peripheral;
	peripheral.delegate = self;
	[peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
    // qzfeng begin 2016/05/10
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID_cj]]];

}


/// is sprinter printer???
- (BOOL)isSPrinter:(CBPeripheral*)peripheral
{
	if ( self.printerType == SPRINTER ){
		return YES;
	}else{
		return NO;
	}
}


#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

	if (self.printerType == HPRINTER) {
		return [_devices count];
	}else{
		return [[self.dicts allKeys]count];
	}
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	CBPeripheral *peripheral;
	if (self.printerType == HPRINTER) {
		PTPrinter *printer = self.devices[indexPath.row];
		peripheral = printer.peripheral;
	}else{
		peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
	}

    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (self.printerType == HPRINTER) {
		PTPrinter *printer = self.devices[indexPath.row];
		[SVProgressHUD showWithStatus:@"连接中"];
		__weak typeof(self) weakSelf = self;
		[BleManager connectPrinter:printer];
		[BleManager whenConnectSuccess:^{
			[SVProgressHUD dismiss];
			NSLog(@"connect to hm success");
			ConnectState state = CONNECT_STATE_CONNECTED;
			weakSelf.connResultBlock(state, _printerType);
		}];
		
		/*
		NOT_FOUND_DEVICE,//未找到设备
		   CONNECT_STATE_DISCONNECT,//断开连接
		   CONNECT_STATE_CONNECTING,//连接中
		   CONNECT_STATE_CONNECTED,//连接上
		   CONNECT_STATE_TIMEOUT,//连接超时
		   CONNECT_STATE_FAILT//连接失败
		 */
		
		[BleManager whenUnconnect:^(NSNumber *number, BOOL isActive) {
			[SVProgressHUD dismiss];
			ConnectState state = CONNECT_STATE_DISCONNECT;
			weakSelf.connResultBlock(state, _printerType);
		}];
		
		[BleManager whenConnectFailureWithErrorBlock:^(PTConnectError error) {
			[SVProgressHUD dismiss];
			NSLog(@"connect to hm whenSendFailure:%@",error);
			ConnectState state;
			switch (error) {
				case PTConnectErrorBleTimeout:
					state = CONNECT_STATE_TIMEOUT;
					break;
				default:
					state = CONNECT_STATE_FAILT;
					break;
			}
			weakSelf.connResultBlock(state, _printerType);
		}];
		
	}else{
		CBPeripheral *selPeripheral = Manager.bleConnecter.connPeripheral;
		int waitSecs = 0;
		if (selPeripheral != nil) {
			[Manager.bleConnecter closePeripheral:selPeripheral];
			waitSecs = 3;
		}
		[SVProgressHUD show];
		CBPeripheral *peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitSecs * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self connectDevice:peripheral];
		});
	}
}


#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:error
{
	if (error!=nil){
		NSLog(@"didWriteValueForCharacteristic Write edata failed!");
		return;
	}
	NSLog(@"Write edata success!");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error==nil)
    {
        //在这个方法中我们要查找到我们需要的服务  然后调用discoverCharacteristics方法查找我们需要的特性
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
            {
                cjFlag=0;           // qzfeng 2016/05/10
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
    if (error==nil){
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





@end
