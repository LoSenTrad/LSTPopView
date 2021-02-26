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
#import <UIView+LSTView.h>
#import "LSTPopViewXibView.h"
#import "LSTPopViewCodeView.h"
#import "LSTMutiPopViewVC.h"
#import "LSTAutoKeyboardVC.h"
#import "LSTPopViewRAMVC.h"
#import "LSTPopViewSceneVC.h"
#import "LSTPopViewGroupTestVC.h"
#import "LSTPopViewPriorityVC.h"
#import "LSTPopViewLifeCycleTestVC.h"
#import "LSTPopViewTimerTestVC.h"
#import "LSTPopViewListView.h"
//#import <LSTPopViewManager.h>
#import "LSTPopViewTVView.h"
#import "LSTLaunchMutiPopViewVC.h"
#import "LSTModel.h"
#import "LSTTestView.h"
#import <UIKit/UIFeedbackGenerator.h>
#import "LSTPopViewDragVC.h"




@interface LSTPopViewVC ()
<
UITableViewDataSource,
UITableViewDelegate,
LSTPopViewProtocol
>


/** 表 */
@property (nonatomic,strong) UITableView *tableView;
/** <#.....#> */


@property (nonatomic,weak) LSTPopView *popView;

/**  */
@property (nonatomic,strong) UIView *testView;

/** <#.....#> */
@property (nonatomic,strong)  NSMutableArray *arr1;
/** <#.....#> */
@property (nonatomic,strong)  NSMutableArray *arr2;
@end

@implementation LSTPopViewVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"调试" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    
    self.testView = [[UIView alloc] init];

    
    
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    
    self.arr1 = arr1;
    self.arr2 = arr2;
    
    
    [arr1 addObject:self.testView];
    [arr2 addObject:self.testView];
    
    [arr1 removeAllObjects];
    
    

}



- (void)test {
    
     

    //    LSTPopViewListView *view = [[LSTPopViewListView alloc] init];
    //    view.layer.cornerRadius = 10;
    //    view.layer.masksToBounds = YES;
    //
    //    view.frame = CGRectMake(0, 0, 300, 500);
    //    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    //    LSTPopViewWK(popView)
    //    popView.hemStyle = LSTHemStyleCenter;
    //    popView.popDuration = 0.8;
    //    popView.dismissDuration = 0.8;
    //    popView.bgColor = UIColor.blackColor;
    //    popView.isObserverScreenRotation = YES;
    //    popView.bgClickBlock = ^{
    //        //        NSLog(@"点击了背景");
    //        [wk_popView dismiss];
    //    };
    //    [popView pop];
    //    self.popView = popView;

    
    LSTPopViewTVView *customView = [[LSTPopViewTVView alloc] initWithFrame:CGRectMake(0, 0, LSTScreenWidth(), LSTScreenHeight()*(0.8))];
    LSTPopView *popView = [LSTPopView initWithCustomView:customView
                                              parentView:self.view
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
    self.popView = popView;
    popView.priority = 1000;
    popView.hemStyle = LSTHemStyleBottom;
    popView.dragStyle = LSTDragStyleY_Positive;
    popView.dragDistance =  customView.height*0.5;
    popView.sweepStyle = LSTSweepStyleY_Positive;
    popView.swipeVelocity = 1600;
    popView.sweepDismissStyle = LSTSweepDismissStyleSmooth;

    
    [popView pop];
    
//    LSTPopViewWK(self);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wk_self codeView];
//    });
    
    
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
    return 13;
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
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"LSTPopView属性调试";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"app启动多窗口实例模拟";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"常用示例场景";
        }
            break;
//        case 3:
//        {
//            cell.textLabel.text = @"拖拽轻扫手势示例场景";
//        }
//            break;
        case 3:
        {
            cell.textLabel.text = @"纯代码自定义view";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"XIB自定义view";
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"多个popView窗口测试";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"规避键盘遮挡调试";
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"popView内存释放调试";
        }
            break;
        case 8:
        {
            cell.textLabel.text = @"多窗口编队调试";
        }
            break;
        case 9:
        {
            cell.textLabel.text = @"窗口优先级调试";
        }
            break;
        case 10:
        {
            cell.textLabel.text = @"生命周期调试(多代理)";
        }
            break;
        case 11:
        {
            cell.textLabel.text = @"定时器调试";
        }
            break;
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self LSTPopViewTest];
    }
    if (indexPath.row == 1) {
        LSTLaunchMutiPopViewVC *vc = [[LSTLaunchMutiPopViewVC alloc] initWithNibName:@"LSTLaunchMutiPopViewVC" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];

    }
    if (indexPath.row == 2) {
        LSTPopViewSceneVC *vc = [[LSTPopViewSceneVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    if (indexPath.row == 3) {
//        LSTPopViewDragVC *vc = [[LSTPopViewDragVC alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//
//    }
    
    if (indexPath.row == 3) {
        [self codeView];
    }
    
    if (indexPath.row == 4) {
        [self xibView];
    }
    
    if (indexPath.row == 5) {
        LSTMutiPopViewVC *vc = [[LSTMutiPopViewVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.row == 6) {
        LSTAutoKeyboardVC *vc = [[LSTAutoKeyboardVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 7) {
        LSTPopViewRAMVC *vc = [[LSTPopViewRAMVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.row == 8) {
        LSTPopViewGroupTestVC *xibVC = [[LSTPopViewGroupTestVC alloc] initWithNibName:@"LSTPopViewGroupTestVC" bundle:nil];
        [self.navigationController pushViewController:xibVC animated:YES];
        
    }
    
    if (indexPath.row == 9) {
        LSTPopViewPriorityVC *xibVC = [[LSTPopViewPriorityVC alloc] initWithNibName:@"LSTPopViewPriorityVC" bundle:nil];
        [self.navigationController pushViewController:xibVC animated:YES];
        
    }
    
    if (indexPath.row == 10) {
        LSTPopViewLifeCycleTestVC *vc = [[LSTPopViewLifeCycleTestVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    if (indexPath.row == 11) {
        LSTPopViewTimerTestVC *vc = [[LSTPopViewTimerTestVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)codeView {
    
    LSTPopViewCodeView *view = [[LSTPopViewCodeView alloc] init];
//    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;    
    view.frame = CGRectMake(0, 0, 300, 300);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:nil popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.priority = 800;
    self.popView = popView;

    LSTPopViewWK(popView)
    popView.hemStyle = LSTHemStyleCenter;
//    popView.adjustY = 10;
    popView.popDuration = 0.8;
    popView.dismissDuration = 0.8;
    popView.isClickFeedback = YES;
    popView.isHideBg = NO;
    popView.delegate = self;
    popView.isObserverScreenRotation = YES;
    popView.cornerRadius = 10;
    popView.rectCorners = UIRectCornerTopLeft|UIRectCornerBottomRight;
    popView.bgClickBlock = ^{
        //        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    view.closeBlock = ^{
        [wk_popView dismissWithStyle:LSTDismissStyleSmoothToTop duration:1.0];
    };
    
    [popView pop];
}

- (void)xibView {
    
    LSTPopViewXibView *view = [LSTPopViewXibView getNibView:@"LSTPopViewXibView"];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;

    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleSmoothFromTop
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.popStyle = LSTPopStyleNO;
    popView.dismissStyle = LSTDismissStyleNO;
    popView.popDuration = 1.0;
    popView.dismissDuration = 1.0;
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    view.clickBlock = ^{
        [wk_popView dismiss];
    };
    popView.dragStyle = LSTDragStyleAll;
    popView.sweepStyle = LSTSweepStyleALL;
    popView.sweepDismissStyle = LSTSweepDismissStyleVelocity;
    [popView pop];
}

- (void)two {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewXibView" bundle:nil];
    LSTPopViewXibView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
        //        NSLog(@"点击了背景");
    };
    view.clickBlock = ^{
        [wk_popView dismiss];
    };
    [popView pop];
}

- (void)LSTPopViewTest {
    
    LSTPopViewTestVC *xibVC = [[LSTPopViewTestVC alloc] initWithNibName:@"LSTPopViewTestVC" bundle:nil];
    [self.navigationController pushViewController:xibVC animated:YES];
    
}

@end
