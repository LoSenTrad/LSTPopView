//
//  LSTPopView.h
//  LoSenTrad
//
//  Created by LoSenTrad on 2020/2/22.
//

#import <UIKit/UIKit.h>

/**
 显示时动画弹框样式
 */
typedef NS_ENUM(NSInteger, LSTPopStyle) {
    LSTPopStyleNO = 0,               ///< 无动画
    LSTPopStyleScale,                ///< 缩放动画，先放大，后恢复至原大小
    LSTPopStyleShakeFromTop,         ///< 从顶部掉下到中间晃动动画
    LSTPopStyleShakeFromBottom,      ///< 从底部往上到中间晃动动画
    LSTPopStyleShakeFromLeft,        ///< 从左侧往右到中间晃动动画
    LSTPopStyleShakeFromRight,       ///< 从右侧往左到中间晃动动画
    LSTPopStyleCardDropFromLeft,     ///< 卡片从顶部左侧开始掉落动画
    LSTPopStyleCardDropFromRight,    ///< 卡片从顶部右侧开始掉落动画
};

/**
 移除时动画弹框样式
 */
typedef NS_ENUM(NSInteger, LSTDismissStyle) {
    LSTDismissStyleNO = 0,               ///< 无动画
    LSTDismissStyleScale,                ///< 缩放动画
    LSTDismissStyleDropToTop,            ///< 从中间直接掉落到顶部
    LSTDismissStyleDropToBottom,         ///< 从中间直接掉落到底部
    LSTDismissStyleDropToLeft,           ///< 从中间直接掉落到左侧
    LSTDismissStyleDropToRight,          ///< 从中间直接掉落到右侧
    LSTDismissStyleCardDropToLeft,       ///< 卡片从中间往左侧掉落
    LSTDismissStyleCardDropToRight,      ///< 卡片从中间往右侧掉落
    LSTDismissStyleCardDropToTop,        ///< 卡片从中间往顶部移动消失
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

@interface LSTPopView : UIView

/** 显示时点击背景是否移除弹框，默认为NO。 */
@property (nonatomic) BOOL isClickBGDismiss;
/** 显示时是否监听屏幕旋转，默认为NO */
@property (nonatomic) BOOL isObserverOrientationChange;
/** 显示时背景的透明度，取值(0.0~1.0)，默认为0.3 */
@property (nonatomic) CGFloat popBGAlpha;
/// 动画相关属性参数
/** 显示时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic) CGFloat popAnimationDuration;
/** 隐藏时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic) CGFloat dismissAnimationDuration;
/** 显示完成回调 */
@property (nullable, nonatomic, copy) void(^popComplete)(void);
/** 移除完成回调 */
@property (nullable, nonatomic, copy) void(^dismissComplete)(void);
/** 点击背景 */
@property (nullable, nonatomic, copy) void(^bgClickBlock)(void);

/** 弹窗水平方向(X)偏移量校准 */
@property (nonatomic, assign) CGFloat adjustX;
/** 弹窗垂直方向(Y)偏移量校准 */
@property (nonatomic, assign) CGFloat adjustY;
/** 弹框位置 */
@property (nonatomic, assign) LSTHemStyle hemStyle;
/** 显示时动画弹框样式 */
@property (nonatomic) LSTPopStyle animationPopStyle;
/** 移除时动画弹框样式 */
@property (nonatomic) LSTDismissStyle animationDismissStyle;



+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView;
/**
 通过自定义视图来构造弹框视图
 
 @param customView 自定义视图
 */
+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle;
/**
 显示弹框
 */
- (void)pop;
/**
 移除弹框
 */
- (void)dismiss;

@end
