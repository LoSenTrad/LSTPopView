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



#pragma mark - ***** 初始化 *****

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
    _popStyle = LSTPopStyleNO;
    _dismissStyle = LSTDismissStyleNO;
    _popDuration = -0.1f;
    _dismissDuration = -0.1f;
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
    popView.backgroundColor = [UIColor clearColor];
    popView.backgroundView.backgroundColor = [UIColor blackColor];
    popView.popStyle = popStyle;
    popView.dismissStyle = dismissStyle;
    
    [popView addSubview:popView.backgroundView];
    [popView.backgroundView addSubview:customView];
    
    //背景添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(tapBGLayer:)];
    tap.delegate = popView;
    [popView.backgroundView addGestureRecognizer:tap];
    //监听customView frame
    [popView.customView addObserver:popView forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    //自定义view添加单击/长按反馈动画
//    UILongPressGestureRecognizer *customViewLP = [[UILongPressGestureRecognizer alloc] initWithTarget:popView action:@selector(pressedEvent:)];
//    [popView.customView addGestureRecognizer:customViewLP];

    UITapGestureRecognizer *customViewTap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(clickEvent:)];
    [popView.customView addGestureRecognizer:customViewTap];
    
//
//    [popView.customView addTarget:self action:@selector(pressedEvent:) forControlEvents:UIControlEventTouchDown];
//    [popView.customView addTarget:self action:@selector(unpressedEvent:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    return popView;

}

- (void)dealloc {
    [self.customView removeObserver:self forKeyPath:@"frame"];
}



#pragma mark - ***** UI布局 *****

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
    
}

- (void)setAdjustX:(CGFloat)adjustX {
    _adjustX = adjustX;
    
    [self setCustomViewFrame];
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

#pragma mark - ***** 公有api *****



- (void)pop {
    [self popWithPopStyle:self.popStyle duration:[self getPopDefaultDuration:self.popStyle]];
}
/// 打开popView 带动画
/// @param popStyle 优先级高于popStyle 局部起作用
- (void)popWithPopStyle:(LSTPopStyle)popStyle {
    
    [self popWithPopStyle:popStyle duration:[self getPopDefaultDuration:popStyle]];
    
}
/// 打开popView 带动画
/// @param popStyle 优先级高于popStyle 局部起作用
/// @param duration 优先级高于popDuration 局部起作用
- (void)popWithPopStyle:(LSTPopStyle)popStyle duration:(CGFloat)duration {
    [self setCustomViewFrame];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getPopDefaultDuration:popStyle];
    NSTimeInterval resDuration = (duration < 0.0f) ? defaultDuration : duration;
    if (popStyle == LSTPopStyleNO) {//无动画
        
        
        self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0.0f];
        self.customView.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            
            self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:self.popBGAlpha];
            self.customView.alpha = 1.0f;
        }];
        
        
    } else {//有动画
        
        //设置背景过渡动画
        self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0];
        [UIView animateWithDuration:resDuration * 0.5 animations:^{
            ws.backgroundView.backgroundColor = [self lst_BlackWithAlpha:self.popBGAlpha];
        }];
        
        //自定义view的自定义动画
        [self hanlePopAnimationWithDuration:resDuration popStyle:popStyle];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.popComplete) {
            ws.popComplete();
        }
    });
}

- (void)dismiss {
    [self dismissWithDismissStyle:self.dismissStyle duration:[self getDismissDefaultDuration:self.dismissStyle]];
}

/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle {
    [self dismissWithDismissStyle:dismissStyle duration:[self getDismissDefaultDuration:dismissStyle]];
}
/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
/// @param duration 优先级高于dismissDuration 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle duration:(CGFloat)duration {
    __block __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getDismissDefaultDuration:dismissStyle];
    NSTimeInterval resDuration = (duration < 0.0f) ? defaultDuration : duration;
    if (dismissStyle == LSTPopStyleNO) {
        
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0.0f];
            self.customView.alpha = 0.0f;
        }];
        
    } else {//有动画
        
        [UIView animateWithDuration:resDuration * 0.5 animations:^{
            ws.backgroundView.backgroundColor = [self lst_BlackWithAlpha:0.0];;
        }];
        
        [self hanleDismissAnimationWithDuration:resDuration withDismissStyle:dismissStyle];
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

//按钮的压下事件 按钮缩小
- (void)pressedEvent:(UIGestureRecognizer *)ges {
    //缩放比例必须大于0，且小于等于1
    
    
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGFloat scale = 0.95;
            [UIView animateWithDuration:0.35 animations:^{
                ges.view.transform = CGAffineTransformMakeScale(scale, scale);
            }];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [UIView animateWithDuration:0.35 animations:^{
                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
            }];
        }
            break;
            
        default:
            break;
    }
}

//按钮的压下事件 按钮缩小
- (void)clickEvent:(UIGestureRecognizer *)ges {
    //缩放比例必须大于0，且小于等于1
    
    CGFloat scale = 0.95;
    
    [UIView animateWithDuration:0.25 animations:^{
        ges.view.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:^(BOOL finished) {
         [UIView animateWithDuration:0.25 animations:^{
             ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
         } completion:^(BOOL finished) {
             
         }];
    }];
    
//    switch (ges.state) {
//        case UIGestureRecognizerStateBegan:
//        {
//
//        }
//            break;
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//        {
//            [UIView animateWithDuration:0.35 animations:^{
//                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
//            } completion:^(BOOL finished) {
//
//            }];
//        }
//            break;
//        default:
//            break;
//    }
}



- (void)tapBGLayer:(UITapGestureRecognizer *)tap {
    if (_isClickBGDismiss) {
        [self dismiss];
    }
    
    if (self.bgClickBlock) {
        self.bgClickBlock();
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:_backgroundView];
    location = [_customView.layer convertPoint:location fromLayer:_backgroundView.layer];
    return ![_customView.layer containsPoint:location];
}

- (void)hanlePopAnimationWithDuration:(NSTimeInterval)duration popStyle:(LSTPopStyle)popStyle {
    __weak typeof(self) ws = self;
    switch (popStyle) {
        case LSTPopStyleScale:// < 缩放动画，先放大，后恢复至原大小
        {
            [self animationWithLayer:_customView.layer duration:((0.3*duration)/0.7) values:@[@0.0, @1.2, @1.0]]; // 另外一组动画值(the other animation values) @[@0.0, @1.2, @0.9, @1.0]
        }
            break;
        case LSTPopStyleSmoothFromTop:
        case LSTPopStyleSmoothFromBottom:
        case LSTPopStyleSmoothFromLeft:
        case LSTPopStyleSmoothFromRight:
        case LSTPopStyleSpringFromTop:
        case LSTPopStyleSpringFromLeft:
        case LSTPopStyleSpringFromBottom:
        case LSTPopStyleSpringFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (popStyle == LSTPopStyleSmoothFromTop||popStyle == LSTPopStyleSpringFromTop) {
                self.customView.layer.position = CGPointMake(startPosition.x, -startPosition.y);
            } else if (popStyle == LSTPopStyleSmoothFromLeft||popStyle == LSTPopStyleSpringFromLeft) {
                self.customView.layer.position = CGPointMake(-startPosition.x, startPosition.y);
            } else if (popStyle == LSTPopStyleSmoothFromBottom||popStyle == LSTPopStyleSpringFromBottom) {
                self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + self.customView.height);
            } else {
                self.customView.layer.position = CGPointMake(CGRectGetMaxX(self.frame) + self.customView.width*0.5 , startPosition.y);
            }
            CGFloat damping = 1.0;
            if (popStyle == LSTPopStyleSpringFromTop||
                popStyle == LSTPopStyleSpringFromTop||
                popStyle == LSTPopStyleSpringFromTop||
                popStyle == LSTPopStyleSpringFromTop) {
                damping = 0.65;
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                ws.customView.layer.position = startPosition;
            } completion:nil];
        }
            break;
        case LSTPopStyleCardDropFromLeft:
        case LSTPopStyleCardDropFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (popStyle == LSTPopStyleCardDropFromLeft) {
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
                ws.customView.layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS((popStyle == LSTPopStyleCardDropFromRight) ? 5.5 : -5.5), 0, 0, 0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.2 animations:^{
                    ws.customView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS((popStyle == LSTPopStyleCardDropFromRight) ? -1.0 : 1.0));
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

- (void)hanleDismissAnimationWithDuration:(NSTimeInterval)duration withDismissStyle:(LSTDismissStyle)dismissStyle
{
    __weak typeof(self) ws = self;
    switch (dismissStyle) {
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
            if (dismissStyle == LSTDismissStyleDropToTop) {
                endPosition = CGPointMake(startPosition.x, -startPosition.y);
            } else if (dismissStyle == LSTDismissStyleDropToBottom) {
                endPosition = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + startPosition.y);
            } else if (dismissStyle == LSTDismissStyleDropToLeft) {
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
                if (dismissStyle == LSTDismissStyleCardDropToLeft) {
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

- (NSTimeInterval)getPopDefaultDuration:(LSTPopStyle)popStyle
{
    NSTimeInterval defaultDuration = 0.0f;
    if (popStyle == LSTPopStyleNO) {
        defaultDuration = 0.2f;
    } else if (popStyle == LSTPopStyleScale) {
        defaultDuration = 0.3f;
    } else if (popStyle == LSTPopStyleSmoothFromTop ||
               popStyle == LSTPopStyleSmoothFromLeft ||
               popStyle == LSTPopStyleSmoothFromBottom ||
               popStyle == LSTPopStyleSmoothFromRight ||
               popStyle == LSTPopStyleSpringFromTop ||
               popStyle == LSTPopStyleSpringFromLeft ||
               popStyle == LSTPopStyleSpringFromBottom ||
               popStyle == LSTPopStyleSpringFromRight ||
               popStyle == LSTPopStyleCardDropFromLeft ||
               popStyle == LSTPopStyleCardDropFromRight) {
        defaultDuration = 0.5f;
    }
    return defaultDuration;
}

- (NSTimeInterval)getDismissDefaultDuration:(LSTDismissStyle)dismissStyle
{
    NSTimeInterval defaultDuration = 0.0f;
    if (dismissStyle == LSTDismissStyleNO) {
        defaultDuration = 0.2f;
    } else if (dismissStyle == LSTDismissStyleScale) {
        defaultDuration = 0.2f;
    } else if (dismissStyle == LSTDismissStyleDropToTop ||
               dismissStyle == LSTDismissStyleDropToBottom ||
               dismissStyle == LSTDismissStyleDropToLeft ||
               dismissStyle == LSTDismissStyleDropToRight ||
               dismissStyle == LSTDismissStyleCardDropToLeft ||
               dismissStyle == LSTDismissStyleCardDropToRight ||
               dismissStyle == LSTDismissStyleCardDropToTop) {
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

