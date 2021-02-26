//
//  LSTPopViewHeightChangeView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2021/2/26.
//  Copyright © 2021 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewHeightChangeView.h"
#import <LSTGestureEvents.h>
#import <UIView+LSTView.h>

@interface LSTPopViewHeightChangeView ()

@property (weak, nonatomic) IBOutlet UIView *fileView;
/**  */
@property (nonatomic, assign) BOOL isOpen;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;


@end

@implementation LSTPopViewHeightChangeView

#pragma mark - ***** 初始化 *****

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initSubViews];
}

#pragma mark - ***** setter 设置器/数据处理 *****


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self.fileView addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        if (self.isOpen) {
            self.height = 170;
            self.isOpen = NO;
            self.imgView.image = [UIImage imageNamed:@"nav_right"];

        }else {
            self.height = 170+120;
            self.isOpen = YES;
            self.imgView.image = [UIImage imageNamed:@"nav_down"];
        }
    }];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

#pragma mark - ***** other 其他 *****


#pragma mark - ***** Lazy Loading 懒加载 *****

@end
