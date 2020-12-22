//
//  LSTLaunchMutiPopViewVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/12/9.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTLaunchMutiPopViewVC.h"
#import "LSTAppUpdateView.h"
#import <LSTPopView.h>
#import <UIView+LSTPV.h>
#import "LSTAppPrivacyView.h"
#import "LSTAppFlashAdView.h"
#import "LSTIndexAdView.h"
#import "LSTOpenPushView.h"

@interface LSTLaunchMutiPopViewVC ()

@end

@implementation LSTLaunchMutiPopViewVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
}


#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    //以下是通过优先级机制 进行了弹窗的排序 逐个展示
    
    //打开闪屏ad
    [LSTLaunchMutiPopViewVC appFlashAdPopView];
    //打开app新版本更新(模拟网络请求延时)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LSTLaunchMutiPopViewVC appUpdatePopView];
    });
    //打开app首页广告弹窗//打开app新版本更新(模拟网络请求延时)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LSTLaunchMutiPopViewVC appIndexAdPopView];
    });
    //打开推送弹窗
    [LSTLaunchMutiPopViewVC appPushPopView];
    
    
//    [LSTLaunchMutiPopViewVC appFlashAdPopView];
//    [LSTLaunchMutiPopViewVC appUpdatePopView];
//    [LSTLaunchMutiPopViewVC appPrivacyPopView];
//    [LSTLaunchMutiPopViewVC appIndexAdPopView];
//    [LSTLaunchMutiPopViewVC appPushPopView];
    
}

/**
 - 1.app闪屏广告位(网络请求,有延迟) 优先级1000
 - 2.app版本升级提示弹窗(网络请求,有延迟) 优先级900
 - 3.app用户隐私弹窗(无延迟) 优先级600
 - 4.app弹窗广告位(网络请求,有延迟) 优先级500
 - 5.打开推送通知(无延迟)  优先级400
 - 6.青少年模式弹窗(短视频,直播app,必须) 优先级300
 */

+ (void)appFlashAdPopView {
    UINib *nib = [UINib nibWithNibName:@"LSTAppFlashAdView" bundle:nil];
    LSTAppFlashAdView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.size = CGSizeMake(pv_ScreenWidth(), pv_ScreenHeight());
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleNO dismissStyle:LSTDismissStyleFade];
    popView.popStyle = LSTPopStyleNO;
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    popView.showTime = 5;
    popView.priority = 1000;
    LSTPopViewWK(view);
    popView.popViewCountDownBlock = ^(LSTPopView * _Nonnull popView, NSTimeInterval timeInterval) {
        [wk_view.timeBtn setTitle:[NSString stringWithFormat:@"跳过 %.0lf",timeInterval] forState:UIControlStateNormal];
    };
    [popView pop];
    view.skipBlock = ^(id sender) {
        [wk_popView dismissWithStyle:LSTDismissStyleFade];
    };
    
}

+ (void)appUpdatePopView {
    UINib *nib = [UINib nibWithNibName:@"LSTAppUpdateView" bundle:nil];
    LSTAppUpdateView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.size = CGSizeMake(300, 450);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
    popView.popStyle = LSTPopStyleNO;
    popView.priority = 900;
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };

    [popView pop];
}

+ (void)appPrivacyPopView {
    UINib *nib = [UINib nibWithNibName:@"LSTAppPrivacyView" bundle:nil];
    LSTAppPrivacyView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.size = CGSizeMake(350, 450);
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
    popView.popStyle = LSTPopStyleNO;
    LSTPopViewWK(popView)
    popView.priority = 800;
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };

    [popView pop];
}

+ (void)appIndexAdPopView {
    UINib *nib = [UINib nibWithNibName:@"LSTIndexAdView" bundle:nil];
    LSTIndexAdView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.size = CGSizeMake(350, 450);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
    popView.popStyle = LSTPopStyleNO;
    LSTPopViewWK(popView)
    popView.priority = 700;
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };

    [popView pop];
}

+ (void)appPushPopView {
    UINib *nib = [UINib nibWithNibName:@"LSTOpenPushView" bundle:nil];
    LSTOpenPushView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.size = CGSizeMake(300, 300);
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
    popView.popStyle = LSTPopStyleNO;
    LSTPopViewWK(popView)
    popView.priority = 600;
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };

    [popView pop];
}



#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

#pragma mark - ***** Lazy Loading 懒加载 *****

@end
