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

@interface LSTPopViewManager : NSObject



LSTPopViewManager *LSTPopViewM(void);

//+ (instancetype)sharedInstance;

/** 获取所有popView */
+ (NSArray *)getAllPopView;
/** 获取所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)view;
/** 读取popView */
+ (LSTPopView *)getPopViewForKey:(NSString *)key;
/** 保存popView */
+ (void)savePopView:(LSTPopView *)popView
      forParentView:(UIView *)parentView
             forKey:(NSString *)key;
/** 移除popView */
+ (void)removePopView:(LSTPopView *)popView;
/** 移除popView 通过唯一key */
+ (void)removePopViewForKey:(NSString *)key;
/** 移除所有popView */
+ (void)removeAllPopView;

@end

NS_ASSUME_NONNULL_END
