//
//  LSTAlertViewAction.h
//  LSTAlertView
//
//  Created by LoSenTrad on 2020/1/4.
//

#import <Foundation/Foundation.h>
@class LSTAlertViewAction;


static CGFloat const LSTActionDefaultHeight = 50.0f;

NS_ASSUME_NONNULL_BEGIN

typedef void(^LSTAlertViewActionClickBlock)(LSTAlertViewAction *action,NSUInteger index);

@interface LSTAlertViewAction : NSObject

/** 标题 */
@property (nonatomic,copy) NSString *title;
/** 标题颜色 */
@property (nonatomic,strong) UIColor *titleColor;
/** 标题字号 */
@property (nonatomic,strong) UIFont *titleFont;
/** 副标题 */
@property (nonatomic,copy) NSString *subTitle;
/** 副标题颜色 */
@property (nonatomic,strong) UIColor *subTitleColor;
/** 副标题字号 */
@property (nonatomic,strong) UIFont *subTitleFont;
/** 标识 */
@property (nonatomic,strong) NSString *identifier;
/** action高度 */
@property (nonatomic,assign) CGFloat height;
/** 自定义actionView */
@property (nonatomic,strong) UIView *actionView;
/** <#...#> */
@property (nonatomic, copy) LSTAlertViewActionClickBlock clickBlock;




/** 禁止调用new方法 统一实例化 */
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)initAction;

+ (instancetype)initActionWithTitle:(NSString *)title
                           subTitle:(NSString *)subTitle
                         clickBlock:(LSTAlertViewActionClickBlock)clickBlock;

+ (instancetype)initActionWithTitle:(NSString *)title
                           subTitle:(NSString *)subTitle
                         identifier:(NSString *)identifier
                         clickBlock:(LSTAlertViewActionClickBlock)clickBlock;

+ (instancetype)initActionWithTitle:(NSString *)title
                           subTitle:(NSString *)subTitle
                         identifier:(NSString *)identifier
                       actionHeight:(CGFloat)actionHeight
                         clickBlock:(LSTAlertViewActionClickBlock)clickBlock;



@end

NS_ASSUME_NONNULL_END
