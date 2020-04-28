//
//  LSTPopViewManager.m
//  LSTButton
//
//  Created by LoSenTrad on 2020/3/30.
//

#import "LSTPopViewManager.h"




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
/** 获取对应popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)view {
    NSMutableArray *mArr = LSTPopViewM().popViewMarr;
    NSMutableArray *resMarr = [NSMutableArray array];
    for (NSDictionary *dic in mArr) {
        NSValue *v = dic[LSTPopView_ParentView];
        if ([v.nonretainedObjectValue isEqual:view]) {
            [resMarr addObject:dic];
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 读取popView */
+ (LSTPopView *)getPopViewForKey:(NSString *)key {
   
    return nil;
}

+ (void)savePopView:(LSTPopView *)popView forParentView:(UIView *)parentView forKey:(NSString *)key {
    

    NSArray *arr = [self getAllPopViewForParentView:parentView];

    for (NSDictionary *dic in arr) {
        NSValue *v = dic[LSTPopView_PopView];
        if ([v.nonretainedObjectValue isEqual:popView]) {
            break;
            return;
        }
    }
        
    NSDictionary *dic = @{LSTPopView_Key:key.length>0?key:@"",
                          LSTPopView_PopView:[NSValue valueWithNonretainedObject:popView],
                          LSTPopView_ParentView:[NSValue valueWithNonretainedObject:parentView]};

    
    [LSTPopViewM().popViewMarr addObject:dic];
    

}

/** 移除popView */
+ (void)removePopView:(LSTPopView *)popView {
    if (!popView) { return;}
    NSArray *arr = LSTPopViewM().popViewMarr;
    
    for (NSDictionary *dic in arr) {
        NSValue *v = dic[LSTPopView_PopView];
        if ([v.nonretainedObjectValue isEqual:popView]) {
            [LSTPopViewM().popViewMarr removeObject:dic];
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


- (NSMutableArray *)popViewMarr {
    if(_popViewMarr) return _popViewMarr;
    _popViewMarr = [NSMutableArray array];
    return _popViewMarr;
}


@end
