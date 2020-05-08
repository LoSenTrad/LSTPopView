//
//  LSTPopView.m
//  LoSenTrad
//
//  Created by LoSenTrad on 2020/2/22.
//

#import "LSTPopView.h"
#import "UIView+LSTView.h"
#import "UIColor+LSTColor.h"
#import "LSTPopViewManager.h"
#import <objc/runtime.h>


// 角度转弧度
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface LSTPopView ()<UIGestureRecognizerDelegate>

///** 内容视图 */
//@property (nonatomic, strong) UIView *contentView;
/** 背景层 */
@property (nonatomic, strong) UIView *backgroundView;
/** 自定义视图 */
@property (nonatomic, strong) UIView *customView;
/** 规避键盘偏移量 */
@property (nonatomic, assign) CGFloat avoidKeyboardOffset;
/**
 弹框容器
 默认是app UIWindow 可指定view作为容器
 */
@property (nonatomic,weak) UIView *parentView;

/** 是否弹出键盘 */
@property (nonatomic,assign,readonly) BOOL isShowKeyboard;




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
    _isClickBgDismiss = NO;
    _isObserverOrientationChange = NO;
    _bgAlpha = 0.25;
    _popStyle = LSTPopStyleNO;
    _dismissStyle = LSTDismissStyleNO;
    _popDuration = -0.1f;
    _dismissDuration = -0.1f;
    _hemStyle = LSTHemStyleCenter;
    _adjustX = 0;
    _adjustY = 0;
    _isClickFeedback = NO;
    _isAvoidKeyboard = YES;
    _avoidKeyboardSpace = 10;
    _isClickFeedback = NO;
    _bgColor = [UIColor blackColor];
    _identifier = @"";
    _isShowKeyboard = NO;
    _isStackSingleShow = NO;
    _showTime = 0.0;
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView {
    return [self initWithCustomView:customView popStyle:LSTPopStyleNO dismissStyle:LSTDismissStyleNO];
}


+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle {
    
    return [self initWithCustomView:customView
                         parentView:nil
                           popStyle:popStyle
                       dismissStyle:dismissStyle];
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                 parentView:(UIView *)parentView
                                   popStyle:(LSTPopStyle)popStyle
                               dismissStyle:(LSTDismissStyle)dismissStyle {
    // 检测自定义视图是否存在(check customView is exist)
    if (!customView) {
        return nil;
    }
    
    CGRect popViewFrame = CGRectZero;
    if (parentView) {
        popViewFrame =  parentView.bounds;
    }else {
        popViewFrame =  CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    }
        
    LSTPopView *popView = [[LSTPopView alloc] initWithFrame:popViewFrame];
    popView.parentView = parentView?parentView:[UIApplication sharedApplication].keyWindow;
    popView.customView = customView;
    popView.backgroundView = [[UIView alloc] initWithFrame:popView.bounds];
    popView.backgroundColor = [UIColor clearColor];
    popView.backgroundView.backgroundColor = [UIColor clearColor];
    popView.popStyle = popStyle;
    popView.dismissStyle = dismissStyle;
    
    [popView addSubview:popView.backgroundView];
    [popView addSubview:customView];
    
    
    //背景添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(popViewBgViewTap:)];
    [popView.backgroundView addGestureRecognizer:tap];
    
 
    UILongPressGestureRecognizer *customViewLP = [[UILongPressGestureRecognizer alloc] initWithTarget:popView action:@selector(bgLongPressEvent:)];
    [popView.backgroundView addGestureRecognizer:customViewLP];
    
//    UITapGestureRecognizer *customViewTap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(customViewClickEvent:)];
//    [popView.customView addGestureRecognizer:customViewTap];
//
    
    [[NSNotificationCenter defaultCenter] addObserver:popView selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:popView selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //监听customView frame
     [popView.customView addObserver:popView forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
     
    return popView;
}

- (void)dealloc {
    
    [self.customView removeObserver:self forKeyPath:@"frame"];
    
    [LSTPopViewManager removePopView:self];
    if ([self.delegate respondsToSelector:@selector(lst_PopViewDidDismiss)]) {
        [self.delegate lst_PopViewDidDismiss];
    }
    if (self.popViewDidDismiss) {
        self.popViewDidDismiss();
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
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
}

- (void)setAdjustY:(CGFloat)adjustY {
    _adjustY = adjustY;
    
    [self setCustomViewFrame];
}



- (void)setIsObserverOrientationChange:(BOOL)isObserverOrientationChange {
    _isObserverOrientationChange = isObserverOrientationChange;
    
    if (_isObserverOrientationChange) {
        
        [self statusBarOrientationChange];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

- (void)setBgAlpha:(CGFloat)bgAlpha {
    _bgAlpha = (bgAlpha <= 0.0f) ? 0.0f : ((bgAlpha > 1.0) ? 1.0 : bgAlpha);
    
}

- (void)setIsClickFeedback:(BOOL)isClickFeedback {
    _isClickFeedback = isClickFeedback;
}

- (void)setIsHideBg:(BOOL)isHideBg {
    _isHideBg = isHideBg;
    if (isHideBg) {
        self.backgroundView.hidden = YES;
    }else {
        self.backgroundView.hidden = NO;
    }
}

- (void)setShowTime:(NSTimeInterval)showTime {
    _showTime = showTime;
    
}

#pragma mark - ***** 公有api *****

- (void)pop {
    [self popWithPopStyle:self.popStyle duration:self.popDuration];
}
/// 打开popView 带动画
/// @param popStyle 优先级高于popStyle 局部起作用
- (void)popWithPopStyle:(LSTPopStyle)popStyle {
    
    [self popWithPopStyle:popStyle duration:self.popDuration];
    
}
/// 打开popView 带动画
/// @param popStyle 优先级高于popStyle 局部起作用
/// @param duration 优先级高于popDuration 局部起作用
- (void)popWithPopStyle:(LSTPopStyle)popStyle duration:(NSTimeInterval)duration {

    [self setCustomViewFrame];
    [self.parentView addSubview:self];
    
    //处理隐藏倒数第二个popView
    if (self.isStackSingleShow) {
        NSArray *popViewArr = [LSTPopViewManager getAllPopViewForPopView:self];
        if (popViewArr.count>=1) {
            NSValue *v = popViewArr[popViewArr.count-1];
            LSTPopView *lastPopView = v.nonretainedObjectValue;
            if (lastPopView.isShowKeyboard) {
                [lastPopView endEditing:YES];
            }
            [UIView animateWithDuration:[self getPopDefaultDuration:popStyle]*0.5 animations:^{
                lastPopView.alpha = 0.0;
            }];
        }
    }
   
    
    
    //将要显示
    if ([self.delegate respondsToSelector:@selector(lst_PopViewWillPop)]) {
        [self.delegate lst_PopViewWillPop];
    }
    if (self.popViewWillPop) {
        self.popViewWillPop();
    }
    

    
    if (self.isHideBg) {
        self.backgroundView.hidden = YES;
    }else {
        self.backgroundView.hidden = NO;
    }

    __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getPopDefaultDuration:popStyle];
    NSTimeInterval resDuration = (duration < 0.0f) ? defaultDuration : duration;
    if (popStyle == LSTPopStyleNO) {//无动画
        
        
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        self.customView.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            
            self.backgroundView.backgroundColor =[self getNewColorWith:self.bgColor alpha:self.bgAlpha];
            self.customView.alpha = 1.0f;
        }];
        
        
    } else {//有动画
        
        //设置背景过渡动画
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        [UIView animateWithDuration:resDuration animations:^{
            ws.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:self.bgAlpha];
        }];
        
        //自定义view过渡动画
        [self hanlePopAnimationWithDuration:resDuration*0.8 popStyle:popStyle];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //消失完毕
        if ([ws.delegate respondsToSelector:@selector(lst_PopViewDidPop)]) {
            [ws.delegate lst_PopViewDidPop];
        }
        if (ws.popViewDidPop) {
            ws.popViewDidPop();
        }
    });
    [LSTPopViewManager savePopView:self];
}

- (void)dismiss {
    [self dismissWithDismissStyle:self.dismissStyle duration:self.dismissDuration];
}

/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle {
    [self dismissWithDismissStyle:dismissStyle duration:self.dismissDuration];
}
/// 关闭popView 带动画
/// @param dismissStyle 优先级高于dismissStyle 局部起作用
/// @param duration 优先级高于dismissDuration 局部起作用
- (void)dismissWithDismissStyle:(LSTDismissStyle)dismissStyle duration:(NSTimeInterval)duration {
        
    if ([self.delegate respondsToSelector:@selector(lst_PopViewWillDismiss)]) {
        [self.delegate lst_PopViewWillDismiss];
    }
    if (self.popViewWillDismiss) {
        self.popViewWillDismiss();
    }
    
    __block __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getDismissDefaultDuration:dismissStyle];
    NSTimeInterval resDuration = (duration < 0.0f) ? defaultDuration : duration;
    if (dismissStyle == LSTPopStyleNO) {
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
            self.customView.alpha = 0.0f;
        }];
    } else {//有动画
        [UIView animateWithDuration:resDuration*0.8 animations:^{
            ws.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        }];
        [self hanleDismissAnimationWithDuration:resDuration withDismissStyle:dismissStyle];
    }
    
    if (ws.isObserverOrientationChange) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration*0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     
        
      //  popView出栈
        NSArray *popViewArr = [LSTPopViewManager getAllPopViewForPopView:self];
        if (popViewArr.count>=2) {
            NSValue *v = popViewArr[popViewArr.count-2];
            LSTPopView *lastPopView = v.nonretainedObjectValue;
            [UIView animateWithDuration:0.25 animations:^{
                lastPopView.alpha = 1;
            }];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ws removeFromSuperview];
       
    });
    
    
}

#pragma mark - ***** 键盘弹出/收回 *****
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    _isShowKeyboard = YES;
    
    if (!self.isAvoidKeyboard) {
        return;
    }
    
    CGFloat customViewMaxY = self.customView.bottom+self.avoidKeyboardSpace;
    
    //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //取得键盘最后的frame(根据userInfo的key----UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 227}, {320, 253}}";)
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardMaxY = keyboardFrame.origin.y;
    
    //    CGFloat transformY = keyboardMaxY - self.frame.size.height;
    
    if (keyboardMaxY<customViewMaxY) {//键盘遮挡到弹框
        
        self.isAvoidKeyboard = YES;
        self.avoidKeyboardOffset = customViewMaxY - keyboardMaxY ;
        //执行动画
        [UIView animateWithDuration:duration animations:^{
            self.customView.y = self.customView.y - self.avoidKeyboardOffset;
        }];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification{
    
    _isShowKeyboard = NO;
    
    if (!self.isAvoidKeyboard) {
        return;
    }
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.customView.y = self.customView.y + self.avoidKeyboardOffset;
    }];
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
            if (!CGSizeEqualToSize(newFrame.size, oldFrame.size)) {
                [self setCustomViewFrame];
            }
        }
    }
}

//按钮的压下事件 按钮缩小
- (void)bgLongPressEvent:(UIGestureRecognizer *)ges {
  
    if ([self.delegate respondsToSelector:@selector(lst_PopViewBgLongPress)]) {
        [self.delegate lst_PopViewBgLongPress];
    }
    if (self.bgLongPressBlock) {
        self.bgLongPressBlock();
    }

//    switch (ges.state) {
//        case UIGestureRecognizerStateBegan:
//        {
//            CGFloat scale = 0.95;
//            [UIView animateWithDuration:0.35 animations:^{
//                ges.view.transform = CGAffineTransformMakeScale(scale, scale);
//            }];
//        }
//            break;
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//        {
//            [UIView animateWithDuration:0.35 animations:^{
//                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
//            } completion:^(BOOL finished) {
//            }];
//        }
//            break;
//
//        default:
//            break;
//    }
}

- (void)customViewClickEvent:(UIGestureRecognizer *)ges {
    
    if (self.isClickFeedback) {
        CGFloat scale = 0.95;
        
        [UIView animateWithDuration:0.25 animations:^{
            ges.view.transform = CGAffineTransformMakeScale(scale, scale);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    
  
    
}



- (void)popViewBgViewTap:(UITapGestureRecognizer *)tap {

   
    if ([self.delegate respondsToSelector:@selector(lst_PopViewBgClick)]) {
        [self.delegate lst_PopViewBgClick];
    }
    if (self.bgClickBlock) {
        if (self.isShowKeyboard) {
            [self endEditing:YES];
        }
        self.bgClickBlock();
    }
    
    if (_isClickBgDismiss) {
        [self dismiss];
    }
}


- (void)hanlePopAnimationWithDuration:(NSTimeInterval)duration
                             popStyle:(LSTPopStyle)popStyle {
    
    self.alpha = 0;
    
    [UIView animateWithDuration:duration*0.5 animations:^{
        self.alpha = 1;
    }];
    
    
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
                self.customView.layer.position = CGPointMake(startPosition.x, -_customView.height*0.5);
            } else if (popStyle == LSTPopStyleSmoothFromLeft||popStyle == LSTPopStyleSpringFromLeft) {
                self.customView.layer.position = CGPointMake(-_customView.width*0.5, startPosition.y);
            } else if (popStyle == LSTPopStyleSmoothFromBottom||popStyle == LSTPopStyleSpringFromBottom) {
                self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + self.customView.height*0.5);
            } else {
                self.customView.layer.position = CGPointMake(CGRectGetMaxX(self.frame) + self.customView.width*0.5 , startPosition.y);
            }
            CGFloat damping = 1.0;
            if (popStyle == LSTPopStyleSpringFromTop||
                popStyle == LSTPopStyleSpringFromLeft||
                popStyle == LSTPopStyleSpringFromBottom||
                popStyle == LSTPopStyleSpringFromRight) {
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
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -_customView.height*0.5);
                self.customView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(15.0));
            } else {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -_customView.height*0.5);
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

- (void)hanleDismissAnimationWithDuration:(NSTimeInterval)duration
                         withDismissStyle:(LSTDismissStyle)dismissStyle {
    
    [UIView animateWithDuration:duration*0.8 animations:^{
        self.alpha = 0;
    }];
    
    __weak typeof(self) ws = self;
    switch (dismissStyle) {
        case LSTDismissStyleScale:
        {
            [self animationWithLayer:self.customView.layer duration:((0.2*duration)/0.8) values:@[@1.0, @0.66, @0.33, @0.01]];
        }
            break;
        case LSTDismissStyleSmoothToTop:
        case LSTDismissStyleSmoothToBottom:
        case LSTDismissStyleSmoothToLeft:
        case LSTDismissStyleSmoothToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = self.customView.layer.position;
            if (dismissStyle == LSTDismissStyleSmoothToTop) {
                endPosition = CGPointMake(startPosition.x, -(_customView.height*0.5));
            } else if (dismissStyle == LSTDismissStyleSmoothToBottom) {
                endPosition = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + _customView.height*0.5);
            } else if (dismissStyle == LSTDismissStyleSmoothToLeft) {
                endPosition = CGPointMake(-_customView.width*0.5, startPosition.y);
            } else {
                endPosition = CGPointMake(CGRectGetMaxX(self.frame) + _customView.width*0.5, startPosition.y);
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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

- (NSTimeInterval)getPopDefaultDuration:(LSTPopStyle)popStyle {
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

- (NSTimeInterval)getDismissDefaultDuration:(LSTDismissStyle)dismissStyle {
    NSTimeInterval defaultDuration = 0.0f;
    if (dismissStyle == LSTDismissStyleNO) {
        defaultDuration = 0.25f;
    } else if (dismissStyle == LSTDismissStyleScale) {
        defaultDuration = 0.25f;
    } else if (dismissStyle == LSTDismissStyleSmoothToTop ||
               dismissStyle == LSTDismissStyleSmoothToBottom ||
               dismissStyle == LSTDismissStyleSmoothToLeft ||
               dismissStyle == LSTDismissStyleSmoothToRight ||
               dismissStyle == LSTDismissStyleCardDropToLeft ||
               dismissStyle == LSTDismissStyleCardDropToRight ||
               dismissStyle == LSTDismissStyleCardDropToTop) {
        defaultDuration = 1.0f;
    }
    return defaultDuration;
}

- (void)animationWithLayer:(CALayer *)layer duration:(CGFloat)duration values:(NSArray *)values {
    CAKeyframeAnimation *KFAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    KFAnimation.duration = duration;
    KFAnimation.removedOnCompletion = NO;
    KFAnimation.fillMode = kCAFillModeForwards;
    KFAnimation.delegate = self;
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
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    
}

// 改变UIColor的Alpha
- (UIColor *)getNewColorWith:(UIColor *)color alpha:(CGFloat)alpha {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat resAlpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&resAlpha];
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return newColor;
}

- (void)startTimer {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0 target:self selector:@selector(handleHideTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

- (void)handleHideTimer:(NSTimer *)timer {
    
}

#pragma mark - ***** 监听横竖屏方向改变 *****

- (void)statusBarOrientationChange:(NSNotification *)notification {
    //    CGRect startCustomViewRect = self.customView.frame;
    //    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    //    self.backgroundView.frame = self.bounds;
    //    self.backgroundView.frame = self.bounds;
    //    self.customView.frame = startCustomViewRect;
    //    self.customView.center = self.center;
}

- (void)statusBarOrientationChange {
    ////    CGRect startCustomViewRect = self.customView.frame;
    //    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    //    self.backgroundView.frame = self.bounds;
    //    self.backgroundView.frame = self.bounds;
    ////    self.customView.frame = self.bounds;
    //    self.customView.center = self.center;
}

@end

