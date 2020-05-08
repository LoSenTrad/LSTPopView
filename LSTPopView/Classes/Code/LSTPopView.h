//
//  LSTPopView.h
//  LoSenTrad
//
//  Created by LoSenTrad on 2020/2/22.
//

#import <UIKit/UIKit.h>

#define LSTPopViewWK(object)  __weak typeof(object) wk_##object = object;
#define LSTPopViewSS(object)  __strong typeof(object) object = weak##object;

/** 显示动画样式 */
typedef NS_ENUM(NSInteger, LSTPopStyle) {
    LSTPopStyleNO = 0,                 // 默认 无动画
    LSTPopStyleScale,                  // 缩放 先放大 后恢复至原大小
    LSTPopStyleSmoothFromTop,          // 顶部 平滑淡入动画
    LSTPopStyleSmoothFromLeft,         // 左侧 平滑淡入动画
    LSTPopStyleSmoothFromBottom,       // 底部 平滑淡入动画
    LSTPopStyleSmoothFromRight,        // 右侧 平滑淡入动画
    LSTPopStyleSpringFromTop,          // 顶部 平滑淡入动画 带弹簧
    LSTPopStyleSpringFromLeft,         // 左侧 平滑淡入动画 带弹簧
    LSTPopStyleSpringFromBottom,       // 底部 平滑淡入动画 带弹簧
    LSTPopStyleSpringFromRight,        // 右侧 平滑淡入动画 带弹簧
    LSTPopStyleCardDropFromLeft,       // 顶部左侧 掉落动画
    LSTPopStyleCardDropFromRight,      // 顶部右侧 掉落动画
};
/** 消失动画样式 */
typedef NS_ENUM(NSInteger, LSTDismissStyle) {
    LSTDismissStyleNO = 0,               // 默认 无动画
    LSTDismissStyleScale,                // 缩放
    LSTDismissStyleSmoothToTop,          // 顶部 平滑淡出动画
    LSTDismissStyleSmoothToLeft,         // 左侧 平滑淡出动画
    LSTDismissStyleSmoothToBottom,       // 底部 平滑淡出动画
    LSTDismissStyleSmoothToRight,        // 右侧 平滑淡出动画
    LSTDismissStyleCardDropToLeft,       // 卡片从中间往左侧掉落
    LSTDismissStyleCardDropToRight,      // 卡片从中间往右侧掉落
    LSTDismissStyleCardDropToTop,        // 卡片从中间往顶部移动消失
};
/** 主动动画样式(开发中) */
typedef NS_ENUM(NSInteger, LSTActivityStyle) {
    LSTActivityStyleNO = 0,               /// 无动画
    LSTActivityStyleScale,                /// 缩放
    LSTActivityStyleShake,                /// 抖动
};
/**弹框位置 */
typedef NS_ENUM(NSInteger, LSTHemStyle) {
    LSTHemStyleCenter = 0,
    LSTHemStyleTop,    //贴顶
    LSTHemStyleLeft,   //贴左
    LSTHemStyleBottom, //贴底
    LSTHemStyleRight,  //贴右
};

@protocol LSTPopViewDelegate <NSObject>



/** 点击弹框 回调 */
- (void)lst_PopViewBgClick;
/** 长按弹框 回调 */
- (void)lst_PopViewBgLongPress;


// ****** 生命周期 ******
/** 将要显示 */
- (void)lst_PopViewWillPop;
/** 已经显示完毕 */
- (void)lst_PopViewDidPop;
/** 将要开始移除 */
- (void)lst_PopViewWillDismiss;
/** 已经移除完毕 */
- (void)lst_PopViewDidDismiss;
//***********************

@end

@interface LSTPopView : UIView

/** 代理 */
@property (nonatomic, weak) id<LSTPopViewDelegate> _Nullable delegate;

/** 显示时点击背景是否移除弹框，默认为NO。 */
@property (nonatomic, assign) BOOL isClickBgDismiss;
/** 显示时是否监听屏幕旋转，默认为NO (开发中) */
@property (nonatomic, assign) BOOL isObserverOrientationChange;
/** 显示时背景的透明度，取值(0.0~1.0)，默认为0.3 */
@property (nonatomic, assign) CGFloat bgAlpha;
/** 是否隐藏背景 默认NO */
@property (nonatomic, assign) BOOL isHideBg;
/** 背景颜色 默认rgb(0,0,0) 透明度0.3 */
@property (nonatomic,strong) UIColor * _Nullable bgColor;
/** 显示时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic, assign) NSTimeInterval popDuration;
/** 隐藏时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic, assign) NSTimeInterval dismissDuration;
/** 弹窗水平方向(X)偏移量校准 */
@property (nonatomic, assign) CGFloat adjustX;
/** 弹窗垂直方向(Y)偏移量校准 */
@property (nonatomic, assign) CGFloat adjustY;
/** 弹框位置 */
@property (nonatomic, assign) LSTHemStyle hemStyle;
/** 显示时动画弹框样式 */
@property (nonatomic) LSTPopStyle popStyle;
/** 移除时动画弹框样式 */
@property (nonatomic) LSTDismissStyle dismissStyle;
///** 单击反馈动画 */
//@property (nonatomic, assign) LSTActivityStyle clickStyle;
/** 是否开启长按反馈动画 默认YES */
//@property (nonatomic, assign) BOOL isLongPressAnimation;
/** 是否支持点击回馈 默认NO (暂时关闭) */
@property (nonatomic, assign) BOOL isClickFeedback;
/** 是否规避键盘 默认YES */
@property (nonatomic, assign) BOOL isAvoidKeyboard;
/** 弹框和键盘的距离 默认10 */
@property (nonatomic, assign) CGFloat avoidKeyboardSpace;
/** 标识 */
@property (nonatomic,copy) NSString *_Nullable identifier;
/**
  群组标识 统一给弹框编队 方便独立管理
  默认为nil,统一全局处理
 */
@property (nonatomic,strong) NSString * _Nullable groupId;
/** 是否遵从多窗口管理 默认YES */
@property (nonatomic, assign) BOOL isPopViewManage;
/** 是否遵从多窗口堆叠单显 默认NO */
@property (nonatomic, assign) BOOL isStackSingleShow;
/** 优先级 范围0~1000 (默认0,遵循先进先出) */
@property (nonatomic, assign) CGFloat priority;
/** 显示多长时间 默认0 不会消失 */
@property (nonatomic, assign) NSTimeInterval showTime;

/** 点击背景 */
@property (nullable, nonatomic, copy) void(^bgClickBlock)(void);
/** 长按背景 */
@property (nullable, nonatomic, copy) void(^bgLongPressBlock)(void);



//************ 生命周期回调(Block) ************
/** 将要显示 回调 */
@property (nullable, nonatomic, copy) void(^popViewWillPop)(void);
/** 已经显示完毕 回调 */
@property (nullable, nonatomic, copy) void(^popViewDidPop)(void);
/** 将要开始移除 回调 */
@property (nullable, nonatomic, copy) void(^popViewWillDismiss)(void);
/** 已经移除完毕 回调 */
@property (nullable, nonatomic, copy) void(^popViewDidDismiss)(void);
//********************************************


+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView;
/**
  通过自定义视图来构造弹框视图
  @param customView 自定义视图
 */
+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle;
/**
  通过自定义视图来构造弹框视图
  @param customView 自定义视图
 */
+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                 parentView:(UIView *_Nullable)parentView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle;
/** 显示popView */
- (void)pop;
/// 打开popView 带动画
/// @param popStyle 优先级高于popStyle 局部起作用
- (void)popWithPopStyle:(LSTPopStyle)popStyle;
/// 打开popView 带动画
/// @param popStyle 优先级高于popStyle 局部起作用
/// @param duration 优先级高于popDuration 局部起作用
- (void)popWithPopStyle:(LSTPopStyle)popStyle duration:(NSTimeInterval)duration;


/** 关闭popView 带动画 */
- (void)dismiss;
/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle;
/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
/// @param duration 优先级高于dismissDuration 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle duration:(NSTimeInterval)duration;



@end
