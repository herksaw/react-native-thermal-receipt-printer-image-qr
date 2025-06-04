//
//  ZPLListViewController.m
//  GPSDKDemo
//
//  Created by max on 2021/3/3.
//  Copyright © 2021 max. All rights reserved.
//

#import "ZPLListViewController.h"
#import "SVProgressHUD.h"
#import "ZplCommand.h"
#import "ConnecterManager.h"
#import "ConnectViewController.h"
@interface ZPLListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *selectIndexs; //多选选中的行
@property (strong, nonatomic) NSDictionary *zplDict; //zpl指令
@property (strong, nonatomic) NSArray *labelNameArr; //名称
@property (strong, nonatomic) NSArray *setNameArr; //名称
@end

@implementation ZPLListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZPL指令打印";
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithTitle:@"选中打印" style:UIBarButtonItemStyleDone target:self action:@selector(sureAction)];
    self.navigationItem.rightBarButtonItem = moreItem;
    [self selectIndexs];
    _setNameArr = @[@"打印3张",@"设置速度",@"设置浓度",@"图像左右颠倒打印",@"反相打印",@"标签内容转过 180 度打印",@"设置纸张类型：连续纸",@"设置纸张类型：间隙纸",@"设置纸张类型：黑标纸",@"打印模式：撕纸",@"标签上下移动",@"设置撕离位置"];
    _labelNameArr = @[@"文字",@"Code 39 码",@"EAN-8 条码",@"UPC-E 条码",@"Code 128 条码",@"EAN-13 条码",@"QR 条码",@"UPC-A 条码",@"横线",@"竖线",@"画框",@"画圆",@"画斜线",@"画椭圆",@"图片1",@"图片2"];
}

- (NSMutableArray *)selectIndexs {
    if (!_selectIndexs) {
        _selectIndexs = [[NSMutableArray alloc] init];
    }
    return _selectIndexs;
}

- (void)sureAction {
    if ([Manager isConnected]) {
        [Manager write:[self zplCommand:_selectIndexs] receCallBack:^(NSData *data) {
        }];
    } else {
        ConnectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSData *)zplCommand:(NSMutableArray *)dataSource{
    ZplCommand *command = [ZplCommand new];
    [command startZpl];
    [command addCls:YES];
    [command addDensity:3];
    [command addReference:0 :0];
    [command addSize:480 :400];
    
    if (_selectIndexs.count) {
        for (NSIndexPath *index in _selectIndexs) {
            
            if (index.section == 0) {
                if (index.row == 0) [command addPrintNum:3 copy:0 pauseCut:0 isPause:YES];
                if (index.row == 1) [command addSpeed:4];
                if (index.row == 2) [command addDensity:8];
                if (index.row == 3) [command addMirror: YES];
                if (index.row == 4) {
                    [command addReversePrint:YES];
                    [command addGraphicBoxX:0 y:0 w:480 h:400 border:480 rounding:0];
                }
                if (index.row == 5) [command addInvertOrientation:YES];
                if (index.row == 6) [command setPaperType:PAPER_N withBLineStartOffset:0];
                if (index.row == 7) [command setPaperType:PAPER_Y withBLineStartOffset:16];
                if (index.row == 8) [command setPaperType:PAPER_M withBLineStartOffset:16];
                if (index.row == 9) [command addPrintMode:@"T"];
                if (index.row == 10) [command addTopOffset:32];
                if (index.row == 11) [command adjustTearOffPosition:16];
            }
            
            if (index.section == 1) {
                if (index.row == 0) [command addTextwithX:30 withY:0 withFont:@"0" withRotation:@"N" withFontWid:36 withFontHei:20 withText:@"Smart print"];
                if (index.row == 1) [command addCODE39:@"1234567" x:50 y:0 config:nil];
                if (index.row == 2) [command addEAN8:@"1234567" x:0 y:0 config:nil];
                if (index.row == 3) [command addUPCE:@"1234567" x:0 y:0 config:nil];
                if (index.row == 4) [command addCODE128:@"1234567" x:0 y:0 config:nil];
                if (index.row == 5) [command addEAN13:@"1234567" x:0 y:0 config:nil];
                if (index.row == 6) [command addQRCode:@"1234567" x:0 y:0 config:nil];
                if (index.row == 7) [command addUPCA:@"1234567" x:0 y:0 config:nil];
                if (index.row == 8) [command addGraphicBoxX:0 y:0 w:200 h:0 border:1 rounding:0];// 横线
                if (index.row == 9) [command addGraphicBoxX:0 y:0 w:0 h:200 border:1 rounding:0];// 竖线
                if (index.row == 10) [command addGraphicBoxX:0 y:0 w:300 h:300 border:3 rounding:0];
                if (index.row == 11) [command addGraphicCircleX:0 y:0 diameter:120 border:3];
                if (index.row == 12) [command addGraphicDiagonalLineX:0 y:0 w:300 h:240 border:5 Orientation:@"R"];
                if (index.row == 13) [command addGraphicEllipseX:0 y:0 w:240 h:180 border:1];
                if (index.row == 14) [command addBitmapwithX:0 withY:30 withWidth:231 withImage:[UIImage imageNamed:@"gprinter"]];
                if (index.row == 15) [command addBitmapwithX:0 withY:30 withWidth:400 withImage:[UIImage imageNamed:@"gprinter"]];
            }
            
        }
        
    }

    [command endZpl];
    return [command getCommand];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"选择设置参数";
    }
    
    if (section == 1) {
        return @"选择输出内容";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _setNameArr.count;
    }
    
    if (section == 1) {
        return _labelNameArr.count;
    }
    return 0;
}
//

//选中某一行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) { //如果为选中状态
        cell.accessoryType = UITableViewCellAccessoryNone; //切换为未选中
        [_selectIndexs removeObject:indexPath]; //数据移除
        
    }else { //未选中
        cell.accessoryType = UITableViewCellAccessoryCheckmark; //切换为选中
        [_selectIndexs addObject:indexPath]; //添加索引数据到数组
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cellid";
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%ld.%@",(long)indexPath.row,_setNameArr[indexPath.row]];
    }
    
    if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%ld.%@",(long)indexPath.row,_labelNameArr[indexPath.row]];
    }
    for (NSIndexPath *index in _selectIndexs) {
        if (indexPath == index) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
}
    return cell;
}

@end
