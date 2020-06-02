//
//  LSTModel.h
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/5/14.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^LSTModelBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface LSTModel : NSObject

@property (nonatomic, assign) NSTimeInterval timeInterval;
/** 定时器执行block */
@property (nonatomic, copy) LSTModelBlock handleBlock;
/** 每次计时单位增量 */
@property (nonatomic, assign) NSTimeInterval unit;
/** 是否递增 YES:递增 NO:递减 */
@property (nonatomic, assign) BOOL increase;
/** 是否本地持久化保存定时数据 */
@property (nonatomic,assign) BOOL isDisk;
/** 是否暂停 */
@property (nonatomic,assign) BOOL isPause;
/** 标识 */
@property (nonatomic, copy) NSString *identifier;

@end

NS_ASSUME_NONNULL_END
