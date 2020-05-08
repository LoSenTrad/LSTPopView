//
//  LSTPopViewManager.m
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import "LSTPopViewManager.h"
#import "LSTPopView.h"



@interface LSTPopViewTimerModel : NSObject

@property (nonatomic, assign) NSTimeInterval timeInterval;
/** 定时器执行block */
@property (nonatomic, copy) LSTPopViewManagerTimerBlock handleBlock;

+ (instancetype)timeInterval:(NSInteger)timeInterval;

@end

@implementation LSTPopViewTimerModel

+ (instancetype)timeInterval:(NSInteger)timeInterval {
    LSTPopViewTimerModel *object = [LSTPopViewTimerModel new];
    object.timeInterval = timeInterval;
    return object;
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
/** 获取对应popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)view {
    NSMutableArray *mArr = LSTPopViewM().popViewMarr;
    NSMutableArray *resMarr = [NSMutableArray array];
    for (NSValue *v in mArr) {
        LSTPopView *popView = v.nonretainedObjectValue;
        if ([popView.superview isEqual:view]) {
            [resMarr addObject:v];
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 获取所有popView 精准获取 */
/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(LSTPopView *)popView {
    
    NSArray *mArr = [self getAllPopViewForParentView:popView.superview];
    NSMutableArray *resMarr = [NSMutableArray array];
    for (NSValue *v in mArr) {
        LSTPopView *tPopView = v.nonretainedObjectValue;
        if (popView.groupId == nil && tPopView.groupId == nil) {
            [resMarr addObject:v];
            continue;
        }
        if ([tPopView.groupId isEqual:popView.groupId]) {
            [resMarr addObject:v];
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
    for (NSValue *v in arr) {
        LSTPopView *tPopView  = v.nonretainedObjectValue;
        
        if ([tPopView isEqual:popView]) {
            break;
            return;
        }
    }
    //
    //    NSDictionary *dic = @{LSTPopView_Key:key.length>0?key:@"",
    //                          LSTPopView_PopView:[NSValue valueWithNonretainedObject:popView],
    //                          LSTPopView_ParentView:[NSValue valueWithNonretainedObject:parentView]};
    
    
    [LSTPopViewM().popViewMarr addObject:[NSValue valueWithNonretainedObject:popView]];

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

/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForCountdown:(NSTimeInterval)countdown
                      handle:(LSTPopViewManagerTimerBlock)handle {
    
}
/** 添加定时器并开启计时 完成任务会自动移除 计时器源*/
+ (void)addTimerForIdentifier:(NSString *)identifier
                 forCountdown:(NSTimeInterval)countdown
                       handle:(LSTPopViewManagerTimerBlock)handle {
    
}

/** 添加定时器并开启计时 */
+ (void)addTimerForHandle:(LSTPopViewManagerTimerBlock)handle {
    
}

/** 添加定时器并开启计时 */
+ (void)addTimerForIdentifier:(NSString *)identifier handle:(LSTPopViewManagerTimerBlock)handle{
    
    if (identifier.length<=0) {
        identifier = [self getTimeStamp];
    }
    
    LSTPopViewTimerModel *model = LSTPopViewM().timerMdic[identifier];
    if (!model) {
        model = [LSTPopViewTimerModel timeInterval:0];
        [LSTPopViewM().timerMdic setObject:model forKey:identifier];
        model.handleBlock = handle;
    }
    [self initTimer:YES timeInterval:1];
}


+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier {
    return 100;
}


+ (void)pauseTimerForIdentifier:(NSString *)identifier {
    
}
+ (void)pauseAllTimer {
    
}

+ (void)removeTimerForIdentifier:(NSString *)identifier {
    
}
+ (void)removeAllTimer {
    
}

/** increase YES: 递增 NO: 递减   */
+ (void)initTimer:(BOOL)increase timeInterval:(NSTimeInterval)timeInterval {
    
    if (LSTPopViewM().showTimer) {
        return;
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:LSTPopViewM() selector:@selector(handleHideTimer:) userInfo:@{@"increase":@(increase),@"timeInterval":@(timeInterval)} repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    LSTPopViewM().showTimer = timer;
    
}

- (void)handleHideTimer:(NSTimer *)timer {
    
    [self timerChange:1];
    
}

- (void)timerChange:(NSTimeInterval)timeInterval {
    // 时间差+
    [LSTPopViewM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, LSTPopViewTimerModel *obj, BOOL *stop) {
        obj.timeInterval += timeInterval;
        if (obj.handleBlock) {
            obj.handleBlock(obj.timeInterval);
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



@end
