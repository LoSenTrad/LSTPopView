//
//  LSTPopViewTimerTestVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/7/10.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTimerTestVC.h"
#import <Masonry.h>
#import "LSTPopViewTimerView.h"
#import <LSTPopView.h>

@interface LSTPopViewTimerTestVC ()

/** <#.....#> */
@property (nonatomic,strong) UIButton *btn;

@end

@implementation LSTPopViewTimerTestVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    [self btnAction];
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.btn];
    [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.center.equalTo(self.view);
    }];
    

    
}



#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

- (void)btnAction {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTimerView" bundle:nil];
    LSTPopViewTimerView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    LSTPopViewWK(self)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    popView.popViewCountDownBlock = ^(LSTPopView * _Nonnull popView, NSTimeInterval timeInterval) {
        view.timeLab.text = [NSString stringWithFormat:@"%.0lf",timeInterval];
    };
    popView.showTime = 5;
    popView.popViewDidDismissBlock = ^{
        [wk_self popView2];
    };
    [popView pop];
}

- (void)popView2 {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTimerView" bundle:nil];
    LSTPopViewTimerView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.imgView.image = [UIImage imageNamed:@"美女2"];
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    LSTPopViewWK(self)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    popView.popViewCountDownBlock = ^(LSTPopView * _Nonnull popView, NSTimeInterval timeInterval) {
        view.timeLab.text = [NSString stringWithFormat:@"%.0lf",timeInterval];
    };
    popView.showTime = 5;
    popView.popViewDidDismissBlock = ^{
        [wk_self popView3];
    };
    [popView pop];
}

- (void)popView3 {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTimerView" bundle:nil];
    LSTPopViewTimerView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.imgView.image = [UIImage imageNamed:@"美女3"];

    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    popView.popViewCountDownBlock = ^(LSTPopView * _Nonnull popView, NSTimeInterval timeInterval) {
        view.timeLab.text = [NSString stringWithFormat:@"%.0lf",timeInterval];
    };
    popView.showTime = 5;

    [popView pop];
}

#pragma mark - ***** Lazy Loading 懒加载 *****

- (UIButton *)btn {
    if(_btn) return _btn;
    _btn = [[UIButton alloc] init];
    [_btn setTitle:@"点击" forState:UIControlStateNormal];
    [_btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btn setBackgroundColor:UIColor.orangeColor];
    [_btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    return _btn;
}


@end
