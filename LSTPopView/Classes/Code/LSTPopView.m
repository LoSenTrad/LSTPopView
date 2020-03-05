//
//  LSTPopView.m
//  LoSenTrad
//
//  Created by LoSenTrad on 2020/2/22.
//

#import "LSTPopView.h"
#import "UIView+LSTView.h"
#import "UIColor+LSTColor.h"


// 角度转弧度
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface LSTPopView ()<UIGestureRecognizerDelegate>

///** 内容视图 */
//@property (nonatomic, strong) UIView *contentView;
/** 背景层 */
@property (nonatomic, strong) UIView *backgroundView;
/** 自定义视图 */
@property (nonatomic, strong) UIView *customView;


@end

@implementation LSTPopView



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    //初始化配置
    _isClickBGDismiss = NO;
    _isObserverOrientationChange = NO;
    _popBGAlpha = 0.3;
    _animationPopStyle = LSTPopStyleNO;
    _animationDismissStyle = LSTDismissStyleNO;
    _popAnimationDuration = -0.1f;
    _dismissAnimationDuration = -0.1f;
    _hemStyle = LSTHemStyleCenter;
    self.adjustX = 0;
    self.adjustY = 0;
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView {
    
   return [self initWithCustomView:customView popStyle:LSTPopStyleNO dismissStyle:LSTDismissStyleNO];
}


+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle {
    // 检测自定义视图是否存在(check customView is exist)
    if (!customView) {
        return nil;
    }
    
    CGRect selfFrame =  CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    LSTPopView *popView = [[LSTPopView alloc] initWithFrame:selfFrame];
    popView.customView = customView;
    
    popView.backgroundView = [[UIView alloc] initWithFrame:popView.bounds];
    [popView addSubview:popView.backgroundView];
    [popView.backgroundView addSubview:customView];
    
    popView.backgroundColor = [UIColor clearColor];
    popView.backgroundView.backgroundColor = [UIColor blackColor];
    popView.animationPopStyle = popStyle;
    popView.animationDismissStyle = dismissStyle;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(tapBGLayer:)];
    tap.delegate = popView;
    [popView.backgroundView addGestureRecognizer:tap];
    //监听customView frame
    [popView.customView addObserver:popView forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    
    return popView;

}

- (void)setCustomViewFrame {
    switch (self.hemStyle) {
        case LSTHemStyleTop ://贴顶
        {
           _customView.centerX = self.backgroundView.centerX+self.adjustX;
           _customView.y = self.adjustY;
        }
            break;
        case LSTHemStyleLeft ://贴左
        {
            _customView.x = self.adjustX;
            _customView.centerY = self.backgroundView.centerY+self.adjustY;

        }
            break;
        case LSTHemStyleBottom ://贴底
        {
            self.customView.centerX = self.backgroundView.centerX+self.adjustX;
            [self.customView layoutIfNeeded];
            _customView.y = self.backgroundView.height-self.customView.height+self.adjustY;
        }
            break;
        case LSTHemStyleRight ://贴右
        {
            _customView.x = self.backgroundView.width-self.customView.width+self.adjustX;
            _customView.centerY = self.backgroundView.centerY+self.adjustY;
        }
            break;
        default://居中
        {
            _customView.centerX = self.backgroundView.centerX+self.adjustX;
            _customView.centerY = self.backgroundView.centerY+self.adjustY;
        }
            break;
    }
}

#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setHemStyle:(LSTHemStyle)hemStyle {
    _hemStyle = hemStyle;
    
    
//    [self setCustomViewFrame];
}

- (void)setAdjustX:(CGFloat)adjustX {
    _adjustX = adjustX;
    
    [self setCustomViewFrame];
    
    return;
    switch (self.hemStyle) {
        case LSTHemStyleTop ://贴顶
        {
            _customView.centerX = self.backgroundView.centerX+self.adjustX;
        }
            break;
        case LSTHemStyleLeft ://贴左
        {
             _customView.x = _customView.x+self.adjustX;
//            _customView.x =  _customView.centerX+self.adjustX;
            
        }
            break;
        case LSTHemStyleBottom ://贴底
        {
            _customView.centerX = self.backgroundView.centerX+self.adjustX;
        }
            break;
        case LSTHemStyleRight ://贴右
        {
            _customView.x = self.backgroundView.width-self.customView.width+self.adjustX;
        }
            break;
        default://居中
        {
            _customView.centerX = self.backgroundView.centerX + self.adjustX;
        }
            break;
    }
}

- (void)setAdjustY:(CGFloat)adjustY {
    _adjustY = adjustY;
    
    [self setCustomViewFrame];
    
    return;
    switch (self.hemStyle) {
        case LSTHemStyleTop ://贴顶
        {
            _customView.y = self.adjustY;
        }
            break;
        case LSTHemStyleLeft ://贴左
        {
            _customView.centerY = self.backgroundView.centerY+self.adjustY;
            
        }
            break;
        case LSTHemStyleBottom ://贴底
        {
            _customView.y = self.backgroundView.height-self.customView.height+self.adjustY;
        }
            break;
        case LSTHemStyleRight ://贴右
        {
            _customView.centerY = self.backgroundView.centerY+self.adjustY;
        }
            break;
        default://居中
        {
            _customView.centerY = self.backgroundView.centerY+self.adjustY;
        }
            break;
    }
}



- (void)setIsObserverOrientationChange:(BOOL)isObserverOrientationChange {
    _isObserverOrientationChange = isObserverOrientationChange;
    
    if (_isObserverOrientationChange) {
        
        [self statusBarOrientationChange];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

- (void)setPopBGAlpha:(CGFloat)popBGAlpha {
    _popBGAlpha = (popBGAlpha <= 0.0f) ? 0.0f : ((popBGAlpha > 1.0) ? 1.0 : popBGAlpha);
    
}



#pragma mark - ***** other 其他 *****

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = CGRectNull;
        CGRect oldFrame = CGRectNull;
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            //此处为获取新的frame
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            oldFrame = [[change valueForKeyPath:@"old"] CGRectValue];
            if (!CGRectEqualToRect(newFrame, oldFrame)) {
                [self setCustomViewFrame];
            }
        }
    }
}

- (void)tapBGLayer:(UITapGestureRecognizer *)tap {
    if (_isClickBGDismiss) {
        [self dismiss];
    }
    
    if (self.bgClickBlock) {
        self.bgClickBlock();
    }
}

#pragma mark UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:_backgroundView];
    location = [_customView.layer convertPoint:location fromLayer:_backgroundView.layer];
    return ![_customView.layer containsPoint:location];
}

- (void)pop {
    
    [self setCustomViewFrame];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getPopDefaultDuration:self.animationPopStyle];
    NSTimeInterval duration = (_popAnimationDuration < 0.0f) ? defaultDuration : _popAnimationDuration;
    if (self.animationPopStyle == LSTPopStyleNO) {//无动画
        
    
        self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0.0f];
        self.customView.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            
            self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:self.popBGAlpha];
             self.customView.alpha = 1.0f;
        }];
        

    } else {//有动画
        
        //设置背景过渡动画
        self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0];
        [UIView animateWithDuration:duration * 0.5 animations:^{
            ws.backgroundView.backgroundColor = [self lst_BlackWithAlpha:self.popBGAlpha];
        }];
        
        //自定义view的自定义动画
        [self hanlePopAnimationWithDuration:duration];
    }

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.popComplete) {
            ws.popComplete();
        }
    });
}

- (void)hanlePopAnimationWithDuration:(NSTimeInterval)duration {
    __weak typeof(self) ws = self;
    switch (self.animationPopStyle) {
        case LSTPopStyleScale:// < 缩放动画，先放大，后恢复至原大小
        {
            [self animationWithLayer:_customView.layer duration:((0.3*duration)/0.7) values:@[@0.0, @1.2, @1.0]]; // 另外一组动画值(the other animation values) @[@0.0, @1.2, @0.9, @1.0]
        }
            break;
        case LSTPopStyleShakeFromTop:
        case LSTPopStyleShakeFromBottom:
        case LSTPopStyleShakeFromLeft:
        case LSTPopStyleShakeFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (self.animationPopStyle == LSTPopStyleShakeFromTop) {
                self.customView.layer.position = CGPointMake(startPosition.x, -startPosition.y);
            } else if (self.animationPopStyle == LSTPopStyleShakeFromBottom) {
                self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + self.customView.height);
            } else if (self.animationPopStyle == LSTPopStyleShakeFromLeft) {
                self.customView.layer.position = CGPointMake(-startPosition.x, startPosition.y);
            } else {
                self.customView.layer.position = CGPointMake(CGRectGetMaxX(self.frame) + self.customView.width*0.5 , startPosition.y);
            }

            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                ws.customView.layer.position = startPosition;
            } completion:nil];
        }
            break;
        case LSTPopStyleCardDropFromLeft:
        case LSTPopStyleCardDropFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (self.animationPopStyle == LSTPopStyleCardDropFromLeft) {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -startPosition.y);
                self.customView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(15.0));
            } else {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -startPosition.y);
                self.customView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-15.0));
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                ws.customView.layer.position = startPosition;
            } completion:nil];
            
            [UIView animateWithDuration:duration*0.6 animations:^{
                ws.customView.layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS((ws.animationPopStyle == LSTPopStyleCardDropFromRight) ? 5.5 : -5.5), 0, 0, 0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.2 animations:^{
                    ws.customView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS((ws.animationPopStyle == LSTPopStyleCardDropFromRight) ? -1.0 : 1.0));
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration*0.2 animations:^{
                        ws.customView.transform = CGAffineTransformMakeRotation(0.0);
                    } completion:nil];
                }];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)dismiss {
    __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getDismissDefaultDuration:self.animationDismissStyle];
    NSTimeInterval duration = (_dismissAnimationDuration < 0.0f) ? defaultDuration : _dismissAnimationDuration;
    if (self.animationDismissStyle == LSTPopStyleNO) {
       
       
        [UIView animateWithDuration:0.2 animations:^{
            
            self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0.0f];
            self.customView.alpha = 0.0f;
        }];
        
    } else {//有动画
        
        [UIView animateWithDuration:duration * 0.5 animations:^{
            ws.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0.0];;
        }];
        
        [self hanleDismissAnimationWithDuration:duration];
    }
    
    if (ws.isObserverOrientationChange) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.dismissComplete) {
            ws.dismissComplete();
        }
        [ws removeFromSuperview];
    });
}

- (void)hanleDismissAnimationWithDuration:(NSTimeInterval)duration
{
    __weak typeof(self) ws = self;
    switch (self.animationDismissStyle) {
        case LSTDismissStyleScale:
        {
            [self animationWithLayer:self.customView.layer duration:((0.2*duration)/0.8) values:@[@1.0, @0.66, @0.33, @0.01]];
        }
            break;
        case LSTDismissStyleDropToTop:
        case LSTDismissStyleDropToBottom:
        case LSTDismissStyleDropToLeft:
        case LSTDismissStyleDropToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = self.customView.layer.position;
            if (self.animationDismissStyle == LSTDismissStyleDropToTop) {
                endPosition = CGPointMake(startPosition.x, -startPosition.y);
            } else if (self.animationDismissStyle == LSTDismissStyleDropToBottom) {
                endPosition = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + startPosition.y);
            } else if (self.animationDismissStyle == LSTDismissStyleDropToLeft) {
                endPosition = CGPointMake(-startPosition.x, startPosition.y);
            } else {
                endPosition = CGPointMake(CGRectGetMaxX(self.frame) + startPosition.x, startPosition.y);
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                ws.customView.layer.position = endPosition;
            } completion:nil];
        }
            break;
        case LSTDismissStyleCardDropToLeft:
        case LSTDismissStyleCardDropToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            __block CGFloat rotateEndY = 0.0f;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                if (self.animationDismissStyle == LSTDismissStyleCardDropToLeft) {
                    ws.customView.transform = CGAffineTransformMakeRotation(M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(ws.customView.frame.origin.y);
                    ws.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(ws.frame) + startPosition.y + rotateEndY);
                } else {
                    ws.customView.transform = CGAffineTransformMakeRotation(-M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(ws.customView.frame.origin.y);
                    ws.customView.layer.position = CGPointMake(startPosition.x * 1.25, CGRectGetMaxY(ws.frame) + startPosition.y + rotateEndY);
                }
            } completion:nil];
        }
            break;
        case LSTDismissStyleCardDropToTop:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = CGPointMake(startPosition.x, -startPosition.y);
            [UIView animateWithDuration:duration*0.2 animations:^{
                ws.customView.layer.position = CGPointMake(startPosition.x, startPosition.y + 50.0f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.8 animations:^{
                    ws.customView.layer.position = endPosition;
                } completion:nil];
            }];
        }
            break;
        default:
            break;
    }
}

- (NSTimeInterval)getPopDefaultDuration:(LSTPopStyle)animationPopStyle
{
    NSTimeInterval defaultDuration = 0.0f;
    if (animationPopStyle == LSTPopStyleNO) {
        defaultDuration = 0.2f;
    } else if (animationPopStyle == LSTPopStyleScale) {
        defaultDuration = 0.3f;
    } else if (animationPopStyle == LSTPopStyleShakeFromTop ||
               animationPopStyle == LSTPopStyleShakeFromBottom ||
               animationPopStyle == LSTPopStyleShakeFromLeft ||
               animationPopStyle == LSTPopStyleShakeFromRight ||
               animationPopStyle == LSTPopStyleCardDropFromLeft ||
               animationPopStyle == LSTPopStyleCardDropFromRight) {
        defaultDuration = 0.7f;
    }
    return defaultDuration;
}

- (NSTimeInterval)getDismissDefaultDuration:(LSTDismissStyle)animationDismissStyle
{
    NSTimeInterval defaultDuration = 0.0f;
    if (animationDismissStyle == LSTDismissStyleNO) {
        defaultDuration = 0.2f;
    } else if (animationDismissStyle == LSTDismissStyleScale) {
        defaultDuration = 0.2f;
    } else if (animationDismissStyle == LSTDismissStyleDropToTop ||
               animationDismissStyle == LSTDismissStyleDropToBottom ||
               animationDismissStyle == LSTDismissStyleDropToLeft ||
               animationDismissStyle == LSTDismissStyleDropToRight ||
               animationDismissStyle == LSTDismissStyleCardDropToLeft ||
               animationDismissStyle == LSTDismissStyleCardDropToRight ||
               animationDismissStyle == LSTDismissStyleCardDropToTop) {
        defaultDuration = 0.8f;
    }
    return defaultDuration;
}

- (void)animationWithLayer:(CALayer *)layer duration:(CGFloat)duration values:(NSArray *)values
{
    CAKeyframeAnimation *KFAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    KFAnimation.duration = duration;
    KFAnimation.removedOnCompletion = NO;
    KFAnimation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:values.count];
    for (NSUInteger i = 0; i<values.count; i++) {
        CGFloat scaleValue = [values[i] floatValue];
        [valueArr addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleValue, scaleValue, scaleValue)]];
    }
    KFAnimation.values = valueArr;
    KFAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [layer addAnimation:KFAnimation forKey:nil];
}

- (UIColor *)lst_BlackWithAlpha: (CGFloat)alpha {
//    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];

}

#pragma mark 监听横竖屏方向改变
- (void)statusBarOrientationChange:(NSNotification *)notification {
//    CGRect startCustomViewRect = self.customView.frame;
//    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
//    self.backgroundView.frame = self.bounds;
//    self.backgroundView.frame = self.bounds;
//    self.customView.frame = startCustomViewRect;
//    self.customView.center = self.center;
}

- (void)statusBarOrientationChange{
////    CGRect startCustomViewRect = self.customView.frame;
//    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
//    self.backgroundView.frame = self.bounds;
//    self.backgroundView.frame = self.bounds;
////    self.customView.frame = self.bounds;
//    self.customView.center = self.center;
}

@end

