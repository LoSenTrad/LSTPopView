//
//  LSTPopViewManager.m
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import "LSTPopViewManager.h"
#import "LSTPopView.h"


#define LSTPopViewTimerPath(name)  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"LSTPopView_%@_Timer",name]]

@interface LSTPopViewTimerModel : NSObject

@property (nonatomic, assign) NSTimeInterval timeInterval;
/** 定时器执行block */
@property (nonatomic, copy) LSTPopViewManagerTimerBlock handleBlock;
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


+ (instancetype)timeInterval:(NSInteger)timeInterval;

@end

@implementation LSTPopViewTimerModel

+ (instancetype)timeInterval:(NSInteger)timeInterval {
    LSTPopViewTimerModel *object = [LSTPopViewTimerModel new];
    object.timeInterval = timeInterval;
    return object;
}

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



@interface LSTPopViewManager ()

/** 内存储存popView */
@property (nonatomic,strong) NSMutableArray *popViewMarr;

/** 储存多个计时器数据源 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, LSTPopViewTimerModel *> *timerMdic;


@end


@implementation LSTPopViewManager

static LSTPopViewManager *_instance;


LSTPopViewManager *LSTPopViewM() {
    return [LSTPopViewManager sharedInstance];
}

+ (instancetype)sharedInstance {
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
        });
    }
    return _instance;
}


+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (NSArray *)getAllPopView {
    return LSTPopViewM().popViewMarr;
}
/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)view {
    NSMutableArray *mArr = LSTPopViewM().popViewMarr;
    NSMutableArray *resMarr = [NSMutableArray array];
    for (id obj in mArr) {
        LSTPopView *popView;
        if ([obj isKindOfClass:[NSValue class]]) {
            NSValue *resObj = (NSValue *)obj;
            popView  = resObj.nonretainedObjectValue;
        }else {
            popView  = (LSTPopView *)obj;
        }
        if ([popView.parentView isEqual:view]) {
            [resMarr addObject:obj];
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 获取所有popView 精准获取 */
/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(LSTPopView *)popView {
    
    NSArray *mArr = [self getAllPopViewForParentView:popView.parentView];
    NSMutableArray *resMarr = [NSMutableArray array];
    for (id obj in mArr) {
        LSTPopView *tPopView;
        if ([obj isKindOfClass:[NSValue class]]) {
            NSValue *resObj = (NSValue *)obj;
            tPopView  = resObj.nonretainedObjectValue;
        }else {
            tPopView  = (LSTPopView *)obj;
        }
        
        if (popView.groupId == nil && tPopView.groupId == nil) {
            [resMarr addObject:obj];
            continue;
        }
        if ([tPopView.groupId isEqual:popView.groupId]) {
            [resMarr addObject:obj];
            continue;
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 读取popView */
+ (LSTPopView *)getPopViewForKey:(NSString *)key {
   
    return nil;
}

+ (void)savePopView:(LSTPopView *)popView {

    NSArray *arr = [self getAllPopView];
    for (id obj in arr) {
        LSTPopView *tPopView;
        if ([obj isKindOfClass:[NSValue class]]) {
            NSValue *resObj = (NSValue *)obj;
            tPopView  = resObj.nonretainedObjectValue;
        }else {
            tPopView  = (LSTPopView *)obj;
        }
        if ([tPopView isEqual:popView]) {
            break;
            return;
        }
    }

    if (popView.superview) {
        [LSTPopViewM().popViewMarr addObject:[NSValue valueWithNonretainedObject:popView]];

    }else {
        [LSTPopViewM().popViewMarr addObject:popView];

    }
   

    
    
     //优先级排序
    [self sortingArr];
    
//    NSMutableArray *test  = LSTPopViewM().popViewMarr;
//    for (NSValue *obj in test) {
//        LSTPopView *p = obj.nonretainedObjectValue;
//        NSLog(@"优先级--->%0.2f",p.priority);
//    }
//    NSLog(@"%@",test);
}
//冒泡排序
+ (void)sortingArr{

    NSMutableArray *arr = LSTPopViewM().popViewMarr;
    
    for (int i = 0; i < arr.count; i++) {
        for (int j = i+1; j < arr.count; j++) {
            
            LSTPopView *iPopView;
            if ([arr[i] isKindOfClass:[NSValue class]]) {
                NSValue *resObj = (NSValue *)arr[i];
                iPopView  = resObj.nonretainedObjectValue;
                
            }else {
                iPopView  = (LSTPopView *)arr[i];
            }
            LSTPopView *jPopView;
            if ([arr[j] isKindOfClass:[NSValue class]]) {
                NSValue *resObj = (NSValue *)arr[j];
                jPopView  = resObj.nonretainedObjectValue;
                
            }else {
                jPopView  = (LSTPopView *)arr[j];
            }
                     
            if (iPopView.priority < jPopView.priority) {
                [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

/** 弱化popView 仅供内部调用 */
+ (void)weakWithPopView:(LSTPopView *)popView {
    
    if (![LSTPopViewM().popViewMarr containsObject:popView]) {
        return;
    }
    
    NSUInteger index =  [LSTPopViewM().popViewMarr indexOfObject:popView];
    
    [LSTPopViewM().popViewMarr replaceObjectAtIndex:index withObject:[NSValue valueWithNonretainedObject:popView]];
    NSLog(@"%@",LSTPopViewM().popViewMarr);
}

/** 移除popView */
+ (void)removePopView:(LSTPopView *)popView {
    if (!popView) { return;}
    NSArray *arr = LSTPopViewM().popViewMarr;
    
    
    for (NSValue *v in arr) {
        LSTPopView *tPopView = v.nonretainedObjectValue;
        if ([tPopView isEqual:popView]) {
            [LSTPopViewM().popViewMarr removeObject:v];
            break;
            return;
        }
    }    
}

/** 移除popView */
+ (void)removePopViewForKey:(NSString *)key {
    
}
/** 移除所有popView */
+ (void)removeAllPopView {
  
}
//
//- (LSTPopView *)getPopViewWithValue:(NSValue *)value {
//
//    return value.nonretainedObjectValue;
//}

/** 出栈栈 仅供内部调用  */
+ (void)popStackForPopView:(LSTPopView *)popView {
    
}

/** 入栈 仅供内部调用  */
+ (void)intoStackForPopView:(LSTPopView *)popView {
//    //入栈
//    NSArray *popViewArr = [self getAllPopViewForPopView:popView];
//    if (popViewArr.count>=1) {
//        //        LSTPopView *lastPopView = popViewArr[popViewArr.count-1];
//        NSValue *v = popViewArr[popViewArr.count-1];
//        LSTPopView *lastPopView = v.nonretainedObjectValue;
////        if (lastPopView.isShowKeyboard) {
//        [lastPopView endEditing:YES];
////        }
//        [UIView animateWithDuration:[popView getPopDefaultDuration:popStyle]*0.5 animations:^{
//            lastPopView.alpha = 0.0;
//        }];
//    }
}


- (NSMutableArray *)popViewMarr {
    if(_popViewMarr) return _popViewMarr;
    _popViewMarr = [NSMutableArray array];
    return _popViewMarr;
}


#pragma mark - ***** 定时器相关 *****

#pragma mark - ***** 递减计时器 *****

/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForCountdown:(NSTimeInterval)countdown
                      handle:(LSTPopViewManagerTimerBlock)handle {
    [self addTimerForIdentifier:nil
                        forUnit:1
                    forIncrease:NO
                      ForIsDisk:NO
                   forCountdown:countdown
                         handle:handle];
}
/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForIdentifier:(NSString *)identifier
                 forCountdown:(NSTimeInterval)countdown
                       handle:(LSTPopViewManagerTimerBlock)handle {
    [self addTimerForIdentifier:identifier
                        forUnit:1
                    forIncrease:NO
                      ForIsDisk:NO
                   forCountdown:countdown
                         handle:handle];
}

+ (void)addTimerForIdentifier:(NSString *)identifier
                 forCountdown:(NSTimeInterval)countdown
                      forUnit:(NSTimeInterval)unit
                       handle:(LSTPopViewManagerTimerBlock)handle {
    [self addTimerForIdentifier:identifier
                        forUnit:unit
                    forIncrease:NO
                      ForIsDisk:NO
                   forCountdown:countdown
                         handle:handle];
}

+ (void)addDiskTimerForIdentifier:(NSString *)identifier
                     forCountdown:(NSTimeInterval)countdown
                          forUnit:(NSTimeInterval)unit
                           handle:(LSTPopViewManagerTimerBlock)handle {
    [self addTimerForIdentifier:identifier
                        forUnit:unit
                    forIncrease:NO
                      ForIsDisk:YES
                   forCountdown:countdown
                         handle:handle];
}


#pragma mark - ***** 递增计时器 *****

/** 添加定时器并开启计时 */
+ (void)addTimerForHandle:(LSTPopViewManagerTimerBlock)handle {
    [self addTimerForIdentifier:nil
                        forUnit:1
                    forIncrease:YES
                      ForIsDisk:NO
                   forCountdown:0
                         handle:handle];
}

/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier handle:(LSTPopViewManagerTimerBlock)handle{
    [self addTimerForIdentifier:identifier
                        forUnit:1
                    forIncrease:YES
                      ForIsDisk:NO
                   forCountdown:0
                         handle:handle];
  
}

/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier
                      forUnit:(NSTimeInterval)unit
                       handle:(LSTPopViewManagerTimerBlock)handle {
    
   
    [self addTimerForIdentifier:identifier
                        forUnit:unit
                    forIncrease:YES
                      ForIsDisk:NO
                   forCountdown:0
                         handle:handle];
    
}

+ (void)addDiskTimerForIdentifier:(NSString *)identifier
                          forUnit:(NSTimeInterval)unit
                           handle:(LSTPopViewManagerTimerBlock)handle {
    [self addTimerForIdentifier:identifier
                        forUnit:unit
                    forIncrease:YES
                      ForIsDisk:YES
                   forCountdown:0
                         handle:handle];
}
//总初始化入口
+ (void)addTimerForIdentifier:(NSString *)identifier
                      forUnit:(NSTimeInterval)unit
                  forIncrease:(BOOL)increase
                    ForIsDisk:(BOOL)isDisk
                 forCountdown:(NSTimeInterval)countdown
                       handle:(LSTPopViewManagerTimerBlock)handle {
    
    if (identifier.length<=0) {
        identifier = [self getTimeStamp];
    }
    
    
    BOOL isTempDisk = [LSTPopViewManager timerIsExistInDiskForIdentifier:identifier];//磁盘有任务
    BOOL isRAM = LSTPopViewM().timerMdic[identifier]?YES:NO;//内存有任务
    
    
     
    if (!isRAM && !isTempDisk) {//新任务
        LSTPopViewTimerModel *model = [LSTPopViewTimerModel timeInterval:countdown];
        model.handleBlock = handle;
        model.unit = unit;
        model.increase = increase;
        model.isDisk = isDisk;
        model.identifier = identifier;
        [LSTPopViewM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            model.handleBlock(model.timeInterval);
        }
        [self initTimer];
    }
   
    
    if (isRAM && !isTempDisk) {//内存任务
        LSTPopViewTimerModel *model = LSTPopViewM().timerMdic[identifier];
        model.isPause = NO;
    }
    
    if (!isRAM && isTempDisk) {//硬盘的任务
        LSTPopViewTimerModel *model = [LSTPopViewTimerModel timeInterval:countdown];
        model.handleBlock = handle;
        model.unit = unit;
        model.increase = increase;
        model.isDisk = isDisk;
        model.identifier = identifier;
        model.timeInterval = [LSTPopViewManager getTimeIntervalForIdentifier:identifier];
        [LSTPopViewM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            model.handleBlock(model.timeInterval);
        }
        [self initTimer];
    }
    
    if (isRAM && isTempDisk) {//硬盘的任务
        LSTPopViewTimerModel *model = LSTPopViewM().timerMdic[identifier];
        model.timeInterval = [LSTPopViewManager getTimeIntervalForIdentifier:identifier];
    }

}

+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        return 0.0;
    }
    
    BOOL isTempDisk = [LSTPopViewManager timerIsExistInDiskForIdentifier:identifier];//磁盘有任务
    BOOL isRAM = LSTPopViewM().timerMdic[identifier]?YES:NO;//内存有任务
    
    
    if (isTempDisk) {
        LSTPopViewTimerModel *model = [LSTPopViewManager loadTimerForIdentifier:identifier];
        
        return model.timeInterval;
    }else if (isRAM) {
         LSTPopViewTimerModel *model = LSTPopViewM().timerMdic[identifier];
        return model.timeInterval;
    }else {
        NSLog(@"找不到计时任务");
        return 0.0;
    }
    
}

+ (BOOL)pauseTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    LSTPopViewTimerModel *model = LSTPopViewM().timerMdic[identifier];
    if (model) {
        model.isPause = YES;
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
}

+ (void)pauseAllTimer {
    [LSTPopViewM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, LSTPopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = YES;
    }];
}

+ (BOOL)restartTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    //只有内存任务才能重启, 硬盘任务只能调用addTimer系列方法重启
    BOOL isRAM = LSTPopViewM().timerMdic[identifier]?YES:NO;//内存有任务
    if (isRAM) {
        LSTPopViewTimerModel *model = LSTPopViewM().timerMdic[identifier];
        model.isPause = NO;
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
    
    
}
+ (void)restartAllTimer {
    
    if (LSTPopViewM().timerMdic.count<=0) {
        return;
    }
    
    [LSTPopViewM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, LSTPopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = NO;
    }];
}

+ (BOOL)removeTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    [LSTPopViewM().timerMdic removeObjectForKey:identifier];
    if (LSTPopViewM().timerMdic.count<=0) {//如果没有计时任务了 就销毁计时器
        [LSTPopViewM().showTimer invalidate];
        LSTPopViewM().showTimer = nil;
    }
    return YES;
}

+ (void)removeAllTimer {
    [LSTPopViewM().timerMdic removeAllObjects];
    [LSTPopViewM().showTimer invalidate];
    LSTPopViewM().showTimer = nil;
}

/** increase YES: 递增 NO: 递减   */
+ (void)initTimer {
    
    if (LSTPopViewM().showTimer) {
        return;
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:LSTPopViewM() selector:@selector(handleHideTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    LSTPopViewM().showTimer = timer;
    
}

- (void)handleHideTimer:(NSTimer *)timer {
    
    [self timerChange];
    
}

- (void)timerChange {
    // 时间差+
    [LSTPopViewM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, LSTPopViewTimerModel *obj, BOOL *stop) {
        if (!obj.isPause) {
            if (obj.increase) {//递增
                obj.timeInterval = obj.timeInterval + obj.unit;
            }else {//递减
                obj.timeInterval = obj.timeInterval - obj.unit;
                if (obj.timeInterval<0) {//计时结束
                    obj.timeInterval = 0;
                    obj.isPause = YES;
                }
            }
            
            if (obj.isDisk) {
                [NSKeyedArchiver archiveRootObject:obj toFile:LSTPopViewTimerPath(obj.identifier)];
            }
            
            if (obj.handleBlock&&obj.increase) {//递增
                obj.handleBlock(obj.timeInterval);
            }
            if (obj.handleBlock&&!obj.increase&&obj>=0) {//递减
                
                obj.handleBlock(obj.timeInterval);
                if (obj.timeInterval<=0) {//计时器计时完毕自动移除计时任务
                    [LSTPopViewM().timerMdic removeObjectForKey:obj.identifier];
                    
                    NSLog(@"%@",LSTPopViewM().timerMdic);
                }
            }
        }
    }];
    // 发出通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil userInfo:nil];
}

+ (NSString *)getTimeStamp {
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
}


- (NSMutableDictionary<NSString *,LSTPopViewTimerModel *> *)timerMdic {
    if(_timerMdic) return _timerMdic;
    _timerMdic = [NSMutableDictionary dictionary];
    return _timerMdic;
}

+ (BOOL)savaForTimerModel:(LSTPopViewTimerModel *)model {
    NSString *filePath = LSTPopViewTimerPath(model.identifier);
    return [NSKeyedArchiver archiveRootObject:model toFile:filePath];
}

+ (LSTPopViewTimerModel *)loadTimerForIdentifier:(NSString *)identifier{
    NSString *filePath = LSTPopViewTimerPath(identifier);
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+ (BOOL)deleteForIdentifier:(NSString *)identifier {
    NSString *filePath = LSTPopViewTimerPath(identifier);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (BOOL)timerIsExistInDiskForIdentifier:(NSString *)identifier {
    NSString *filePath = LSTPopViewTimerPath(identifier);
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return isExist;
}



@end
