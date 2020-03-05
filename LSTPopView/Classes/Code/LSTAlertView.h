//
//  LSTAlertView.h
//  LSTAlertView
//
//  Created by LoSenTrad on 2020/1/4.
//

#import <UIKit/UIKit.h>
#import "LSTPopView.h"
#import "LSTAlertViewAction.h"

NS_ASSUME_NONNULL_BEGIN


//typedef void(^LSTAlertViewClickBlock)(NSUInteger index,NSString *title,LSTAlertViewAction *action);
typedef void(^LSTAlertViewBgClickBlock)(void);



@interface LSTAlertView : UIView

/** 标题 */
@property (nonatomic,strong) UILabel *titleLab;
/** 副标题 */
@property (nonatomic,strong) UILabel *subTitleLab;

@property (nonatomic,assign) NSTimeInterval *showAnimateDuration;
@property (nonatomic,assign) NSTimeInterval *closeAnimateDuration;
/** alertView宽度 */
@property (nonatomic, assign) CGFloat alertViewWith;
/** action统一高度 默认50 */
@property (nonatomic, assign) CGFloat actionHeight;
/** <#...#> */
@property (nonatomic, copy) LSTAlertViewBgClickBlock bgClickBlock;
/** 弹框位置 */
@property (nonatomic, assign) LSTHemStyle hemStyle;
/** 背景颜色 默认白色 */
@property (nonatomic,strong) UIColor *bgColor;
/** 圆角 默认10 */
@property (nonatomic,assign) CGFloat cornerRadius;
/** 分割线颜色 默认是 */
@property (nonatomic,strong) UIColor *separatorColor;
/** 分割线高度 */
@property (nonatomic, assign) CGFloat separatorHeight;


/** 禁止调用new方法 统一实例化 */
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)initAlertView;

+ (instancetype)initAlertViewWithActions:(NSArray <LSTAlertViewAction *> *)actions;

- (void)addAction:(LSTAlertViewAction *)action;

- (void)deleteActionForIdentifier:(NSString *)identifier;
- (void)deleteActionForAction:(LSTAlertViewAction *)action;
- (void)deleteActionForActions:(NSArray<LSTAlertViewAction *> *)actions;


- (void)deleteActionForIndex:(NSUInteger)index;

- (void)reload;

- (void)show;



+ (instancetype)showWithTitle:(NSString *)title
                 actionTitles:(NSArray<NSString *> *)actionTitles
                   ClickBlock:(LSTAlertViewActionClickBlock)clickBlock;

+ (instancetype)showWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                 actionTitles:(NSArray<NSString *> *)actionTitles
              actionSubTitles:(NSArray<NSString *> *)actionSubTitles
                   ClickBlock:(LSTAlertViewActionClickBlock)clickBlock;



- (void)close;

@end

NS_ASSUME_NONNULL_END
