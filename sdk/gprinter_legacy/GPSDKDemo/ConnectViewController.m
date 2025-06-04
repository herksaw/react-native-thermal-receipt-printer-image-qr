//
//  ConnectViewController.m
//  GPSDKDemo
//
//  Created by max on 2020/7/22.
//  Copyright © 2020 max. All rights reserved.
//

#import "ConnectViewController.h"
#import "ConnecterManager.h"
#import "SVProgressHUD.h"

@interface ConnectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *deviceList;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property(nonatomic,strong)NSMutableArray *devices;
@property(nonatomic,strong)NSMutableDictionary *dicts;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;


@end

@implementation ConnectViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

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

-(void)viewDidAppear:(BOOL)animated {
    [Manager stopScan];
    if (Manager.bleConnecter == nil) {
        __weak __typeof(self)weakSelf = self;
        [Manager didUpdateState:^(NSInteger state) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
            switch (state) {
                case CBManagerStateUnsupported:
                    NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
                    break;
                case CBManagerStateUnauthorized:
                    NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
                    break;
                case CBManagerStatePoweredOff:
                    // 未连接
                    [Manager stopScan];
                    [Manager setIsConnected:NO];
                    [strongSelf.deviceList reloadData];
                    NSLog(@"Bluetooth is currently powered off.");
                    break;
                case CBManagerStatePoweredOn:
                    [strongSelf startScane];
                    NSLog(@"Bluetooth power on");
                    break;
                case CBManagerStateUnknown:
                default:
                    break;
            }
        }];
    } else {
        [self startScane];
    }
}
// 断开连接
- (IBAction)disconnectAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager close];
        Manager.bleConnecter.connPeripheral = nil;
        Manager.currentConnMethod = BLUETOOTH;
        self.disconnectBtn.hidden = YES;
        self.connectStatusLabel.text = @"未连接";
        [SVProgressHUD showErrorWithStatus:@"断开连接"];
    }
}


- (IBAction)wifiConnectAction:(id)sender {
    if([Manager isConnected]){
        [SVProgressHUD showSuccessWithStatus:@"请先断开当前设备"];
        return;
    }
    Manager.currentConnMethod = ETHERNET;
    NSString *ip = self.ipTextField.text;
    int port = [self.portTextField.text intValue];
    [Manager connectIP:ip port:port connectState:^(ConnectState state) {
        [self updateConnectState:state];
    } callback:^(NSData *data) {
        
    }];
}

-(void)updateConnectState:(ConnectState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case CONNECT_STATE_CONNECTING:
                self.connectStatusLabel.text = @"连接状态：连接中....";
                break;
            case CONNECT_STATE_CONNECTED:
                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
                self.connectStatusLabel.text = @"连接状态：已连接";
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceConnectSuccess" object:nil userInfo:nil]];
                break;
            case CONNECT_STATE_FAILT:
                [SVProgressHUD showErrorWithStatus:@"连接失败"];
                self.connectStatusLabel.text = @"连接状态：连接失败";
                break;
            case CONNECT_STATE_DISCONNECT:
                [SVProgressHUD showInfoWithStatus:@"断开连接"];
                self.connectStatusLabel.text = @"连接状态：断开连接";
                break;
            default:
                self.connectStatusLabel.text = @"连接状态：连接超时";
                break;
        }
    });
}


-(void)viewDidDisappear:(BOOL)animated{
    [Manager stopScan];
}

// 开始搜索
-(void)startScane {
    __weak __typeof(self)weakSelf = self;
    [Manager scanForPeripheralsWithServices:nil options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
        if (peripheral.name != nil) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            //NSLog(@"name -> %@",peripheral.name);
            NSUInteger oldCounts = [strongSelf.dicts count];
            [strongSelf.dicts setObject:peripheral forKey:peripheral.identifier.UUIDString];
            //NSLog(@"name=======%@uuid===%@",peripheral.name,peripheral.identifier.UUIDString);
            if (oldCounts < [self.dicts count]) {
                [strongSelf.deviceList reloadData];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"连接设备";
}

-(void)viewWillAppear:(BOOL)animated {
    if ([Manager isConnected] && Manager.currentConnMethod == BLUETOOTH) {
        self.connectStatusLabel.text = [NSString stringWithFormat:@"连接成功：%@",Manager.peripheral.name];
        self.disconnectBtn.hidden = NO;
    } else if ([Manager isConnected] && Manager.currentConnMethod == ETHERNET) {
        self.connectStatusLabel.text = @"Wi-Fi已连接";
        self.disconnectBtn.hidden = NO;
    }
}

#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

// 设置区间的头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,30)];
    topLabel.text = @"方式二：通过蓝牙连接";
    topLabel.textColor = [UIColor blueColor];
    topLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [view addSubview:topLabel];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    if([Manager isConnected]){
        [SVProgressHUD showSuccessWithStatus:@"请先断开当前设备"];
        return;
    }
    CBPeripheral *peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
    [self connectDevice:peripheral];
}

-(void)connectDevice:(CBPeripheral *)peripheral {
    NSLog(@"peripheral -> %@",peripheral.name);
    __weak __typeof(self)weakSelf = self;
    Manager.currentConnMethod = BLUETOOTH;
   
    [Manager connectPeripheral:peripheral options:nil timeout:2 connectBlack:^(ConnectState state) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        switch (state) {
            case CONNECT_STATE_CONNECTED:
                NSLog(@"/////连接成功");
                Manager.isConnected = YES;
                Manager.UUIDString = peripheral.identifier.UUIDString;
                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
                strongSelf.connectStatusLabel.text = [NSString stringWithFormat:@"连接成功：%@",peripheral.name];
                strongSelf.disconnectBtn.hidden = NO;
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceConnectSuccess" object:nil userInfo:nil]];
                [strongSelf.deviceList reloadData];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case CONNECT_STATE_CONNECTING:
                NSLog(@"////连接中....");
                break;
            default:
                NSLog(@"/////连接失败");
                Manager.isConnected = NO;
                strongSelf.connectStatusLabel.text = @"未连接";
                strongSelf.disconnectBtn.hidden = YES;
                [SVProgressHUD showErrorWithStatus:@"当前设备已断开，请尝试重新连接"];
                 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceDisconnect" object:nil userInfo:nil]];
                break;
        }
    }];
}

@end
