//
//  LSTPopViewManager.h
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class LSTPopView;






static NSString *const LSTPopView_ParentView = @"LSTPopView_ParentView";
static NSString *const LSTPopView_Key = @"LSTPopView_Key";
static NSString *const LSTPopView_PopView = @"LSTPopView_PopView";

NS_ASSUME_NONNULL_BEGIN


typedef void(^LSTPopViewManagerTimerBlock)(NSTimeInterval interval);


@interface LSTPopViewManager : NSObject



LSTPopViewManager *LSTPopViewM(void);

//+ (instancetype)sharedInstance;



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
/** 读取popView */
+ (LSTPopView *)getPopViewForGroupId:(NSString *)groupId forKey:(NSString *)key;



/** 移除popView */
+ (void)removePopView:(LSTPopView *)popView;
/**
   移除popView 通过唯一key (有可能会跨编队误删弹框)
   建议使用removePopViewForGroupId:forkey: 方法进行精确删除
*/
+ (void)removePopViewForKey:(NSString *)key;
/** 精确删除弹框 通过编队id和弹框标识 */
+ (void)removePopViewForGroupId:(NSString *)groupId forKey:(NSString *)key;
/** 移除所有popView */
+ (void)removeAllPopView;


/** 出栈 仅供内部调用  */
+ (void)popStackForPopView:(LSTPopView *)popView;
/** 入栈 仅供内部调用  */
+ (void)intoStackForPopView:(LSTPopView *)popView;




#pragma mark - ***** 计时器相关 *****

@property (nonatomic, strong) NSTimer *showTimer;


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
                  forIncrease:(NSTimeInterval)increase
                       handle:(LSTPopViewManagerTimerBlock)handle;

/** 添加定时器并开启计时 */
+ (void)addTimerForHandle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier handle:(LSTPopViewManagerTimerBlock)handle;
/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier
                  forIncrease:(NSTimeInterval)increase
                       handle:(LSTPopViewManagerTimerBlock)handle;


+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier;


+ (void)pauseTimerForIdentifier:(NSString *)identifier;
+ (void)pauseAllTimer;

+ (void)removeTimerForIdentifier:(NSString *)identifier;
+ (void)removeAllTimer;


@end

NS_ASSUME_NONNULL_END
