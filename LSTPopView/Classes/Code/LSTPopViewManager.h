//
//  LSTPopViewManager.h
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class LSTPopView;


static NSString * _Nonnull const LSTPopView_ParentView = @"LSTPopView_ParentView";
static NSString * _Nonnull const LSTPopView_Key = @"LSTPopView_Key";
static NSString * _Nonnull const LSTPopView_PopView = @"LSTPopView_PopView";


typedef void(^LSTPopViewManagerTimerBlock)(NSTimeInterval interval);




NS_ASSUME_NONNULL_BEGIN

@interface LSTPopViewManager : NSObject


/** 单例 */
LSTPopViewManager *LSTPopViewM(void);


/** 保存popView */
+ (void)savePopView:(LSTPopView *)popView;

/** 获取全局(整个app内)所有popView */
+ (NSArray *)getAllPopView;
/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)view;
/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(UIView *)popView;
/**
    读取popView (有可能会跨编队读取弹框)
    建议使用getPopViewForGroupId:forkey: 方法进行精确读取
 */
+ (LSTPopView *)getPopViewForKey:(NSString *)key;



/** 移除popView */
+ (void)removePopView:(LSTPopView *)popView;
/**
   移除popView 通过唯一key (有可能会跨编队误删弹框)
   建议使用removePopViewForGroupId:forkey: 方法进行精确删除
*/
+ (void)removePopViewForKey:(NSString *)key;
/** 移除所有popView */
+ (void)removeAllPopView;


/** 弱化popView 仅供内部调用 */
+ (void)weakWithPopView:(LSTPopView *)popView;




#pragma mark - ***** 计时器相关 *****

@property (nonatomic, strong) NSTimer * _Nullable showTimer;


#pragma mark - ***** 递减计时器 *****

/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForCountdown:(NSTimeInterval)countdown
                       handle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForIdentifier:(NSString *)identifier
                 forCountdown:(NSTimeInterval)countdown
                       handle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForIdentifier:(NSString *)identifier
                 forCountdown:(NSTimeInterval)countdown
                      forUnit:(NSTimeInterval)unit
                       handle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addDiskTimerForIdentifier:(NSString *)identifier
                     forCountdown:(NSTimeInterval)countdown
                          forUnit:(NSTimeInterval)unit
                           handle:(LSTPopViewManagerTimerBlock)handle;


#pragma mark - ***** 递增计时器 *****
/** 添加定时器并开启计时 */
+ (void)addTimerForHandle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier handle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier
                      forUnit:(NSTimeInterval)unit
                       handle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 */
+ (void)addDiskTimerForIdentifier:(NSString *)identifier
                          forUnit:(NSTimeInterval)unit
                           handle:(LSTPopViewManagerTimerBlock)handle;




/** 通过标识获取定时器的 计时间隔 */
+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier;

/** 暂停指定标识的计时器 */
+ (BOOL)pauseTimerForIdentifier:(NSString *)identifier;
/** 暂定所有计时器 */
+ (void)pauseAllTimer;

/** 重启指定标识的计时器 */
+ (BOOL)restartTimerForIdentifier:(NSString *)identifier;
/** 重启所有计时器 */
+ (void)restartAllTimer;

/** 移除指定标识的计时器 */
+ (BOOL)removeTimerForIdentifier:(NSString *)identifier;
/** 移除所有计时器 */
+ (void)removeAllTimer;


@end

NS_ASSUME_NONNULL_END
