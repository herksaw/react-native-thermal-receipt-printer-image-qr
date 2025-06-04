//
//  ViewController.m
//  GPSDKDemo
//
//  Created by max on 2020/7/22.
//  Copyright © 2020 max. All rights reserved.
//

#import "ViewController.h"
#import "ConnecterManager.h"
#import "ConnectViewController.h"
#import "SVProgressHUD.h"
#import "EscCommand.h"
#import "TscCommand.h"
#import "CPCLCommand.h"
#import "GPUtils.h"
#import "CPCLViewController.h"
#import "ZPLListViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *connStateLabel;
@property(nonatomic,assign) BOOL isReceive;
@end

@implementation ViewController

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GSDK Demo";
    
    //注册通知：
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnect) name:@"deviceDisconnect" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnect) name:@"deviceConnectSuccess" object:nil];
    
    if (@available(iOS 10.0, *)) {
        [self testHttp]; // 默许
    } else {
    }
    
}

-(void)testHttp{
    NSURL *url = [NSURL URLWithString:@"https://m.gainscha.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);
        }
    }];
    
    [dataTask resume];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Notificat & monitor
-(void)deviceDisconnect {
    NSLog(@"当前设备已断开，请尝试重新连接");
    [SVProgressHUD showErrorWithStatus:@"当前设备已断开，请尝试重新连接"];
    self.connStateLabel.text = @"连接状态：未连接";
}

-(void)deviceConnect {
    NSLog(@"当前设备已经连接");
    self.connStateLabel.text = @"连接状态：已连接";
}

-(void)updateConnectState:(ConnectState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case CONNECT_STATE_CONNECTING:
                self.connStateLabel.text = @"连接状态：连接中....";
                break;
            case CONNECT_STATE_CONNECTED:
                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
                self.connStateLabel.text = @"连接状态：已连接";
                break;
            case CONNECT_STATE_FAILT:
                [SVProgressHUD showErrorWithStatus:@"连接失败"];
                self.connStateLabel.text = @"连接状态：连接失败";
                break;
            case CONNECT_STATE_DISCONNECT:
                [SVProgressHUD showInfoWithStatus:@"断开连接"];
                self.connStateLabel.text = @"连接状态：断开连接";
                break;
            default:
                self.connStateLabel.text = @"连接状态：连接超时";
                break;
        }
    });
}

#pragma mark - 测试数据
-(NSData *)tscCommand:(int)gap{
    int size= 8;
    TscCommand *command = [[TscCommand alloc]init];
    [command addSize:48 :80];
    [command addGapWithM:gap withN:0];
    [command addReference:0 :0];
    [command addTear:@"ON"];
    [command addQueryPrinterStatus:ON];
    [command addCls];
    [command addTextwithX:0 withY:10*size withFont:@"TSS24.BF2" withRotation:0 withXscal:2 withYscal:2 withText:@"佳博科技ABCD1234"];
    [command addTextwithX:0 withY:18*size withFont:@"5" withRotation:0 withXscal:1 withYscal:1 withText:@"2020/01/01"];
    int mode = 0; // mode -> 0 正常；mode -> 3，压缩打印，仅部分支持压缩算法的机型适用
    [command addNewBitmapwithX:0 withY:28*size withMode:mode withWidth:400 withImage:[UIImage imageNamed:@"gprinter"]];
    [command addPrint:1 :1];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

-(NSData *)escCommand{
    EscCommand *command = [[EscCommand alloc]init];
    [command addInitializePrinter];
    [command addPrintAndFeedLines:5];
    //内容居中
    [command addSetJustification:1];
    [command addPrintMode: 88];
    [command addText:@"Print text\n"];
    [command addPrintAndLineFeed];
    [command addPrintMode: 0];
    [command addText:@"Welcome to use Smarnet printer!"];
    //换行
    [command addPrintAndLineFeed];
    //内容居左（默认居左）
    [command addSetJustification:0];
    [command addText:@"佳博"];
    //设置水平和垂直单位距离
    [command addSetHorAndVerMotionUnitsX:7 Y:0];
    //设置绝对位置
    [command addSetAbsolutePrintPosition:6];
    [command addText:@"网络"];
    [command addSetAbsolutePrintPosition:10];
    [command addText:@"设备"];
    [command addPrintAndLineFeed];
    NSString *content = @"Gprinter";
    //二维码
    [command addQRCodeSizewithpL:0 withpH:0 withcn:0 withyfn:0 withn:5];
    [command addQRCodeSavewithpL:0x0b withpH:0 withcn:0x31 withyfn:0x50 withm:0x30 withData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [command addQRCodePrintwithpL:0 withpH:0 withcn:0 withyfn:0 withm:0];
    [command addPrintAndLineFeed];

    [command addSetBarcodeWidth:2];
    [command addSetBarcodeHeight:60];
    [command addSetBarcodeHRPosition:2];
    [command addCODE128:'B' : @"ABC1234567890"];
    
    [command addPrintAndLineFeed];
    
    UIImage *image = [UIImage imageNamed:@"gprinter"];

    NSData *imageData = [GPUtils escBitmapDataWithImage:image andScaleWidth:40 * 8 andScaleHeight:40 * 8];
    int picwidth = image.size.width;
    int picheight = image.size.height;

    
    [command addESCBitmapwithM:40 withxL:((picwidth/8)/256) withxH:((picwidth/8)/256) withyL:picheight/256 withyH:picheight/256 withData:imageData];
    
    [command addPrintAndFeedLines:5];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

- (NSData *)cpclCommand{
    CPCLCommand *command = [[CPCLCommand alloc]init];
    //初始化
    [command addInitializePrinterwithOffset:0 withHeight:1000 withQTY:1];
    
    //居中
    [command addJustification:CENTER];
    
    [command addSetmagWithWidthScale:1 withHeightScale:1];
    
    //文字
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:30 withContent:@"Sample"];
    
    [command addSetmagWithWidthScale:0 withHeightScale:0];
    [command addJustification:LEFT];
    
    //打印图片
    UIImage *img = [UIImage imageNamed:@"gprinter.png"];
    [command addGraphics:COMPRESSED WithXstart:0 withYstart:65 withImage:img withMaxWidth:385];

    [command addText:T withFont:FONT_04 withXstart:240 withYstart:65 withContent:@"Print code128!"];

    //条码文字注释
    [command addBarcodeTextWithFont:5 withOffset:2];
    //条码
    [command addBarcode:BARCODE withType:Code128 withWidth:1 withRatio:Point0 withHeight:50 withXstart:240 withYstart:130 withString:@"012345678"];

    //关闭注释
    [command addBarcodeTextOff];
    
    // 方位
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:330 withContent:@"佳博"];
    [command addJustification:CENTER];

    [command addText:T withFont:FONT_04 withXstart:0 withYstart:330 withContent:@"网络"];
    [command addJustification:RIGHT];

    [command addText:T withFont:FONT_04 withXstart:0 withYstart:330 withContent:@"设备"];
    [command addJustification:LEFT];
    
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:370 withContent:@"测试非粗体 效果SMARNET printer"];
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:400 withContent:@"欢迎使用SMARNET"];
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:430 withContent:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    
    // 粗体测试
    [command setBold:YES];
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:460 withContent:@"测试粗体 效果SMARNET printer"];
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:490 withContent:@"欢迎使用SMARNET"];
    [command addText:T withFont:FONT_04 withXstart:0 withYstart:520 withContent:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    [command setBold:NO];
    
    [command addReverseText:T withFont:FONT_00 withXstart:0 withYstart:560 withContent:@"中英文 //[]English混搭123反色"];
    [command addReverseText:T withFont:FONT_01 withXstart:0 withYstart:600 withContent:@"中英文 //[]English混搭123反色"];
    [command addReverseText:T withFont:FONT_02 withXstart:0 withYstart:640 withContent:@"中英文 //[]English混搭123反色"];
    
    [command addReverseText:T withFont:FONT_04 withXstart:0 withYstart:720 withContent:@"退改单1234567890"];
    
    [command addReverseText:T withFont:FONT_05 withXstart:0 withYstart:820 withContent:@"中文字符“”‘'（）《》〈〉【】"];
    
//    [command addSetmagWithWidthScale:2 withHeightScale:2];
//    [command addText:T withFont:FONT_00 withXstart:0 withYstart:680 withContent:@"字体宽高放大2倍"];
//    [command addReverseText:T withFont:FONT_03 withXstart:0 withYstart:760 withContent:@"中英文 //[]English"];
//    [command addReverseText:T withFont:FONT_04 withXstart:0 withYstart:820 withContent:@"中英文 //[]English"];
//    [command addReverseText:T withFont:FONT_05 withXstart:0 withYstart:920 withContent:@"中英文 //[]English"];
//
//    [command addSetmagWithWidthScale:3 withHeightScale:3];
//    [command addText:T withFont:FONT_00 withXstart:0 withYstart:970 withContent:@"字体宽高放大3倍"];
//    [command addReverseText:T withFont:FONT_00 withXstart:0 withYstart:1050 withContent:@"中英文English"];
//    [command addReverseText:T withFont:FONT_01 withXstart:0 withYstart:1150 withContent:@"中英文English"];
//    [command addReverseText:T withFont:FONT_02 withXstart:0 withYstart:1250 withContent:@"中英文English"];
    
//    [command addText:T withFont:FONT_04 withXstart:0 withYstart:790 withContent:@"不同方向下的反色文本"];
//    [command addReverseText:T180 withFont:FONT_04 withXstart:400 withYstart:860 withContent:@"逆时针旋转 180 度，反转打印文本。"];
//    [command addReverseText:VT withFont:FONT_04 withXstart:0 withYstart:1400 withContent:@"逆时针旋转 90 度，纵向打印文本。"];
//    [command addReverseText:T90 withFont:FONT_04 withXstart:250 withYstart:1400 withContent:@"逆时针旋转 90 度，纵向打印文本。"];
//    [command addReverseText:T270 withFont:FONT_04 withXstart:500 withYstart:885 withContent:@"逆时针旋转 270 度，纵向打印文本。"];
//    [command addJustification:LEFT];

    //打印
    [command addPrint];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

#pragma mark - 点击事件
- (IBAction)connectAction:(id)sender {
    ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

// 标签打印测试(TSPL) 标签纸: 默认设置标签间隙为2
- (IBAction)TSPLPrintAction1:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self tscCommand:2] receCallBack:^(NSData *data) {}];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 标签打印测试(TSPL)  连续纸
- (IBAction)TSPLPrintAction2:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self tscCommand:0] receCallBack:^(NSData *data) {}];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)ESCPrintAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self escCommand] receCallBack:^(NSData *data) {}];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)CPCLPrintAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand] receCallBack:^(NSData *data) {}];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)TSPLStatusCheckAction:(id)sender {
    if ([Manager isConnected]) {
        __weak __typeof(self)weakSelf = self;
        self.isReceive = NO;
        if (!self.isReceive) {
                 //tsc查询状态指令
                 unsigned char tscCommand[] = {0x1B, 0x21,0x3F};
                    Manager.connecter.readData = ^(NSData * _Nullable data) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        strongSelf.isReceive = YES;
                        NSLog(@"data -> %@",data);
                        [SVProgressHUD showInfoWithStatus:[self TSPLHexStringWithData:data]];
                    };
                 [Manager write:[NSData dataWithBytes:tscCommand length:sizeof(tscCommand)]];
             }
    } else {
        [SVProgressHUD showErrorWithStatus:@"连接设备后再进行查询操作"];
    }
}

- (IBAction)ESCStatusCheckAction:(id)sender {
    if ([Manager isConnected]) {
        __weak __typeof(self)weakSelf = self;
        self.isReceive = NO;
        if (!self.isReceive) {
                 //esc查询状态指令
                 unsigned char escCommand[] = {0x10, 0x04, 0x02};
                    Manager.connecter.readData = ^(NSData * _Nullable data) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        strongSelf.isReceive = YES;
                        NSLog(@"data -> %@",data);
                        [SVProgressHUD showInfoWithStatus:[self ESCHexStringWithData:data]];
                    };
                 [Manager write:[NSData dataWithBytes:escCommand length:sizeof(escCommand)]];
             }
    } else {
        [SVProgressHUD showErrorWithStatus:@"连接设备后再进行查询操作"];
    }
}


- (IBAction)CPCLStatusCheckAction:(id)sender {
    if ([Manager isConnected]) {
        __weak __typeof(self)weakSelf = self;
        self.isReceive = NO;
        if (!self.isReceive) {
                 //cpcl查询状态指令
                 unsigned char cpclCommand[] = {0x1B, 0x68};
                    Manager.connecter.readData = ^(NSData * _Nullable data) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        strongSelf.isReceive = YES;
                        NSLog(@"data -> %@",data);
                        [SVProgressHUD showInfoWithStatus:[self CPCLHexStringWithData:data]];
                    };
                 [Manager write:[NSData dataWithBytes:cpclCommand length:sizeof(cpclCommand)]];
             }
    } else {
        [SVProgressHUD showErrorWithStatus:@"连接设备后再进行查询操作"];
    }
}


- (IBAction)progressWriteLabelAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self tscCommand:2] progress:^(NSUInteger total, NSUInteger progress) {
            CGFloat p = (CGFloat)progress / (CGFloat)total;
            [SVProgressHUD showProgress:p status:@"发送中..."];
            if(total - progress == 0) {
                NSLog(@"发送完成");
                [SVProgressHUD dismiss];
            }
        } receCallBack:^(NSData * _Nullable data) {
            NSLog(@"返回打印机状态==%@",[self TSPLHexStringWithData:data]);
            [SVProgressHUD showInfoWithStatus:[self TSPLHexStringWithData:data]];
        }];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (IBAction)progressWriteLabe2lAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self tscCommand:0] progress:^(NSUInteger total, NSUInteger progress) {
            CGFloat p = (CGFloat)progress / (CGFloat)total;
            [SVProgressHUD showProgress:p status:@"发送中..."];
            if(total - progress == 0) {
                NSLog(@"发送完成");
                [SVProgressHUD dismiss];
            }
        } receCallBack:^(NSData * _Nullable data) {
            NSLog(@"返回打印机状态==%@",[self TSPLHexStringWithData:data]);
            [SVProgressHUD showInfoWithStatus:[self TSPLHexStringWithData:data]];
        }];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (IBAction)progressWriteTicket:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self escCommand] progress:^(NSUInteger total, NSUInteger progress) {
            CGFloat p = (CGFloat)progress / (CGFloat)total;
            [SVProgressHUD showProgress:p status:@"发送中..."];
            if(total - progress == 0) {
                NSLog(@"发送完成");
                [SVProgressHUD dismiss];
            }
        } receCallBack:^(NSData * _Nullable data) {
            NSLog(@"返回打印机状态==%@",[self ESCHexStringWithData:data]);
            [SVProgressHUD showInfoWithStatus:[self ESCHexStringWithData:data]];
        }];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)progressCPCLAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand] progress:^(NSUInteger total, NSUInteger progress) {
            CGFloat p = (CGFloat)progress / (CGFloat)total;
            [SVProgressHUD showProgress:p status:@"发送中..."];
            if(total - progress == 0) {
                NSLog(@"发送完成");
                [SVProgressHUD dismiss];
            }
        } receCallBack:^(NSData * _Nullable data) {
            NSLog(@"返回打印机状态==%@",[self CPCLHexStringWithData:data]);
            [SVProgressHUD showInfoWithStatus:[self CPCLHexStringWithData:data]];
        }];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)newCPCLTestAction:(id)sender {
    ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CPCLVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickZPLAction:(id)sender {
    if ([Manager isConnected]) {
        ZPLListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZPLList"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - tool
-(NSString *)TSPLHexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    
    NSDictionary *dic = @{
        @"00":@"正常待机",
        @"01":@"开盖",
        @"02":@"卡纸",
        @"03":@"卡纸、开盖",
        @"04":@"缺纸",
        @"05":@"确知、开盖",
        @"08":@"无碳带",
        @"09":@"无碳带、开盖",
        @"0A":@"无碳带、卡纸",
        @"0B":@"无碳带、卡纸、开盖",
        @"0C":@"无碳带、缺纸",
        @"0D":@"无碳带、缺纸、开盖",
        @"10":@"暂停打印",
        @"20":@"正在打印",
        @"41":@"盖子未关闭",
        @"80":@"其他错误",
        
    };
    return ([dic valueForKey:hexStr]) ? [dic valueForKey:hexStr] : @"其他错误";
}

-(NSString *)ESCHexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    
    NSDictionary *dic = @{
        @"12":@"正常",
        @"32":@"缺纸",
        @"16":@"开盖",
        @"40":@"错误状态",
    };
    return ([dic valueForKey:hexStr]) ? [dic valueForKey:hexStr] : @"其他状态";
}

-(NSString *)CPCLHexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    
    NSDictionary *dic = @{
        @"00":@"正常待机",
        @"01":@"走纸或正在打印",
        @"02":@"缺纸",
        @"04":@"开盖有纸",
        @"06":@"开盖缺纸",
    };
    return ([dic valueForKey:hexStr]) ? [dic valueForKey:hexStr] : @"其他状态";
}


@end
