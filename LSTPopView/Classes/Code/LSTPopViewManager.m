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

/** 读取popView */
+ (void)getPopViewForKey:(NSString *)key {
   
}
/** 保存popView */
+ (void)savePopView:(id)popView forKey:(NSString *)key {
    if (key.length<=0) {return;}
//
//       NSDictionary *dic = @{@"key":key,@"popView":}:
//
//       LSTPopViewM().popViewMarr addObject:
}
/** 移除popView */
+ (void)removePopViewForKey:(NSString *)key {
    
}
/** 移除所有popView */
+ (void)removeAllPopView {
    
}


- (NSMutableArray *)popViewMarr {
    if(_popViewMarr) return _popViewMarr;
    _popViewMarr = [NSMutableArray array];
    return _popViewMarr;
}


@end
