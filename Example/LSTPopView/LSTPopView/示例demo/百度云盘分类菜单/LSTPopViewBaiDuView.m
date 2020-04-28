//
//  LSTPopViewTranspondView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/24.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewBaiDuView.h"
#import <Masonry.h>

@interface LSTPopViewBaiDuView ()

/** <#.....#> */
@property (nonatomic,strong) UIImageView *imgView;

@end


@implementation LSTPopViewBaiDuView

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
    
    [self addSubview:self.imgView];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
}

#pragma mark - ***** other 其他 *****


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UIImageView *)imgView {
    if(_imgView) return _imgView;
    _imgView = [[UIImageView alloc] init];
    _imgView.image = [UIImage imageNamed:@"baidu"];
    return _imgView;
}


@end
