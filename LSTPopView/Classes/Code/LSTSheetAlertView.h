//
//  LSTSheetAlertView.h
//  LSTAlertView
//
//  Created by LoSenTrad on 2020/1/10.
//

#import <UIKit/UIKit.h>
#import "LSTAlertViewAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSTSheetAlertView : UIView


/** 标题 */
@property (nonatomic,strong) UILabel *titleLab;
/** 副标题 */
@property (nonatomic,strong) UILabel *subTitleLab;
/** alertView宽度 */
@property (nonatomic, assign) CGFloat alertViewWith;
/** action统一高度 默认50 */
@property (nonatomic, assign) CGFloat actionHeight;


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
