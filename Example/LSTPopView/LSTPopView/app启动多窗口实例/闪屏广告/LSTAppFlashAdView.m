//
//  LSTAppFlashAdView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/12/9.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTAppFlashAdView.h"
#import <UIColor+LSTColor.h>
#import <UIView+LSTView.h>

@implementation LSTAppFlashAdView

#pragma mark - ***** 初始化 *****

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initSubViews];
}

#pragma mark - ***** setter 设置器/数据处理 *****


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    self.timeBtn.backgroundColor = LSTHexColorWithAlpha(@"#000000", 0.5);
    
    self.timeBtn.layer.masksToBounds = YES;
    self.timeBtn.layer.cornerRadius = 15;
    
    if (lst_IsIphoneX_ALL()) {
        self.topH.constant = LSTStatusBarHeight()+10;
    }
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}
- (IBAction)skipBtnAction:(UIButton *)sender {
    
    self.skipBlock? self.skipBlock(nil):nil;
    
}

#pragma mark - ***** other 其他 *****


#pragma mark - ***** Lazy Loading 懒加载 *****


@end
