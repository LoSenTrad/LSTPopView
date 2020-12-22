//
//  LSTPopViewLifeCycleTestVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/6/5.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewLifeCycleTestVC.h"
#import <LSTPopView.h>
#import <UIView+LSTView.h>
#import <LSTGestureEvents.h>
#import "LSTLifeCycleView.h"

@interface LSTPopViewLifeCycleTestVC () <LSTPopViewProtocol>

@end

@implementation LSTPopViewLifeCycleTestVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutSubViewUI];
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    self.view.backgroundColor = UIColor.whiteColor;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self test];
}

#pragma mark - ***** Other 其他 *****

- (void)test {
    LSTLifeCycleView *view = [[LSTLifeCycleView alloc] init];
    view.size = CGSizeMake(350, 350);
    view.backgroundColor = UIColor.orangeColor;
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView);
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.delegate = self;
    popView.delegate = view;
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    popView.showTime = 5;
    popView.popViewCountDownBlock = ^(LSTPopView *popView, NSTimeInterval timeInterval) {
        view.timeLab.text = [NSString stringWithFormat:@"%.0lf",timeInterval];
    };
    
    [popView pop];
}

#pragma mark - ***** LSTPopViewProtocol *****

/** 点击弹窗 回调 */
- (void)lst_PopViewBgClick {
    NSLog(@"点了弹窗");
    
}
/** 长按弹窗 回调 */
- (void)lst_PopViewBgLongPress {
     NSLog(@"长按弹窗");
}


// ****** 生命周期 ******
/** 将要显示 */
- (void)lst_PopViewWillPopForPopView:(LSTPopView *)popView {
     NSLog(@"将要显示");
}
/** 已经显示完毕 */
- (void)lst_PopViewDidPopForPopView:(LSTPopView *)popView {
     NSLog(@"已经显示完毕");
}
- (void)lst_PopViewCountDownForPopView:(LSTPopView *)popView forCountDown:(NSTimeInterval)timeInterval {
    NSLog(@"倒计时---%u",timeInterval);
}
- (void)lst_PopViewCountDownFinishForPopView:(LSTPopView *)popView {
    NSLog(@"倒计时完成");
}
/** 将要开始移除 */
- (void)lst_PopViewWillDismissForPopView:(LSTPopView *)popView {
     NSLog(@"将要开始移除");
}
/** 已经移除完毕 */
- (void)lst_PopViewDidDismissForPopView:(LSTPopView *)popView {
     NSLog(@"已经移除完毕");
}

@end
