//
//  LSTPopViewManager.m
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import "LSTPopViewManager.h"
#import "LSTPopView.h"


@interface LSTPopViewManager ()

/** 内存储存popView */
@property (nonatomic,strong) NSMutableArray *popViewMarr;


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
            
            if (iPopView.priority > jPopView.priority) {
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
    
    for (id obj in arr) {
        LSTPopView *tPopView;
        if ([obj isKindOfClass:[NSValue class]]) {
            NSValue *resObj = (NSValue *)obj;
            tPopView  = resObj.nonretainedObjectValue;
        }else {
            tPopView  = (LSTPopView *)obj;
        }
        if ([tPopView isEqual:popView]) {
            [LSTPopViewM().popViewMarr removeObject:obj];
            break;
            return;
        }
    }
}

/** 移除popView */
+ (void)removePopViewForKey:(NSString *)key {
    if (key.length<=0) { return;}
    NSArray *arr = LSTPopViewM().popViewMarr;
    
    for (id obj in arr) {
        LSTPopView *tPopView;
        if ([obj isKindOfClass:[NSValue class]]) {
            NSValue *resObj = (NSValue *)obj;
            tPopView  = resObj.nonretainedObjectValue;
        }else {
            tPopView  = (LSTPopView *)obj;
        }
        if ([tPopView.identifier isEqualToString:key]) {
            [LSTPopViewM().popViewMarr removeObject:obj];
            break;
            return;
        }
    }
}
/** 移除所有popView */
+ (void)removeAllPopView {
    NSMutableArray *arr = LSTPopViewM().popViewMarr;
    
    if (arr.count<=0) {return;}
    [arr removeAllObjects];
}

- (NSMutableArray *)popViewMarr {
    if(_popViewMarr) return _popViewMarr;
    _popViewMarr = [NSMutableArray array];
    return _popViewMarr;
}





@end
