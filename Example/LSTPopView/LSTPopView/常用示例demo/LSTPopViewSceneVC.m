//
//  LSTPopViewSceneVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/23.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewSceneVC.h"
#import <LSTPopView.h>
#import <Masonry.h>
#import "LSTPopViewQQView.h"
#import <UIView+LSTView.h>
#import <LSTGestureEvents.h>
#import "LSTPopViewqqtopView.h"
#import "LSTPopViewWeChatView.h"
#import "LSTPopViewTranspondView.h"
#import "LSTPopViewUCView.h"
#import "LSTPopViewBaiDuView.h"
#import "LSTPopViewrRSidebarView.h"
#import "LSTPopViewrLSidebarView.h"
#import "LSTPopViewBottomInputView.h"
#import "LSTPopViewCenterInputView.h"
#import "LSTPopViewloadingView.h"
#import <UIColor+LSTColor.h>
#import "LSTPopViewdoyinView.h"
#import "LSTPopViewListView.h"
#import "LSTPopViewTVView.h"
#import "LSTPopViewHeightChangeView.h"

@interface LSTPopViewSceneVC ()
<
UITableViewDelegate,
UITableViewDataSource
>

/** 表 */
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation LSTPopViewSceneVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}


- (void)bindViewModel {
    
}

#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"QQ音乐顶部提示栏";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"QQ顶部提示栏";
        }
            break;
        case 2:
        {
             cell.textLabel.text = @"类微信/微博底部弹窗";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"微信消息转发弹窗";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"UC分享弹窗";
        }
            break;
        case 5:
        {
             cell.textLabel.text = @"百度云盘分类菜单(显示在self.view上)";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"右侧边栏";
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"左侧边栏";
        }
            break;
        case 8:
        {
            cell.textLabel.text = @"中间输入框";
        }
            break;
        case 9:
        {
            cell.textLabel.text = @"底部输入框";
        }
            break;
        case 10:
        {
            cell.textLabel.text = @"加载指示器";
        }
            break;
        case 11:
        {
            cell.textLabel.text = @"抖音个人主页";
        }
            break;
        case 12:
        {
            cell.textLabel.text = @"collectionView展示";
        }
            break;
        case 13:
        {
            cell.textLabel.text = @"tableView展示";
        }
            break;
        case 14:
        {
            cell.textLabel.text = @"自定义view动态高度变化";
        }
            break;
        default:
            break;
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    switch (indexPath.row) {
        case 0:
        {
            [self test0];
        }
            break;
        case 1:
        {
            [self test1];
        }
            break;
        case 2:
        {
             [self test2];
        }
            break;
        case 3:
        {
            [self test3];
        }
            break;
        case 4:
        {
            [self test4];
        }
            break;
        case 5:
        {
            [self test5];
        }
            break;
        case 6:
        {
            [self test6];
        }
            break;
        case 7:
        {
            [self test7];
        }
            break;
        case 8:
        {
            [self test8];
        }
            break;
        case 9:
        {
            [self test9];
        }
            break;
        case 10:
        {
            [self test10];
        }
            break;
        case 11:
        {
            [self test11];
        }
            break;
        case 12:
        {
            [self test12];
        }
            break;
        case 13:
        {
            [self test13];
        }
            break;
        case 14:
        {
            [self test14];
        }
            break;
        default:
            break;
    }
}

- (void)test0 {
    LSTPopViewQQView *view = [LSTPopViewQQView getNibView:@"LSTPopViewQQView"];
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToTop];
    LSTPopViewWK(popView)
    popView.hemStyle = LSTHemStyleTop;
    popView.popDuration = 0.25;
    popView.dismissDuration = 0.25;
    popView.isClickFeedback = YES;
    popView.bgColor = UIColor.blackColor;
    popView.isHideBg = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    [popView pop];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wk_popView dismiss];
    });
    

}
- (void)test1 {
    LSTPopViewqqtopView *view = [LSTPopViewqqtopView getNibView:@"LSTPopViewqqtopView"];
    view.frame = CGRectMake(0, 0, LSTScreenWidth()-40, 60);
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToTop];
    LSTPopViewWK(popView)
    popView.hemStyle = LSTHemStyleTop;
    popView.popDuration = 0.25;
    popView.dismissDuration = 0.25;
    popView.adjustY = LSTStatusBarHeight();
    popView.isClickFeedback = YES;
    popView.bgColor = UIColor.blackColor;
    popView.isHideBg = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wk_popView dismiss];
    });
    
    [popView pop];
}
- (void)test2 {
    LSTPopViewWeChatView *view = [LSTPopViewWeChatView getNibView:@"LSTPopViewWeChatView"];
    view.layer.cornerRadius = 15;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromBottom dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.hemStyle = LSTHemStyleBottom;
    popView.popDuration = 0.25;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}

- (void)test3 {
    LSTPopViewTranspondView *view = [[LSTPopViewTranspondView alloc] init];
    view.frame = CGRectMake(0, 0, LSTScreenWidth()-80,(LSTScreenWidth()-80)/1.23);
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleNO];
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}

- (void)test4 {
    LSTPopViewUCView *view = [[LSTPopViewUCView alloc] init];
    view.frame = CGRectMake(0, 0, LSTScreenWidth()-20,(LSTScreenWidth()-20)/1.30);
    view.layer.cornerRadius = 20;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromBottom dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.hemStyle = LSTHemStyleBottom;
    popView.adjustY = -LSTTabBarBottomMargin();
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}

- (void)test5 {
    LSTPopViewBaiDuView *view = [[LSTPopViewBaiDuView alloc] init];
    view.frame = CGRectMake(0, 0, LSTScreenWidth(),(LSTScreenWidth())/1.95);
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                              parentView:self.view
                                                popStyle:LSTPopStyleSpringFromTop
                                            dismissStyle:LSTDismissStyleSmoothToTop];
    popView.hemStyle = LSTHemStyleTop;
    popView.adjustY = LSTNavBarHeight()-20;
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}
             
- (void)test6 {
    LSTPopViewrRSidebarView *view = [[LSTPopViewrRSidebarView alloc] init];
    view.frame = CGRectMake(0, 0, 280,LSTScreenHeight()-LSTNavBarHeight());
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                              parentView:self.view
                                                popStyle:LSTPopStyleSpringFromRight
                                            dismissStyle:LSTDismissStyleSmoothToRight];
    popView.hemStyle = LSTHemStyleRight;
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}

- (void)test7 {
    LSTPopViewrLSidebarView *view = [LSTPopViewrLSidebarView getNibView:@"LSTPopViewrLSidebarView"];
    view.frame = CGRectMake(0, 0, LSTScreenWidth()-40 ,LSTScreenHeight());
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleSmoothFromLeft
                                            dismissStyle:LSTDismissStyleSmoothToLeft];
    popView.hemStyle = LSTHemStyleLeft;
    LSTPopViewWK(popView)
//    popView.adjustX = -20;
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.dragStyle = LSTDragStyleX_Negative;
    popView.sweepStyle = LSTSweepStyleX_Negative;
    popView.dragDistance = (LSTScreenWidth()-40)*0.5;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}

- (void)test8 {
    LSTPopViewCenterInputView *view = [LSTPopViewCenterInputView getNibView:@"LSTPopViewCenterInputView"];
    view.frame = CGRectMake(0, 0, 300,254);
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleFade
                                            dismissStyle:LSTDismissStyleFade];
    popView.hemStyle = LSTHemStyleCenter;
    LSTPopViewWK(popView);
    LSTPopViewWK(view);
    popView.adjustY = 100;
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_view.textTF resignFirstResponder];
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_view.textTF resignFirstResponder];
        [wk_popView dismiss];
    }];
    
    [popView pop];
    
    [view.textTF becomeFirstResponder];
}

- (void)test9 {
    LSTPopViewBottomInputView *view = [LSTPopViewBottomInputView getNibView:@"LSTPopViewBottomInputView"];
    view.frame = CGRectMake(0, 0, LSTScreenWidth(),150);
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                              parentView:self.view
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.hemStyle = LSTHemStyleBottom;
    LSTPopViewWK(popView);
    LSTPopViewWK(view);
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.avoidKeyboardSpace = 0;
    popView.bgClickBlock = ^{
//        NSLog(@"点击了背景");
        [wk_popView dismiss];
//        [view endEditing:YES];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view.textTF becomeFirstResponder];
    });
    
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        wk_view.height = wk_view.height-10;
    }];
    
    [popView pop];
  
}

- (void)test10 {
    LSTPopViewloadingView *view = [LSTPopViewloadingView getNibView:@"LSTPopViewloadingView"];
    view.frame = CGRectMake(0, 0, 180,40);
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.backgroundColor =  LSTRGBColorWithAlpha(0, 0, 0, 0.5);
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleScale
                                            dismissStyle:LSTDismissStyleNO];
    popView.hemStyle = LSTHemStyleCenter;
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.avoidKeyboardSpace = 0;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.titleLab.text = @"😘数据加载完成~";
        
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wk_popView dismiss];
    });
    
    [popView pop];
}

- (void)test11 {
    LSTPopViewdoyinView *view = [LSTPopViewdoyinView getNibView:@"LSTPopViewdoyinView"];
    view.frame = CGRectMake(0, 0, LSTScreenWidth(),LSTScreenWidth()/1.31);
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.hemStyle = LSTHemStyleBottom;
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    
    popView.sweepStyle = LSTSweepStyleY_Positive;
    popView.dragStyle = LSTDragStyleY_Positive;
    popView.sweepDismissStyle = LSTSweepDismissStyleSmooth;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    
    [popView pop];
}

- (void)test12 {
    LSTPopViewListView *view = [[LSTPopViewListView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    view.frame = CGRectMake(0, 0, LSTScreenWidth()-40, LSTScreenHeight()-LSTNavBarHeight()*2);
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.hemStyle = LSTHemStyleCenter;
    popView.popDuration = 0.8;
    popView.dismissDuration = 0.8;
    popView.bgColor = UIColor.blackColor;
    popView.isObserverScreenRotation = YES;
    popView.bgClickBlock = ^{
        //        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [popView pop];

}

- (void)test13 {
//    LSTPopViewTVView *view = [[LSTPopViewTVView alloc] init];
//    view.layer.cornerRadius = 8;
//    view.layer.masksToBounds = YES;
//
//    view.frame = CGRectMake(0, 0, LSTScreenWidth()-40, LSTScreenHeight()*(2/3.0));
//    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
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
    LSTPopViewTVView *customView = [[LSTPopViewTVView alloc] initWithFrame:CGRectMake(0, 0, LSTScreenWidth(), LSTScreenHeight()*(0.8))];
    LSTPopView *popView = [LSTPopView initWithCustomView:customView
                                              parentView:self.view
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
//    self.popView = popView;
    popView.priority = 1000;
    popView.hemStyle = LSTHemStyleBottom;
    popView.dragStyle = LSTDragStyleY_Positive;
    popView.dragDistance =  customView.height*0.5;
    popView.sweepStyle = LSTSweepStyleY_Positive;
    popView.swipeVelocity = 1600;
    popView.sweepDismissStyle = LSTSweepDismissStyleSmooth;

    
    [popView pop];
}

//- (void)test14 {
//    UIView *view = [[UIView alloc] init];
//    view.layer.cornerRadius = 8;
//    view.layer.masksToBounds = YES;
//    view.backgroundColor = UIColor.orangeColor;
//
//    view.frame = CGRectMake(0, 0, LSTScreenWidth(), LSTScreenHeight());
//    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
//    LSTPopViewWK(popView);
//    LSTPopViewWK(view);
//    popView.hemStyle = LSTHemStyleCenter;
//    popView.popDuration = 0.8;
//    popView.dismissDuration = 0.8;
//    popView.bgColor = UIColor.blackColor;
//
//    popView.panOffsetBlock = ^(CGPoint offset) {
//
////        wk_view.y = wk_view.y+offset.y;
//
//        LSTPVLog(@"%@",NSStringFromCGPoint(offset));
//
//    };
//
//    [popView pop];
//
//}

- (void)test14 {
    LSTPopViewHeightChangeView *view = [LSTPopViewHeightChangeView getNibView:@"LSTPopViewHeightChangeView"];
    view.frame = CGRectMake(0, 0, 300, 170);
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleSmoothFromTop
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.isClickFeedback = YES;
    popView.cornerRadius = 8;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [popView pop];
}

#pragma mark - ***** Lazy Loading 懒加载 *****

- (UITableView *)tableView {
    if(_tableView) return _tableView;
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    return _tableView;
}


@end
