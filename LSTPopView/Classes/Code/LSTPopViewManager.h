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


@end

NS_ASSUME_NONNULL_END
