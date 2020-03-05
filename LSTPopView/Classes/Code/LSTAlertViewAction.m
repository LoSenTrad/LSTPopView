//
//  LSTAlertViewAction.m
//  LSTAlertView
//
//  Created by LoSenTrad on 2020/1/4.
//

#import "LSTAlertViewAction.h"

@implementation LSTAlertViewAction


- (instancetype)init{
    if (self = [super init]) {
        self.height = LSTActionDefaultHeight;
        self.titleFont = [UIFont systemFontOfSize:17];
        self.titleColor = UIColor.blackColor;
        self.subTitleFont = [UIFont systemFontOfSize:13];
        self.subTitleColor = UIColor.grayColor;
        self.identifier = @"undefined";
    }
    return self;
}

+ (instancetype)initAction {
    return [[self alloc] init];
}

+ (instancetype)initActionWithTitle:(NSString *)title
                           subTitle:(NSString *)subTitle
                         clickBlock:(LSTAlertViewActionClickBlock)clickBlock {
    LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
    action.title = title;
    action.subTitle = subTitle;
    action.clickBlock = clickBlock;
    return action;
}

+ (instancetype)initActionWithTitle:(NSString *)title
                           subTitle:(NSString *)subTitle
                         identifier:(NSString *)identifier
                         clickBlock:(LSTAlertViewActionClickBlock)clickBlock {
    LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
    action.title = title;
    action.subTitle = subTitle;
    action.identifier = identifier.length>0?identifier:@"undefined";
    action.clickBlock = clickBlock;
    return action;
}


+ (instancetype)initActionWithTitle:(NSString *)title
                           subTitle:(NSString *)subTitle
                         identifier:(NSString *)identifier
                       actionHeight:(CGFloat)actionHeight
                         clickBlock:(LSTAlertViewActionClickBlock)clickBlock {
    
    LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
    action.title = title;
    action.subTitle = subTitle;
    action.identifier = identifier.length>0?identifier:@"undefined";
    action.height = actionHeight<0?0:actionHeight;
    action.clickBlock = clickBlock;
    return action;
    
}

#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setTitle:(NSString *)title {
    _title = title;
    
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    
}

- (void)setSubTitleFont:(UIFont *)subTitleFont {
    _subTitleFont = subTitleFont;
    
}

- (void)setSubTitleColor:(UIColor *)subTitleColor {
    _subTitleColor = subTitleColor;
    
}

@end
