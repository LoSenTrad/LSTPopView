//
//  LSTPopViewCodeView.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/2/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewCodeView.h"
#import <Masonry.h>


@interface LSTPopViewCodeView ()

/** <#.....#> */
@property (nonatomic,strong) UIButton *closeBtn;
/** <#.....#> */
@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation LSTPopViewCodeView

#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

#pragma mark - ***** setter 设置器/数据处理 *****
- (void)dealloc {
    
}


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self addSubview:self.imgView];
    [self.imgView addSubview:self.closeBtn];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.top.equalTo(self.imgView).offset(8);
        make.right.equalTo(self.imgView).offset(-8);

    }];
    
    
}

#pragma mark - ***** other 其他 *****

- (void)closeBtnAction {
    if (self.closeBlock) {
        self.closeBlock();
    }
    
}

#pragma mark - ***** Lazy Loading 懒加载 *****

- (UIImageView *)imgView {
    if(_imgView) return _imgView;
    _imgView = [[UIImageView alloc] init];
    _imgView.image = [UIImage imageNamed:@"1234"];
    _imgView.backgroundColor = UIColor.clearColor;
    _imgView.userInteractionEnabled = YES;
    return _imgView;
}

- (UIButton *)closeBtn {
    if(_closeBtn) return _closeBtn;
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    return _closeBtn;
}


@end
