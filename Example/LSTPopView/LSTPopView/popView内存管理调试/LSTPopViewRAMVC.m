//
//  LSTPopViewRAMVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/21.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewRAMVC.h"
#import <LSTPopView.h>
#import "LSTPopViewCodeView.h"
#import <LSTPopViewManager.h>

@interface LSTPopViewRAMVC ()

@end

@implementation LSTPopViewRAMVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
}
- (void)dealloc {
  
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    self.view.backgroundColor = UIColor.whiteColor;
}


- (void)open {
    LSTPopViewCodeView *view = [[LSTPopViewCodeView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    
    view.frame = CGRectMake(0, 0, 300, 300);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:self.view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.hemStyle = LSTHemStyleCenter;
    popView.adjustY = 10;
    popView.isClickFeedback = YES;
    popView.bgColor = UIColor.blackColor;
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    
    view.closeBlock = ^{
        [wk_popView dismissWithStyle:LSTDismissStyleSmoothToTop duration:1.0];
    };
    
    [popView popWithStyle:LSTPopStyleCardDropFromLeft duration:0.5];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self open];
}


#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

#pragma mark - ***** Lazy Loading 懒加载 *****


@end
