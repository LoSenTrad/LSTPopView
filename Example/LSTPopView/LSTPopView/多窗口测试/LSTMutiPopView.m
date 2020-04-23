//
//  LSTMutiPopView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/3/31.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTMutiPopView.h"

@interface LSTMutiPopView ()

/** <#.....#> */
@property (nonatomic,strong) UIButton *closeBtn;

@end

@implementation LSTMutiPopView

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
    [self addSubview:self.closeBtn];
   
    _closeBtn.frame = CGRectMake(150, 80, 100, 44);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    

    
}

#pragma mark - ***** other 其他 *****

- (void)closeBtnAction:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UIButton *)closeBtn {
    if(_closeBtn) return _closeBtn;
    _closeBtn = [[UIButton alloc] init];
    _closeBtn.backgroundColor = UIColor.orangeColor;
    [_closeBtn setTitle:@"添加窗口" forState:UIControlStateNormal];
    [_closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    return _closeBtn;
}

@end
