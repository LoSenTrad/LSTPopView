//
//  LSTViewController.m
//  LSTPopView
//
//  Created by 490790096@qq.com on 03/06/2020.
//  Copyright (c) 2020 490790096@qq.com. All rights reserved.
//

#import "LSTViewController.h"
#import "LSTPopViewVC.h"
#import "LSTAlertViewVC.h"
#import "LSTSheetAlertViewVC.h"
#import <Masonry.h>
#import <LSTGestureEvents.h>
#import <LSTControlEvents.h>
#import <LSTPopView.h>
#import <LSTPopViewManager.h>
#import "LSTPopViewCodeView.h"


@interface LSTViewController ()

/** <#.....#> */
@property (nonatomic,strong) NSTimer *timer;


/** <#.....#> */
@property (nonatomic,weak) LSTPopView *popView;

@end

@implementation LSTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"LSTPopView -- 万能弹窗";
    
    
    [LSTPopViewManager addTimerForIdentifier:@"123" handle:^(NSTimeInterval Interval) {
        NSLog(@"%lf",Interval);
    }];
    
   
   

    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    LSTPopViewCodeView *view = [[LSTPopViewCodeView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    view.frame = CGRectMake(0, 0, 300, 300);
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    self.popView = popView;
    __weak typeof(self.popView) wk_popView = self.popView;
    self.popView.hemStyle = LSTHemStyleCenter;
    self.popView.adjustY = 10;
    self.popView.popDuration = 0.8;
    self.popView.dismissDuration = 0.8;
    self.popView.isClickFeedback = YES;
    self.popView.bgColor = UIColor.blackColor;
    self.popView.isHideBg = NO;
    self.popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    view.closeBlock = ^{
        [wk_popView dismissWithDismissStyle:LSTDismissStyleSmoothToTop duration:1.0];
    };
    
    [self.popView pop];
    
}



- (IBAction)popViewBtn:(UIButton *)sender {
    
    LSTPopViewVC *vc = [[LSTPopViewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)alertViewBtn:(UIButton *)sender {
    
    LSTAlertViewVC *vc = [[LSTAlertViewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sheetAlertViewBtn:(UIButton *)sender {
    
    LSTSheetAlertViewVC *vc = [[LSTSheetAlertViewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
