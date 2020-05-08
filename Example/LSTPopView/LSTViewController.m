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


@interface LSTViewController ()

/** <#.....#> */
@property (nonatomic,strong) NSTimer *timer;

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
