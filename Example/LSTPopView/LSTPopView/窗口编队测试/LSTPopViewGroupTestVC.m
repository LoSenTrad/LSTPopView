//
//  LSTPopViewGroupTestVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/5/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewGroupTestVC.h"
#import "LSTPopViewGroupTestView.h"
#import <UIColor+LSTColor.h>
#import <LSTPopView.h>
#import <UIView+LSTView.h>
#import <LSTGestureEvents.h>

@interface LSTPopViewGroupTestVC ()
@property (weak, nonatomic) IBOutlet UIView *contentView;


@end

@implementation LSTPopViewGroupTestVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    [self bindViewModel];
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
}


- (void)bindViewModel {
    
}

#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

- (IBAction)redBtnAction:(UIButton *)sender {
    
    LSTPopViewGroupTestView *view = [LSTPopViewGroupTestView getNibView:@"LSTPopViewGroupTestView"];
    view.backgroundColor = UIColor.redColor;
    view.frame = CGRectMake(0, 0, 150, 150);
    view.titleLab.text = @"红色编队窗口";
    
    
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:_contentView popStyle:LSTPopStyleScale dismissStyle:LSTDismissStyleNO];
    popView.adjustY = -rand()%300+25;
    popView.adjustX = -rand()%150+25;
    
    popView.groupId = @"red";
    
    LSTPopViewWK(popView);
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    popView.isHideBg = YES;
    [popView pop];
    
}

- (IBAction)orangeBtnAction:(UIButton *)sender {
    LSTPopViewGroupTestView *view = [LSTPopViewGroupTestView getNibView:@"LSTPopViewGroupTestView"];
    view.backgroundColor = UIColor.orangeColor;
    view.frame = CGRectMake(0, 0, 200, 200);
    view.titleLab.text = @"橙色编队窗口";
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:_contentView popStyle:LSTPopStyleScale dismissStyle:LSTDismissStyleNO];
    popView.adjustY = -rand()%300+25;
    popView.adjustX = -rand()%150+25;
    popView.groupId = @"orange";
    LSTPopViewWK(popView);
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    popView.isHideBg = YES;
    [popView pop];
}

- (IBAction)blueBtnAction:(UIButton *)sender {
    LSTPopViewGroupTestView *view = [LSTPopViewGroupTestView getNibView:@"LSTPopViewGroupTestView"];
    view.backgroundColor = UIColor.blueColor;
    view.frame = CGRectMake(0, 0, 100, 100);
    view.titleLab.text = @"蓝色编队窗口";
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:_contentView popStyle:LSTPopStyleScale dismissStyle:LSTDismissStyleNO];
    popView.adjustY = -rand()%300+25;
    popView.adjustX = -rand()%150+25;
    popView.groupId = @"blue";
    LSTPopViewWK(popView);
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
    popView.isHideBg = YES;
    [popView pop];
}


#pragma mark - ***** Lazy Loading 懒加载 *****



@end
