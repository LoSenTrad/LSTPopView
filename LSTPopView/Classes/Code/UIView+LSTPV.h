//
//  UIView+LSTPV.h
//  LSTPopView
//
//  Created by LoSenTrad on 2020/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LSTPV)

/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_X;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Y;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Width;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Height;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_CenterX;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_CenterY;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Top;
/** 获取/设置view的左边坐标 */
@property (nonatomic, assign) CGFloat pv_Left;
/** 获取/设置view的底部坐标Y */
@property (nonatomic, assign) CGFloat pv_Bottom;
/** 获取/设置view的右边坐标 */
@property (nonatomic, assign) CGFloat pv_Right;
/** 获取/设置view的size */
@property (nonatomic, assign) CGSize pv_Size;


/** 是否是苹果X系列(刘海屏系列) */
BOOL pv_IsIphoneX_ALL(void);
/** 屏幕大小 */
CGSize pv_ScreenSize(void);
/** 屏幕宽度 */
CGFloat pv_ScreenWidth(void);
/** 屏幕高度 */
CGFloat pv_ScreenHeight(void);

@end

NS_ASSUME_NONNULL_END
