//
//  LSTPriorityView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/5/22.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPriorityView.h"
#import <Masonry.h>

@implementation LSTPriorityView



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

    self.backgroundColor = UIColor.blueColor;

    [self addSubview:self.titleLab];
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    
}

#pragma mark - ***** other 其他 *****


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UILabel *)titleLab {
    if(_titleLab) return _titleLab;
    _titleLab = [[UILabel alloc] init];
    _titleLab.textColor = UIColor.whiteColor;
    _titleLab.numberOfLines = 0;
    _titleLab.textAlignment = NSTextAlignmentCenter;
    return _titleLab;
}

@end
