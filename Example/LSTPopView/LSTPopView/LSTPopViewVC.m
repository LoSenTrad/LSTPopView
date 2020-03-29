//
//  LSTPopViewVC.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/1/17.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewVC.h"
#import "LSTPopViewTestVC.h"
#import <LSTPopView.h>
#import "LSTPopViewXibView.h"
#import "LSTPopViewCodeView.h"

@interface LSTPopViewVC ()
<
UITableViewDataSource,
UITableViewDelegate
>


/** 表 */
@property (nonatomic,strong) UITableView *tableView;


@end

@implementation LSTPopViewVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
   
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
    self.title = @"LSTPopView示例";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
}

#pragma mark - ***** Other 其他 *****

#pragma mark - ***** Lazy Loading 懒加载 *****


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"纯代码自定义view";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"XIB自定义view";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"LSTPopView属性调试";
        }
            break;
            
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self codeView];
    }
    if (indexPath.row == 1) {
        [self xibView];
    }
    if (indexPath.row == 2) {
        [self LSTPopViewTest];
    }
}



- (void)codeView {
   
    LSTPopViewCodeView *view = [[LSTPopViewCodeView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
        
    view.frame = CGRectMake(0, 0, 300, 300);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleDropToLeft];
    popView.hemStyle = LSTHemStyleCenter;
    popView.adjustY = 10;
//    __weak typeof(popView) weakPopview = popView;
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    
    view.closeBlock = ^{
        [wk_popView dismissWithDismissStyle:LSTDismissStyleDropToTop duration:1.0];
    };
    
    [popView popWithPopStyle:LSTPopStyleSmoothFromTop duration:0.5];
}

- (void)xibView {
    
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewXibView" bundle:nil];
    LSTPopViewXibView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:1 dismissStyle:1];
    LSTPopViewWK(popView);
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
        NSLog(@"点击了背景");
    };
    
    view.clickBlock = ^{
        [popView dismiss];
    };
    
    [popView pop];
    
}

- (void)LSTPopViewTest {
    
    LSTPopViewTestVC *xibVC = [[LSTPopViewTestVC alloc] initWithNibName:@"LSTPopViewTestVC" bundle:nil];
    
    [self.navigationController pushViewController:xibVC animated:YES];
    
}

@end
