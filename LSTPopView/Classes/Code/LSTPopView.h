//
//  LSTPopView.h
//  LoSenTrad
//
//  Created by LoSenTrad on 2020/2/22.
//

/** 博客地址 如果觉得好用 伸出你的小指头 点Star 点赞 点收藏! 就是给予我最大的支持!
    github: https://github.com/LoSenTrad/LSTPopView
    简书: https://www.jianshu.com/p/8023a85dc2a2
 */

#import <UIKit/UIKit.h>
#import "LSTPopViewProtocol.h"


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


NS_ASSUME_NONNULL_BEGIN

@interface LSTPopView : UIView

/** 代理 支持多代理 */
@property (nonatomic, weak) id<LSTPopViewProtocol> _Nullable delegate;
/** 标识 默认为空 */
@property (nonatomic,copy) NSString *_Nullable identifier;
/** 弹框容器 默认是app UIWindow 可指定view作为容器 */
@property (nonatomic,weak) UIView * _Nullable parentView;
/** 弹框位置 默认LSTHemStyleCenter */
@property (nonatomic, assign) LSTHemStyle hemStyle;
/** 显示时动画弹框样式 默认LSTPopStyleNO */
@property (nonatomic) LSTPopStyle popStyle;
/** 移除时动画弹框样式 默认LSTDismissStyleNO */
@property (nonatomic) LSTDismissStyle dismissStyle;
/** 显示时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic, assign) NSTimeInterval popDuration;
/** 隐藏时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic, assign) NSTimeInterval dismissDuration;
/** 弹窗水平方向(X)偏移量校准 默认0 */
@property (nonatomic, assign) CGFloat adjustX;
/** 弹窗垂直方向(Y)偏移量校准 默认0 */
@property (nonatomic, assign) CGFloat adjustY;
/** 背景颜色 默认rgb(0,0,0) 透明度0.3 */
@property (nonatomic,strong) UIColor * _Nullable bgColor;
/** 显示时背景的透明度，取值(0.0~1.0)，默认为0.3 */
@property (nonatomic, assign) CGFloat bgAlpha;
/** 是否隐藏背景 默认NO */
@property (nonatomic, assign) BOOL isHideBg;
/** 显示时点击背景是否移除弹框，默认为NO。 */
@property (nonatomic, assign) BOOL isClickBgDismiss;
/** 是否监听屏幕旋转，默认为YES */
@property (nonatomic, assign) BOOL isObserverScreenRotation;
/** 是否支持点击回馈 默认NO (暂时关闭) */
@property (nonatomic, assign) BOOL isClickFeedback;
/** 是否规避键盘 默认YES */
@property (nonatomic, assign) BOOL isAvoidKeyboard;
/** 弹框和键盘的距离 默认10 */
@property (nonatomic, assign) CGFloat avoidKeyboardSpace;
/** 显示多长时间 默认0 不会消失 */
@property (nonatomic, assign) NSTimeInterval showTime;

//************ 群组相关属性 ****************
/** 群组标识 统一给弹框编队 方便独立管理 默认为nil,统一全局处理 */
@property (nonatomic,strong) NSString * _Nullable groupId;
/** 是否堆叠 默认NO  如果是YES  priority优先级不生效*/
@property (nonatomic,assign) BOOL isStack;
/** 单显示 默认NO  只会显示优先级最高的popView   */
@property (nonatomic, assign) BOOL isSingle;
/** 优先级 范围0~1000 (默认0,遵循先进先出) isStack和isSingle为NO的时候生效 */
@property (nonatomic, assign) CGFloat priority;
//****************************************

/** 点击背景 */
@property (nullable, nonatomic, copy) void(^bgClickBlock)(void);
/** 长按背景 */
@property (nullable, nonatomic, copy) void(^bgLongPressBlock)(void);

//以下键盘弹出/收起 第三方键盘会多次回调(百度,搜狗测试得出), 原生键盘回调一次

/** 键盘将要弹出 */
@property (nullable, nonatomic, copy) void(^keyboardWillShowBlock)(void);
/** 键盘弹出完毕 */
@property (nullable, nonatomic, copy) void(^keyboardDidShowBlock)(void);
/** 键盘frame将要改变 */
@property (nullable, nonatomic, copy) void(^keyboardFrameWillChangeBlock)(CGRect beginFrame,CGRect endFrame,CGFloat duration);
/** 键盘frame改变完毕 */
@property (nullable, nonatomic, copy) void(^keyboardFrameDidChangeBlock)(CGRect beginFrame,CGRect endFrame,CGFloat duration);
/** 键盘将要收起 */
@property (nullable, nonatomic, copy) void(^keyboardWillHideBlock)(void);
/** 键盘收起完毕 */
@property (nullable, nonatomic, copy) void(^keyboardDidHideBlock)(void);

//************ 生命周期回调(Block) ************
/** 将要显示 回调 */
@property (nullable, nonatomic, copy) void(^popViewWillPopBlock)(void);
/** 已经显示完毕 回调 */
@property (nullable, nonatomic, copy) void(^popViewDidPopBlock)(void);
/** 将要开始移除 回调 */
@property (nullable, nonatomic, copy) void(^popViewWillDismissBlock)(void);
/** 已经移除完毕 回调 */
@property (nullable, nonatomic, copy) void(^popViewDidDismissBlock)(void);
/** 倒计时 回调 */
@property (nullable, nonatomic, copy) void(^popViewCountDownBlock)(LSTPopView *popView,NSTimeInterval timeInterval);
//********************************************


/*
   以下是构建方法
   customView: 已定义view
   popStyle: 弹出动画
   dismissStyle: 移除动画
   parentView: 弹框父容器
 */
+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView;

+ (nullable instancetype)initWithCustomView:(UIView *)customView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle;

+ (nullable instancetype)initWithCustomView:(UIView *)customView
                                 parentView:(UIView *_Nullable)parentView
                                   popStyle:(LSTPopStyle)popStyle


                               dismissStyle:(LSTDismissStyle)dismissStyle;
/*
  以下是弹出方法
  popStyle: 弹出动画 优先级大于全局的popStyle 局部起作用
  duration: 弹出时间 优先级大于全局的popDuration 局部起作用
*/
- (void)pop;
- (void)popWithStyle:(LSTPopStyle)popStyle;
- (void)popWithDuration:(NSTimeInterval)duration;
- (void)popWithStyle:(LSTPopStyle)popStyle duration:(NSTimeInterval)duration;


/*
  以下是弹出方法
  dismissStyle: 弹出动画 优先级大于全局的dismissStyle 局部起作用
  duration: 弹出时间 优先级大于全局的dismissDuration 局部起作用
*/
- (void)dismiss;
- (void)dismissWithStyle:(LSTDismissStyle)dismissStyle;
- (void)dismissWithDuration:(NSTimeInterval)duration;
- (void)dismissWithStyle:(LSTDismissStyle)dismissStyle duration:(NSTimeInterval)duration;


/** 删除指定代理 */
- (void)removeForDelegate:(id<LSTPopViewProtocol>)delegate;
/** 删除代理池 删除所有代理 */
- (void)removeAllDelegate;

@end


NS_ASSUME_NONNULL_END
