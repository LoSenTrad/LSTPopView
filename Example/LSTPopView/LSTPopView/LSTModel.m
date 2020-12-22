//
//  LSTModel.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/5/14.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTModel.h"

@implementation LSTModel

//@property (nonatomic, assign) NSTimeInterval timeInterval;
///** 定时器执行block */
//@property (nonatomic, copy) LSTModelBlock handleBlock;
///** 每次计时单位增量 */
//@property (nonatomic, assign) NSTimeInterval unit;
///** 是否递增 YES:递增 NO:递减 */
//@property (nonatomic, assign) BOOL increase;
///** 是否本地持久化保存定时数据 */
//@property (nonatomic,assign) BOOL isDisk;
///** 是否暂停 */
//@property (nonatomic,assign) BOOL isPause;
///** 标识 */
//@property (nonatomic, copy) NSString *identifier;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.timeInterval forKey:@"timeInterval"];
    [aCoder encodeDouble:self.unit forKey:@"unit"];
    [aCoder encodeBool:self.increase forKey:@"increase"];
    [aCoder encodeBool:self.isDisk forKey:@"isDisk"];
    [aCoder encodeBool:self.isPause forKey:@"isPause"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.timeInterval = [aDecoder decodeDoubleForKey:@"timeInterval"];
        self.unit = [aDecoder decodeDoubleForKey:@"unit"];
        self.increase = [aDecoder decodeBoolForKey:@"increase"];
        self.isDisk = [aDecoder decodeBoolForKey:@"isDisk"];
        self.isPause = [aDecoder decodeBoolForKey:@"isPause"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    }
    return self;
}

@end
