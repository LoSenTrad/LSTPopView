//
//  LSTPopViewrRSidebarView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/24.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewrRSidebarView.h"
#import <UIColor+LSTColor.h>
#import <UIView+LSTView.h>

@interface LSTPopViewrRSidebarView ()


/** <#.....#> */
@property (nonatomic,strong) UIButton *btn1;
/** <#.....#> */
@property (nonatomic,strong) UIButton *btn2;
/** <#.....#> */
@property (nonatomic,strong) UIButton *btn3;
/** <#.....#> */
@property (nonatomic,strong) UIButton *btn4;
/** <#.....#> */
@property (nonatomic,strong) UIButton *btn5;
/** <#.....#> */
@property (nonatomic,strong) UIButton *btn6;
@end

@implementation LSTPopViewrRSidebarView


#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

#pragma mark - ***** setter 设置器/数据处理 *****


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.btn1];
    [self addSubview:self.btn2];
    [self addSubview:self.btn3];
    [self addSubview:self.btn4];
    [self addSubview:self.btn5];
    [self addSubview:self.btn6];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.btn1.x = 20;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.btn2.x = 20;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.btn3.x = 20;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.btn4.x = 20;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.btn5.x = 20;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.btn6.x = 20;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

#pragma mark - ***** other 其他 *****


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UIButton *)btn1 {
    if(_btn1) return _btn1;
    _btn1 = [[UIButton alloc] init];
    [_btn1 setTitle:@"我是标题1" forState:UIControlStateNormal];
    [_btn1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn1.backgroundColor = LSTHexColor(@"#2F98F6");
    _btn1.frame = CGRectMake(300, 80, 150, 40);
    _btn1.layer.cornerRadius = 5;
    _btn1.layer.masksToBounds = YES;
    return _btn1;
}
- (UIButton *)btn2 {
    if(_btn2) return _btn2;
    _btn2 = [[UIButton alloc] init];
    [_btn2 setTitle:@"我是标题2" forState:UIControlStateNormal];
    [_btn2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn2.backgroundColor = LSTHexColor(@"#2F98F6");
    _btn2.frame = CGRectMake(300, 160, 150, 40);
    _btn2.layer.cornerRadius = 5;
    _btn2.layer.masksToBounds = YES;
    return _btn2;
}

- (UIButton *)btn3 {
    if(_btn3) return _btn3;
    _btn3 = [[UIButton alloc] init];
    [_btn3 setTitle:@"我是标题3" forState:UIControlStateNormal];
    [_btn3 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn3.backgroundColor = LSTHexColor(@"#2F98F6");
    _btn3.frame = CGRectMake(300, 240, 150, 40);
    _btn3.layer.cornerRadius = 5;
    _btn3.layer.masksToBounds = YES;
    return _btn3;
}

- (UIButton *)btn4 {
    if(_btn4) return _btn4;
    _btn4 = [[UIButton alloc] init];
    [_btn4 setTitle:@"我是标题4" forState:UIControlStateNormal];
    [_btn4 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn4.backgroundColor = LSTHexColor(@"#2F98F6");
    _btn4.frame = CGRectMake(300, 320, 150, 40);
    _btn4.layer.cornerRadius = 5;
    _btn4.layer.masksToBounds = YES;
    return _btn4;
}
- (UIButton *)btn5 {
    if(_btn5) return _btn5;
    _btn5 = [[UIButton alloc] init];
    [_btn5 setTitle:@"我是标题5" forState:UIControlStateNormal];
    [_btn5 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn5.backgroundColor = LSTHexColor(@"#2F98F6");
    _btn5.frame = CGRectMake(300, 400, 150, 40);
    _btn5.layer.cornerRadius = 5;
    _btn5.layer.masksToBounds = YES;
    return _btn5;
}
- (UIButton *)btn6 {
    if(_btn6) return _btn6;
    _btn6 = [[UIButton alloc] init];
    [_btn6 setTitle:@"我是标题6" forState:UIControlStateNormal];
    [_btn6 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn6.backgroundColor = LSTHexColor(@"#2F98F6");
    _btn6.frame = CGRectMake(300, 480, 150, 40);
    _btn6.layer.cornerRadius = 5;
    _btn6.layer.masksToBounds = YES;
    return _btn6;
}


@end
