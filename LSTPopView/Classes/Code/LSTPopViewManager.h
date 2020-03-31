//
//  LSTPopViewManager.h
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSTPopViewManager : NSObject

+ (instancetype)sharedInstance;

/** 读取popView */
+ (void)getPopViewForKey:(NSString *)key;
/** 保存popView */
+ (void)savePopView:(id)popView forKey:(NSString *)key;
/** 移除popView */
+ (void)removePopViewForKey:(NSString *)key;
/** 移除所有popView */
+ (void)removeAllPopView;

@end

NS_ASSUME_NONNULL_END
