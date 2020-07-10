//
//  ViewController.m
//  GSDK
//
//  Created by 猿史森林 on 2018/6/15.
//  Copyright © 2018年 Smarnet. All rights reserved.
//

#import "BluetoothListController.h"

@interface BluetoothListController ()<UITableViewDelegate,UITableViewDataSource>
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


-(void)viewDidAppear:(BOOL)animated {
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
                    [self startScanBlue];
                    NSLog(@"Bluetooth power on");
                    break;
                case CBCentralManagerStateUnknown:
                default:
                    break;
            }
        }];
    } else {
        [self startScanBlue];
    }
}


-(void)viewDidDisappear:(BOOL)animated{
    [Manager stopScan];
}

#pragma mark - bluetooth
-(void)connectDevice:(CBPeripheral *)peripheral {
    [Manager connectPeripheral:peripheral options:nil timeout:2 connectBlack:self.connectBlock];
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


#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [_devices count];
    return [[self.dicts allKeys]count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    CBPeripheral *peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
    [self connectDevice:peripheral];
}





@end
