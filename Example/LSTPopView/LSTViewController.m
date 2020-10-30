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
#import "LSTModel.h"


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
    
//    [LSTPopViewManager addTimerForIdentifier:@"123" handle:^(NSTimeInterval Interval) {
//        NSLog(@"%lf",Interval);
//    }];
    
    
//    [LSTPopViewManager addTimerForIdentifier:@"123" forUnit:5 handle:^(NSTimeInterval interval) {
//        NSLog(@"%lf",interval);
//    }];
   
//    [LSTPopViewManager addTimerForCountdown:30 handle:^(NSTimeInterval interval) {
//        NSLog(@"%lf",interval);
//    }];
    
//    [LSTPopViewManager addTimerForIdentifier:@"1" forCountdown:30 forUnit:5 handle:^(NSTimeInterval interval) {
//        NSLog(@"%lf",interval);
//
//    }];
//
//    [LSTPopViewManager addTimerForIdentifier:@"2" forCountdown:60 forUnit:5 handle:^(NSTimeInterval interval) {
//           NSLog(@"%lf",interval);
//
//       }];
//    [LSTPopViewManager addTimerForIdentifier:@"3" forCountdown:80 forUnit:5 handle:^(NSTimeInterval interval) {
//           NSLog(@"%lf",interval);
//
//       }];
//    [LSTPopViewManager addTimerForIdentifier:@"4" forCountdown:1000 forUnit:5 handle:^(NSTimeInterval interval) {
//           NSLog(@"%lf",interval);
//
//       }];
    
//
//    [LSTPopViewManager addDiskTimerForIdentifier:@"1" forCountdown:100 forUnit:1 handle:^(NSTimeInterval interval) {
//
//        NSLog(@"%lf",interval);
//    }];
//    [LSTPopViewManager addDiskTimerForIdentifier:@"2" forCountdown:100 forUnit:1 handle:^(NSTimeInterval interval) {
//
//        NSLog(@"%lf",interval);
//    }];
//    [LSTPopViewManager addDiskTimerForIdentifier:@"3" forCountdown:100 forUnit:1 handle:^(NSTimeInterval interval) {
//
//        NSLog(@"%lf",interval);
//    }];
//    [LSTPopViewManager addDiskTimerForIdentifier:@"4" forCountdown:100 forUnit:1 handle:^(NSTimeInterval interval) {
//
//        NSLog(@"%lf",interval);
//    }];
//    [LSTPopViewManager addDiskTimerForIdentifier:@"5" forCountdown:100 forUnit:1 handle:^(NSTimeInterval interval) {
//
//        NSLog(@"%lf",interval);
//    }];

    
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
