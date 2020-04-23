//
//  LSTMutiPopViewVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/3/31.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTMutiPopViewVC.h"
#import "LSTPopViewCodeView.h"
#import <LSTPopView.h>
#import "LSTMutiPopView.h"

#define LSTRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define LSTRGBAColor(r, g, b ,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define LSTRandColor LSTRGBColor(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))

@interface LSTMutiPopViewVC ()

@end

@implementation LSTMutiPopViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self open];
}


- (void)open {
    LSTMutiPopView *view = [[LSTMutiPopView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.backgroundColor = LSTRandColor;
    
    view.frame = CGRectMake(0, 0, 300, 300);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.hemStyle = LSTHemStyleCenter;
    popView.adjustY = 10;
    popView.isClickFeedback = YES;
    //    __weak typeof(popView) weakPopview = popView;
    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    
    view.closeBlock = ^{
        [wk_self open];
    };
    
    [popView popWithPopStyle:LSTPopStyleSmoothFromTop duration:0.5];
}

@end
