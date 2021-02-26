//
//  LSTPopViewProtocol.h
//  LSTCategory
//
//  Created by LoSenTrad on 2020/5/30.
//

#import <Foundation/Foundation.h>
@class LSTPopView;


#ifdef DEBUG
#define LSTPVLog(format, ...) printf("class: <%p %s:(第%d行) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define LSTPVLog(format, ...)
#endif

/** 调试日志类型 */
typedef NS_ENUM(NSInteger, LSTPopViewLogStyle) {
    LSTPopViewLogStyleNO = 0,          // 关闭调试信息(窗口和控制台日志输出)
    LSTPopViewLogStyleWindow,          // 开启左上角小窗
    LSTPopViewLogStyleConsole,         // 开启控制台日志输出
    LSTPopViewLogStyleALL              // 开启小窗和控制台日志
};

/** 显示动画样式 */
typedef NS_ENUM(NSInteger, LSTPopStyle) {
    LSTPopStyleFade = 0,               // 默认 渐变出现
    LSTPopStyleNO,                     // 无动画
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
    LSTDismissStyleFade = 0,             // 默认 渐变消失
    LSTDismissStyleNO,                   // 无动画
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
/** 弹窗位置 */
typedef NS_ENUM(NSInteger, LSTHemStyle) {
    LSTHemStyleCenter = 0,   //居中
    LSTHemStyleTop,          //贴顶
    LSTHemStyleLeft,         //贴左
    LSTHemStyleBottom,       //贴底
    LSTHemStyleRight,        //贴右
    LSTHemStyleTopLeft,      //贴顶和左
    LSTHemStyleBottomLeft,   //贴底和左
    LSTHemStyleBottomRight,  //贴底和右
    LSTHemStyleTopRight      //贴顶和右
};
/** 拖拽方向 */
typedef NS_ENUM(NSInteger, LSTDragStyle) {
    LSTDragStyleNO = 0,  //默认 不能拖拽窗口
    LSTDragStyleX_Positive = 1<<0,   //X轴正方向拖拽
    LSTDragStyleX_Negative = 1<<1,   //X轴负方向拖拽
    LSTDragStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    LSTDragStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    LSTDragStyleX = (LSTDragStyleX_Positive|LSTDragStyleX_Negative),   //X轴方向拖拽
    LSTDragStyleY = (LSTDragStyleY_Positive|LSTDragStyleY_Negative),   //Y轴方向拖拽
    LSTDragStyleAll = (LSTDragStyleX|LSTDragStyleY)   //全向拖拽
};
///** 可轻扫消失的方向 */
typedef NS_ENUM(NSInteger, LSTSweepStyle) {
    LSTSweepStyleNO = 0,  //默认 不能拖拽窗口
    LSTSweepStyleX_Positive = 1<<0,   //X轴正方向拖拽
    LSTSweepStyleX_Negative = 1<<1,   //X轴负方向拖拽
    LSTSweepStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    LSTSweepStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    LSTSweepStyleX = (LSTSweepStyleX_Positive|LSTSweepStyleX_Negative),   //X轴方向拖拽
    LSTSweepStyleY = (LSTSweepStyleY_Positive|LSTSweepStyleY_Negative),   //Y轴方向拖拽
    LSTSweepStyleALL = (LSTSweepStyleX|LSTSweepStyleY)   //全向轻扫
};

/**
   可轻扫消失动画类型 对单向横扫 设置有效
   LSTSweepDismissStyleSmooth: 自动适应选择以下其一
   LSTDismissStyleSmoothToTop,
   LSTDismissStyleSmoothToLeft,
   LSTDismissStyleSmoothToBottom ,
   LSTDismissStyleSmoothToRight
 */
typedef NS_ENUM(NSInteger, LSTSweepDismissStyle) {
    LSTSweepDismissStyleVelocity = 0,  //默认加速度 移除
    LSTSweepDismissStyleSmooth = 1     //平顺移除
};


NS_ASSUME_NONNULL_BEGIN

@protocol LSTPopViewProtocol <NSObject>


/** 点击弹窗 回调 */
- (void)lst_PopViewBgClickForPopView:(LSTPopView *)popView;
/** 长按弹窗 回调 */
- (void)lst_PopViewBgLongPressForPopView:(LSTPopView *)popView;




// ****** 生命周期 ******
/** 将要显示 */
- (void)lst_PopViewWillPopForPopView:(LSTPopView *)popView;
/** 已经显示完毕 */
- (void)lst_PopViewDidPopForPopView:(LSTPopView *)popView;
/** 倒计时进行中 timeInterval:时长  */
- (void)lst_PopViewCountDownForPopView:(LSTPopView *)popView forCountDown:(NSTimeInterval)timeInterval;
/** 倒计时倒计时完成  */
- (void)lst_PopViewCountDownFinishForPopView:(LSTPopView *)popView;
/** 将要开始移除 */
- (void)lst_PopViewWillDismissForPopView:(LSTPopView *)popView;
/** 已经移除完毕 */
- (void)lst_PopViewDidDismissForPopView:(LSTPopView *)popView;
//***********************




@end

NS_ASSUME_NONNULL_END
