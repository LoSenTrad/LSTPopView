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
@property (nonatomic, assign) CGFloat x;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat y;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat width;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat height;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat centerX;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat centerY;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat top;
/** 获取/设置view的左边坐标 */
@property (nonatomic, assign) CGFloat left;
/** 获取/设置view的底部坐标Y */
@property (nonatomic, assign) CGFloat bottom;
/** 获取/设置view的右边坐标 */
@property (nonatomic, assign) CGFloat right;
/** 获取/设置view的size */
@property (nonatomic, assign) CGSize size;


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
