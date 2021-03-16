//
//  LSTAlert.h
//  LSTPopView
//
//  Created by Yegq on 2021/3/16.
//

#import <Foundation/Foundation.h>
#import "LSTPopView.h"

NS_ASSUME_NONNULL_BEGIN
@class LSTAlert;

typedef LSTAlert * _Nonnull (^LSTAlert_String)(NSString * string);
typedef LSTAlert * _Nonnull (^LSTAlert_View)(UIView * view);
typedef LSTAlert * _Nonnull (^LSTAlert_CustomView)(Lst_Block_View_Void block);
typedef LSTAlert * _Nonnull (^LSTAlert_Color)(UIColor * color);
typedef LSTAlert * _Nonnull (^LSTAlert_Delegate)(id<LSTPopViewProtocol> delegate);
typedef LSTAlert * _Nonnull (^LSTAlert_HemStyle)(LSTHemStyle style);
typedef LSTAlert * _Nonnull (^LSTAlert_PopStyle)(LSTPopStyle style);
typedef LSTAlert * _Nonnull (^LSTAlert_DismissStyle)(LSTDismissStyle style);
typedef LSTAlert * _Nonnull (^LSTAlert_DragStyle)(LSTDragStyle style);
typedef LSTAlert * _Nonnull (^LSTAlert_SweepStyle)(LSTSweepStyle style);
typedef LSTAlert * _Nonnull (^LSTAlert_SweepDismissStyle)(LSTSweepDismissStyle style);
typedef LSTAlert * _Nonnull (^LSTAlert_Interval)(NSTimeInterval num);
typedef LSTAlert * _Nonnull (^LSTAlert_Float)(CGFloat num);
typedef LSTAlert * _Nonnull (^LSTAlert_BOOL)(BOOL is);
typedef LSTAlert * _Nonnull (^LSTAlert_Corner)(UIRectCorner corner);

typedef LSTAlert * _Nonnull (^LSTAlert_Block_Void)(Lst_Block_Void block);
typedef LSTAlert * _Nonnull (^LSTAlert_Void)(void);
typedef LSTAlert * _Nonnull (^LSTAlert_Block_Point)(Lst_Block_Point block);
typedef LSTAlert * _Nonnull (^LSTAlert_Block_KeyBoardChange)(Lst_Block_KeyBoardChange block);
typedef LSTAlert * _Nonnull (^LSTAlert_Block_AlertCountDown)(Lst_Block_AlertCountDown block);

@interface LSTAlert : NSObject

/// 初始化 alert
+ (instancetype)alert;

#pragma mark - ===================   便利方法   ===================
/// 获取全局(整个app内)所有popView
+ (NSArray <LSTPopView *>*)getAllPopView;
/// 获取当前页面所有popView
+ (NSArray <LSTPopView *>*)getAllPopViewForParentView:(UIView *)parentView;
/// 获取当前页面指定编队的所有popView
+ (NSArray <LSTPopView *>*)getAllPopViewForPopView:(UIView *)popView;

/// 读取popView (有可能会跨编队读取弹窗)
+ (LSTPopView *)getPopViewForKey:(NSString *)key;

/// 移除所有的 popview
+ (void)dismissAllAlert:(Lst_Block_Void)complete;
/// 移除最后添加的 popview
+ (void)dismissAlertComplete:(Lst_Block_Void)complete;
/// 移除指定 LSTAlert 的 popview
+ (void)dismissAlertForAlert:(LSTAlert *)alert complete:(Lst_Block_Void)complete;
/// 移除指定 key 的 popview
+ (void)dismissAlertForKey:(NSString *)key complete:(Lst_Block_Void)complete;
/// 移除指定 popview 的 popview
+ (void)dismissAlertForPopView:(LSTPopView *)popView complete:(Lst_Block_Void)complete;

#pragma mark - ===================   属性设置   ===================
#pragma mark 基础属性
/// 代理 支持多代理
@property (nonatomic , copy , readonly ) LSTAlert_Delegate delegate;
/// 标识 默认为空
@property (nonatomic , copy , readonly ) LSTAlert_String identifier;
/// 弹窗容器
@property (nonatomic , copy , readonly ) LSTAlert_View parentView;
/// 自定义view
@property (nonatomic , copy , readonly ) LSTAlert_CustomView currCustomView;
/// 弹窗位置 默认LSTHemStyleCenter
@property (nonatomic , copy , readonly ) LSTAlert_HemStyle hemStyle;
/// 显示时动画弹窗样式 默认LSTPopStyleFade
@property (nonatomic , copy , readonly ) LSTAlert_PopStyle popStyle;
/// 移除时动画弹窗样式 默认LSTDismissStyleFade
@property (nonatomic , copy , readonly ) LSTAlert_DismissStyle dismissStyle;
/// 显示时动画时长，> 0。不设置则使用默认的动画时长 设置成LSTPopStyleNO, 该属性无效
@property (nonatomic , copy , readonly ) LSTAlert_Interval popDuration;
/// 隐藏时动画时长，>0。不设置则使用默认的动画时长  设置成LSTDismissStyleNO, 该属性无效
@property (nonatomic , copy , readonly ) LSTAlert_Interval dismissDuration;
/// 弹窗水平方向(X)偏移量校准 默认0
@property (nonatomic , copy , readonly ) LSTAlert_Float adjustX;
/// 弹窗垂直方向(Y)偏移量校准 默认0
@property (nonatomic , copy , readonly ) LSTAlert_Float adjustY;
/// 背景颜色 默认rgb(0,0,0) 透明度0.3
@property (nonatomic , copy , readonly ) LSTAlert_Color bgColor;
/// 显示时背景的透明度，取值(0.0~1.0)，默认为0.3
@property (nonatomic , copy , readonly ) LSTAlert_Float bgAlpha;
/// 是否隐藏背景 默认NO
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isHideBg;
/// 显示时点击背景是否移除弹窗，默认为NO。
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isClickBgDismiss;
/// 是否监听屏幕旋转，默认为YES
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isObserverScreenRotation;
/// 是否支持点击回馈 默认NO (暂时关闭)
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isClickFeedback;
/// 是否规避键盘 默认YES
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isAvoidKeyboard;
/// 弹窗和键盘的距离 默认10
@property (nonatomic , copy , readonly ) LSTAlert_Float avoidKeyboardSpace;
/// 显示多长时间 默认0 不会消失
@property (nonatomic , copy , readonly ) LSTAlert_Interval showTime;
/// 自定view圆角方向设置  默认UIRectCornerAllCorners  当cornerRadius>0时生效
@property (nonatomic , copy , readonly ) LSTAlert_Corner rectCorners;
/// 自定义view圆角大小, 默认 0
@property (nonatomic , copy , readonly ) LSTAlert_Float cornerRadius;
/// 弹出震动反馈 默认NO iOS10+ 系统才有此效果
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isImpactFeedback;

#pragma mark 群组相关属性
/// 群组标识 统一给弹窗编队 方便独立管理 默认为nil,统一全局处理
@property (nonatomic , copy , readonly ) LSTAlert_String groupId;
/// 是否堆叠 默认NO  如果是YES  priority优先级不生效
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isStack;
/// 单显示 默认NO  只会显示优先级最高的popView
@property (nonatomic , copy , readonly ) LSTAlert_BOOL isSingle;
/// 优先级 范围0~1000 (默认0,遵循先进先出) isStack和isSingle为NO的时候生效
@property (nonatomic , copy , readonly ) LSTAlert_Float priority;
#pragma mark 拖拽手势相关属性
/// 拖拽方向 默认 不可拖拽
@property (nonatomic , copy , readonly ) LSTAlert_DragStyle dragStyle;
/// X轴或者Y轴拖拽移除临界距离 范围(0 ~ +∞)  默认0 不拖拽移除  基使用于dragStyle
@property (nonatomic , copy , readonly ) LSTAlert_Float dragDistance;
/// 拖拽移除动画类型 默认同dismissStyle
@property (nonatomic , copy , readonly ) LSTAlert_DismissStyle dragDismissStyle;
/// 拖拽消失动画时间 默认同 dismissDuration
@property (nonatomic , copy , readonly ) LSTAlert_Interval dragDismissDuration;
/// 拖拽复原动画时间 默认0.25s
@property (nonatomic , copy , readonly ) LSTAlert_Interval dragReboundTime;
/// 轻扫方向 默认 不可轻扫  前提开启dragStyle
@property (nonatomic , copy , readonly ) LSTAlert_SweepStyle sweepStyle;
/// 轻扫速率 控制轻扫移除 默认1000  基于使用sweepStyle
@property (nonatomic , copy , readonly ) LSTAlert_Float swipeVelocity;
/// 轻扫移除的动画 默认LSTSweepDismissStyleVelocity
@property (nonatomic , copy , readonly ) LSTAlert_SweepDismissStyle sweepDismissStyle;

#pragma mark - ===================   交互回调   ===================
/// 点击背景
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void bgClickBlock;
/// 长按背景
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void bgLongPressBlock;
/// 弹窗pan手势偏移量
@property (nonatomic , copy , readonly ) LSTAlert_Block_Point panOffsetBlock;

#pragma mark - ===================   以下键盘弹出/收起 第三方键盘会多次回调(百度,搜狗测试得出), 原生键盘回调一次   ===================
/// 键盘将要弹出
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void keyboardWillShowBlock;
/// 键盘弹出完毕
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void keyboardDidShowBlock;
/// 键盘frame将要改变
@property (nonatomic , copy , readonly ) LSTAlert_Block_KeyBoardChange keyboardFrameWillChangeBlock;
/// 键盘frame改变完毕
@property (nonatomic , copy , readonly ) LSTAlert_Block_KeyBoardChange keyboardFrameDidChangeBlock;
/// 键盘将要收起
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void keyboardWillHideBlock;
/// 键盘收起完毕
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void keyboardDidHideBlock;

#pragma mark - ===================   生命周期回调(Block)   ===================
/// 将要显示 回调
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void popViewWillPopBlock;
/// 已经显示完毕 回调
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void popViewDidPopBlock;
/// 将要开始移除 回调
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void popViewWillDismissBlock;
/// 已经移除完毕 回调
@property (nonatomic , copy , readonly ) LSTAlert_Block_Void popViewDidDismissBlock;
/// 倒计时 回调
@property (nonatomic , copy , readonly ) LSTAlert_Block_AlertCountDown popViewCountDownBlock;

/// 弹出
@property (nonatomic , copy , readonly ) LSTAlert_Void pop;
/// 小时
@property (nonatomic , copy , readonly ) LSTAlert_Void dismiss;

@property (nonatomic , weak , readonly ) LSTPopView * popView;

@end

NS_ASSUME_NONNULL_END
