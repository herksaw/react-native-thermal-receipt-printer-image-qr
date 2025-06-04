//
//  CPCLViewController.m
//  GPSDKDemo
//
//  Created by max on 2021/1/27.
//  Copyright © 2021 max. All rights reserved.
//

#import "CPCLViewController.h"
#import "CPCLCommand.h"
#import "ConnecterManager.h"
#import "ConnectViewController.h"
#import "SVProgressHUD.h"
@interface CPCLViewController ()
@property(nonatomic,strong)NSMutableDictionary *fontDict;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fontSeg;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

@implementation CPCLViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    _fontSeg.selectedSegmentIndex = 3; // FONT_04
}


- (IBAction)testMultiLinePrintAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand1] progress:^(NSUInteger total, NSUInteger progress) {
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

- (IBAction)testMultiLineReversePrintAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand2] progress:^(NSUInteger total, NSUInteger progress) {
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

- (IBAction)testCustomMultiLinePrintAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand3] progress:^(NSUInteger total, NSUInteger progress) {
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

- (IBAction)testCustomMultiLineReversePrintAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand4] progress:^(NSUInteger total, NSUInteger progress) {
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

- (IBAction)drawWatermarksAction:(id)sender {
    if ([Manager isConnected]) {
        [Manager write:[self cpclCommand5] progress:^(NSUInteger total, NSUInteger progress) {
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



- (NSData *)cpclCommand1{
    CPCLCommand *command = [[CPCLCommand alloc]init];
    //初始化
    [command addInitializePrinterwithOffset:0 withHeight:300 withQTY:1];
    NSString *test = @"句子，前后都有停顿，并带\n有一定的句调，表示相对\n完整的意义。句子前后\n或中间的停顿，在口头语言中，\n表现出来就是时间\n间隔，在书面语言中，就\n用标点符号来表示。一\n般来说，汉语中的句\n子分以下几种(结尾)";
    [command addMultiLineWithFont:(int)_fontSeg.selectedSegmentIndex + 1 withXstart:0 withYstart:0 withContent:test];

    //打印
    [command addPrint];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

- (NSData *)cpclCommand2{
    CPCLCommand *command = [[CPCLCommand alloc]init];
    //初始化
    [command addInitializePrinterwithOffset:0 withHeight:300 withQTY:1];
    NSString *test = @"句子，前后都有停顿，并带\n有一定的句调，表示相对\n完整的意义。句子前后\n或中间的停顿，在口头语言中，\n表现出来就是时间\n间隔，在书面语言中，就\n用标点符号来表示。一\n般来说，汉语中的句\n子分以下几种(结尾)";
    [command addMultiLineReverseTextWithFont:(int)_fontSeg.selectedSegmentIndex + 1 withXstart:0 withYstart:0 withContent:test];

    //打印
    [command addPrint];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

- (NSData *)cpclCommand3{
    CPCLCommand *command = [[CPCLCommand alloc]init];
    //初始化
    [command addInitializePrinterwithOffset:0 withHeight:1000 withQTY:1];
    [command addSetmagWithWidthScale:0 withHeightScale:0];
    NSString *test = self.textView.text;
    [command addCustomMultiLineTextWithFont:2 withXstart:0 withYstart:0 withRowWidth:361 withFixHeight:140 withContent:test];

    //打印
    [command addPrint];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

- (NSData *)cpclCommand4{
    CPCLCommand *command = [[CPCLCommand alloc]init];
    //初始化
    [command addInitializePrinterwithOffset:0 withHeight:1000 withQTY:1];
    NSString *test = self.textView.text;
    [command addCustomMultiLineReverseTextWithFont:(int)_fontSeg.selectedSegmentIndex + 1 withXstart:0 withYstart:0 withRowWidth:400 withFixHeight:0 withContent:test];

    //打印
    [command addPrint];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
}

- (NSData *)cpclCommand5{
    CPCLCommand *command = [[CPCLCommand alloc]init];
    //初始化
    [command addInitializePrinterwithOffset:0 withHeight:600 withQTY:1];
    
   NSString *test = @"句子，前后都有停顿，并带\n有一定的句调，表示相对\n完整的意义。句子前后\n或中间的停顿，在口头语言中，\n表现出来就是时间\n间隔，在书面语言中，就\n用标点符号来表示。一\n般来说，汉语中的句\n子分以下几种(结尾)";
    [command addMultiLineWithFont:(int)_fontSeg.selectedSegmentIndex + 1 withXstart:0 withYstart:0 withContent:test];
    [command drawWatermarks:0 withFont:(int)_fontSeg.selectedSegmentIndex + 1 withXstart:50 withYstart:300 withContent:@"水印测试" withBold:0 withWidthScale:0 withHeightScale:0];

    //打印
    [command addPrint];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    return [command getCommand];
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
