//
//  LSTPopView.h
//  LoSenTrad
//
//  Created by LoSenTrad on 2020/2/22.
//

#import <UIKit/UIKit.h>

#define LSTPopViewWK(object)  __weak typeof(object) wk_##object = object;
#define LSTPopViewSS(object)  __strong typeof(object) object = weak##object;
/**
 显示时动画弹框样式LSTPVPopStyle
 */
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
/**
 移除时动画弹框样式
 */
typedef NS_ENUM(NSInteger, LSTDismissStyle) {
    LSTDismissStyleNO = 0,               // 无动画
    LSTDismissStyleScale,                // 缩放动画
    LSTDismissStyleDropToTop,            // 掉落到 顶部
    LSTDismissStyleDropToBottom,         // 掉落到 底部
    LSTDismissStyleDropToLeft,           // 掉落到 左侧
    LSTDismissStyleDropToRight,          // 掉落到 右侧
    LSTDismissStyleCardDropToLeft,       // 卡片从中间往左侧掉落
    LSTDismissStyleCardDropToRight,      // 卡片从中间往右侧掉落
    LSTDismissStyleCardDropToTop,        // 卡片从中间往顶部移动消失
};
/**
   主动动画样式
 */
typedef NS_ENUM(NSInteger, LSTActivityStyle) {
    LSTActivityStyleNO = 0,               /// 无动画
    LSTActivityStyleScale,                /// 缩放
    LSTActivityStyleShake,                /// 抖动
};
/**
 弹框位置
 */
typedef NS_ENUM(NSInteger, LSTHemStyle) {
    LSTHemStyleCenter = 0,
    LSTHemStyleTop,
    LSTHemStyleLeft,
    LSTHemStyleBottom,
    LSTHemStyleRight,
};

@protocol LSTPopViewDelegate <NSObject>


//************ 生命周期回调(Block) ************

/** 将要显示 */
- (void)lst_PopViewWillPop;
/** 已经显示完毕 */
- (void)lst_PopViewPopFinish;
/** 将要开始移除 */
- (void)lst_PopViewWillDismiss;
/** 已经移除完毕 */
- (void)lst_PopViewDismissFinish;


//********************************************


@end

@interface LSTPopView : UIView

/** 代理 */
@property (nonatomic,weak) id<LSTPopViewDelegate> _Nullable delegate;

/** 显示时点击背景是否移除弹框，默认为NO。 */
@property (nonatomic) BOOL isClickBGDismiss;
/** 显示时是否监听屏幕旋转，默认为NO */
@property (nonatomic) BOOL isObserverOrientationChange;
/** 显示时背景的透明度，取值(0.0~1.0)，默认为0.3 */
@property (nonatomic) CGFloat popBGAlpha;
/// 动画相关属性参数
/** 显示时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic) CGFloat popDuration;
/** 隐藏时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic) CGFloat dismissDuration;
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

/** 点击背景 */
@property (nullable, nonatomic, copy) void(^bgClickBlock)(void);

//************ 生命周期回调(Block) ************
/** 显示完成回调 */
@property (nullable, nonatomic, copy) void(^popComplete)(void);
/** 移除完成回调 */
@property (nullable, nonatomic, copy) void(^dismissComplete)(void);
//********************************************



+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView;
/**
 通过自定义视图来构造弹框视图
 
 @param customView 自定义视图
 */
+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
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
- (void)popWithPopStyle:(LSTPopStyle)popStyle duration:(CGFloat)duration;

/** 关闭popView 带动画 */
- (void)dismiss;

/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle;
/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
/// @param duration 优先级高于dismissDuration 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle duration:(CGFloat)duration;

@end
