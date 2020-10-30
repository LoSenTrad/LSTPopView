//
//  LSTPopViewPriorityVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/5/22.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewPriorityVC.h"
#import "LSTPriorityView.h"
#import <LSTPopView.h>

@interface LSTPopViewPriorityVC ()

@end

@implementation LSTPopViewPriorityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)noPriority:(UIButton *)sender {
    
    LSTPriorityView *view = [[LSTPriorityView alloc] init];
    view.layer.cornerRadius = 15;
    view.layer.masksToBounds = YES;
    view.frame = CGRectMake(0, 0, 300, 300);
    view.titleLab.text = @"窗口 - 1";
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    [popView pop];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LSTPriorityView *view = [[LSTPriorityView alloc] init];
        view.titleLab.text = @"窗口 - 2";
        view.backgroundColor = UIColor.orangeColor;
        view.layer.cornerRadius = 15;
        view.layer.masksToBounds = YES;
        view.frame = CGRectMake(0, 0, 300, 300);
        LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
        LSTPopViewWK(popView)
        popView.popDuration = 0.5;
        popView.dismissDuration = 0.5;
        popView.bgClickBlock = ^{
            NSLog(@"点击了背景");
            [wk_popView dismiss];
        };
        [popView pop];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LSTPriorityView *view = [[LSTPriorityView alloc] init];
        view.titleLab.text = @"窗口 - 3";
        view.backgroundColor = UIColor.purpleColor;
        view.layer.cornerRadius = 15;
        view.layer.masksToBounds = YES;
        view.frame = CGRectMake(0, 0, 300, 300);
        LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
        LSTPopViewWK(popView)
        popView.popDuration = 0.5;
        popView.dismissDuration = 0.5;
        popView.bgClickBlock = ^{
            NSLog(@"点击了背景");
            [wk_popView dismiss];
        };
        [popView pop];
    });
    
    
    
}

- (IBAction)hasPriority:(UIButton *)sender {
    
    LSTPriorityView *view = [[LSTPriorityView alloc] init];
    view.layer.cornerRadius = 15;
    view.layer.masksToBounds = YES;
    view.frame = CGRectMake(0, 0, 300, 300);
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    view.titleLab.text = [NSString stringWithFormat:@"窗口 - 1\n(优先级: %0.2f)",popView.priority];

    [popView pop];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LSTPriorityView *view = [[LSTPriorityView alloc] init];
        view.backgroundColor = UIColor.orangeColor;
        view.layer.cornerRadius = 15;
        view.layer.masksToBounds = YES;
        view.frame = CGRectMake(0, 0, 300, 300);
        LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
        LSTPopViewWK(popView)
        popView.popDuration = 0.5;
        popView.dismissDuration = 0.5;
        popView.priority = 200;
        popView.bgClickBlock = ^{
            NSLog(@"点击了背景");
            [wk_popView dismiss];
        };
        view.titleLab.text = [NSString stringWithFormat:@"窗口 - 2\n(优先级: %0.2f)",popView.priority];

        [popView pop];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LSTPriorityView *view = [[LSTPriorityView alloc] init];
        view.backgroundColor = UIColor.purpleColor;
        view.layer.cornerRadius = 15;
        view.layer.masksToBounds = YES;
        view.frame = CGRectMake(0, 0, 300, 300);
        LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSpringFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
        LSTPopViewWK(popView)
        popView.popDuration = 0.5;
        popView.dismissDuration = 0.5;
        popView.priority = 100;
        popView.bgClickBlock = ^{
            NSLog(@"点击了背景");
            [wk_popView dismiss];
        };
        view.titleLab.text = [NSString stringWithFormat:@"窗口 - 3\n(优先级: %0.2f)",popView.priority];

        [popView pop];
    });
    
    
}

@end
