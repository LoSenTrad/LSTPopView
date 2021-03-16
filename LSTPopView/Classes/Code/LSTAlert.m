//
//  LSTAlert.m
//  LSTPopView
//
//  Created by Yegq on 2021/3/16.
//

#import "LSTAlert.h"

@interface LSTConfig : NSObject

#pragma mark - ===================   属性设置   ===================
#pragma mark 基础属性
/// 代理 支持多代理
@property (nonatomic , strong) NSHashTable * delegate;
/// 标识 默认为空
@property (nonatomic , strong) NSString * identifier;
/// 弹窗容器
@property (nonatomic , weak  ) UIView * parentView;
/// 自定义view
@property (nonatomic , weak  ) UIView * currCustomView;
/// 弹窗位置 默认LSTHemStyleCenter
@property (nonatomic , assign) LSTHemStyle hemStyle;
/// 显示时动画弹窗样式 默认LSTPopStyleFade
@property (nonatomic , assign) LSTPopStyle popStyle;
/// 移除时动画弹窗样式 默认LSTDismissStyleFade
@property (nonatomic , assign) LSTDismissStyle dismissStyle;
/// 显示时动画时长，> 0。不设置则使用默认的动画时长 设置成LSTPopStyleNO, 该属性无效
@property (nonatomic , assign) NSTimeInterval popDuration;
/// 隐藏时动画时长，>0。不设置则使用默认的动画时长  设置成LSTDismissStyleNO, 该属性无效
@property (nonatomic , assign) NSTimeInterval dismissDuration;
/// 弹窗水平方向(X)偏移量校准 默认0
@property (nonatomic , assign) CGFloat adjustX;
/// 弹窗垂直方向(Y)偏移量校准 默认0
@property (nonatomic , assign) CGFloat adjustY;
/// 背景颜色 默认rgb(0,0,0) 透明度0.3
@property (nonatomic , strong) UIColor * bgColor;
/// 显示时背景的透明度，取值(0.0~1.0)，默认为0.3
@property (nonatomic , assign) CGFloat bgAlpha;
/// 是否隐藏背景 默认NO
@property (nonatomic , assign) BOOL isHideBg;
/// 显示时点击背景是否移除弹窗，默认为NO。
@property (nonatomic , assign) BOOL isClickBgDismiss;
/// 是否监听屏幕旋转，默认为YES
@property (nonatomic , assign) BOOL isObserverScreenRotation;
/// 是否支持点击回馈 默认NO (暂时关闭)
@property (nonatomic , assign) BOOL isClickFeedback;
/// 是否规避键盘 默认YES
@property (nonatomic , assign) BOOL isAvoidKeyboard;
/// 弹窗和键盘的距离 默认10
@property (nonatomic , assign) CGFloat avoidKeyboardSpace;
/// 显示多长时间 默认0 不会消失
@property (nonatomic , assign) NSTimeInterval showTime;
/// 自定view圆角方向设置  默认UIRectCornerAllCorners  当cornerRadius>0时生效
@property (nonatomic , assign) UIRectCorner rectCorners;
/// 自定义view圆角大小, 默认 0
@property (nonatomic , assign) CGFloat cornerRadius;
/// 弹出震动反馈 默认NO iOS10+ 系统才有此效果
@property (nonatomic , assign) BOOL isImpactFeedback;

#pragma mark 群组相关属性
/// 群组标识 统一给弹窗编队 方便独立管理 默认为nil,统一全局处理
@property (nonatomic , strong) NSString * groupId;
/// 是否堆叠 默认NO  如果是YES  priority优先级不生效
@property (nonatomic , assign) BOOL isStack;
/// 单显示 默认NO  只会显示优先级最高的popView
@property (nonatomic , assign) BOOL isSingle;
/// 优先级 范围0~1000 (默认0,遵循先进先出) isStack和isSingle为NO的时候生效
@property (nonatomic , assign) CGFloat priority;
#pragma mark 拖拽手势相关属性
/// 拖拽方向 默认 不可拖拽
@property (nonatomic , assign) LSTDragStyle dragStyle;
/// X轴或者Y轴拖拽移除临界距离 范围(0 ~ +∞)  默认0 不拖拽移除  基使用于dragStyle
@property (nonatomic , assign) CGFloat dragDistance;
/// 拖拽移除动画类型 默认同dismissStyle
@property (nonatomic , assign) LSTDismissStyle dragDismissStyle;
/// 拖拽消失动画时间 默认同 dismissDuration
@property (nonatomic , assign) NSTimeInterval dragDismissDuration;
/// 拖拽复原动画时间 默认0.25s
@property (nonatomic , assign) NSTimeInterval dragReboundTime;
/// 轻扫方向 默认 不可轻扫  前提开启dragStyle
@property (nonatomic , assign) LSTSweepStyle sweepStyle;
/// 轻扫速率 控制轻扫移除 默认1000  基于使用sweepStyle
@property (nonatomic , assign) CGFloat swipeVelocity;
/// 轻扫移除的动画 默认LSTSweepDismissStyleVelocity
@property (nonatomic , assign) LSTSweepDismissStyle sweepDismissStyle;

#pragma mark - ===================   交互回调   ===================
/// 点击背景
@property (nonatomic , copy  ) Lst_Block_Void bgClickBlock;
/// 长按背景
@property (nonatomic , copy  ) Lst_Block_Void bgLongPressBlock;
/// 弹窗pan手势偏移量
@property (nonatomic , copy  ) Lst_Block_Point panOffsetBlock;

#pragma mark - ===================   以下键盘弹出/收起 第三方键盘会多次回调(百度,搜狗测试得出), 原生键盘回调一次   ===================
/// 键盘将要弹出
@property (nonatomic , copy  ) Lst_Block_Void keyboardWillShowBlock;
/// 键盘弹出完毕
@property (nonatomic , copy  ) Lst_Block_Void keyboardDidShowBlock;
/// 键盘frame将要改变
@property (nonatomic , copy  ) Lst_Block_KeyBoardChange keyboardFrameWillChangeBlock;
/// 键盘frame改变完毕
@property (nonatomic , copy  ) Lst_Block_KeyBoardChange keyboardFrameDidChangeBlock;
/// 键盘将要收起
@property (nonatomic , copy  ) Lst_Block_Void keyboardWillHideBlock;
/// 键盘收起完毕
@property (nonatomic , copy  ) Lst_Block_Void keyboardDidHideBlock;

#pragma mark - ===================   生命周期回调(Block)   ===================
/// 将要显示 回调
@property (nonatomic , copy  ) Lst_Block_Void popViewWillPopBlock;
/// 已经显示完毕 回调
@property (nonatomic , copy  ) Lst_Block_Void popViewDidPopBlock;
/// 将要开始移除 回调
@property (nonatomic , copy  ) Lst_Block_Void popViewWillDismissBlock;
/// 已经移除完毕 回调
@property (nonatomic , strong) NSHashTable * popViewDidDismissBlocks;
/// 倒计时 回调
@property (nonatomic , copy  ) Lst_Block_AlertCountDown popViewCountDownBlock;
@end

@implementation LSTConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData
{
    _hemStyle                 = LSTHemStyleCenter;
    _popStyle                 = LSTPopStyleFade;
    _dismissStyle             = LSTDismissStyleFade;
    _bgColor                  = UIColor.blackColor;
    _bgAlpha                  = 0.3;
    _isObserverScreenRotation = YES;
    _isAvoidKeyboard          = YES;
    _avoidKeyboardSpace       = 10;
}

- (NSHashTable *)delegate
{
    if (_delegate) return _delegate;
    
    _delegate = [NSHashTable hashTableWithOptions:(NSPointerFunctionsWeakMemory)];
    
    return _delegate;
}

- (NSHashTable *)popViewDidDismissBlocks
{
    if (_popViewDidDismissBlocks) return _popViewDidDismissBlocks;
    
    _popViewDidDismissBlocks = [NSHashTable hashTableWithOptions:(NSPointerFunctionsWeakMemory)];
    
    return _popViewDidDismissBlocks;
}

@end

#pragma mark - ===================   LSTAlert   ===================
#pragma mark - ===================   LSTAlert   ===================
@interface LSTAlert ()

@property (nonatomic , weak  ) LSTPopView * popView;

@property (nonatomic , strong) LSTConfig * config;

@end

@implementation LSTAlert

+ (instancetype)alert
{
    LSTAlert *alert = LSTAlert.alloc.init;
    
    return alert;
}

- (LSTConfig *)config
{
    if (_config) return _config;
    
    _config = LSTConfig.alloc.init;
    
    return _config;
}

#define lst_property_block(class, subclass, proprety) \
- (class)proprety\
{\
    return ^(subclass object) {\
        self.config.proprety = object;\
        return self;\
    };\
}

- (LSTAlert_Delegate)delegate
{
    return ^(id<LSTPopViewProtocol> object) {
        if (object) {
            [self.config.delegate addObject:object];
        }
        return self;
    };
}

lst_property_block(LSTAlert_String, id, identifier);
lst_property_block(LSTAlert_View,   id, parentView);


- (LSTAlert_CustomView)currCustomView{
    
    return ^(Lst_Block_View_Void object){
        self.config.currCustomView = object();
        return self;
    };
    
}

lst_property_block(LSTAlert_HemStyle,       LSTHemStyle, hemStyle);
lst_property_block(LSTAlert_PopStyle,       LSTPopStyle, popStyle);
lst_property_block(LSTAlert_DismissStyle,   LSTDismissStyle, dismissStyle);
lst_property_block(LSTAlert_Interval,       NSTimeInterval, popDuration);
lst_property_block(LSTAlert_Interval,       NSTimeInterval, dismissDuration);
lst_property_block(LSTAlert_Float,          CGFloat, adjustX);
lst_property_block(LSTAlert_Float,          CGFloat, adjustY);
lst_property_block(LSTAlert_Color,          id, bgColor);
lst_property_block(LSTAlert_Float,          CGFloat, bgAlpha);
lst_property_block(LSTAlert_BOOL,           BOOL, isHideBg);
lst_property_block(LSTAlert_BOOL,           BOOL,isClickBgDismiss);
lst_property_block(LSTAlert_BOOL,           BOOL, isObserverScreenRotation);
lst_property_block(LSTAlert_BOOL,           BOOL, isClickFeedback);
lst_property_block(LSTAlert_BOOL,           BOOL, isAvoidKeyboard);
lst_property_block(LSTAlert_Float,          CGFloat, avoidKeyboardSpace);
lst_property_block(LSTAlert_Interval,       NSTimeInterval, showTime);
lst_property_block(LSTAlert_Corner,         UIRectCorner, rectCorners);
lst_property_block(LSTAlert_Float,          CGFloat, cornerRadius);
lst_property_block(LSTAlert_BOOL,           BOOL, isImpactFeedback);

lst_property_block(LSTAlert_String,         id, groupId);
lst_property_block(LSTAlert_BOOL,           BOOL, isStack);
lst_property_block(LSTAlert_BOOL,           BOOL, isSingle);
lst_property_block(LSTAlert_Float,          CGFloat, priority);
lst_property_block(LSTAlert_DragStyle,      LSTDragStyle, dragStyle);
lst_property_block(LSTAlert_Float, CGFloat, dragDistance);
lst_property_block(LSTAlert_DismissStyle, LSTDismissStyle, dragDismissStyle);
lst_property_block(LSTAlert_Interval, NSTimeInterval, dragDismissDuration);
lst_property_block(LSTAlert_SweepStyle, LSTSweepStyle, sweepStyle);
lst_property_block(LSTAlert_Float, CGFloat, swipeVelocity);
lst_property_block(LSTAlert_SweepDismissStyle, LSTSweepDismissStyle, sweepDismissStyle);

lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, bgClickBlock);
lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, bgLongPressBlock);
lst_property_block(LSTAlert_Block_Point, Lst_Block_Point, panOffsetBlock);

lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, keyboardWillShowBlock);
lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, keyboardDidShowBlock);
lst_property_block(LSTAlert_Block_KeyBoardChange, Lst_Block_KeyBoardChange, keyboardFrameWillChangeBlock);
lst_property_block(LSTAlert_Block_KeyBoardChange, Lst_Block_KeyBoardChange, keyboardFrameDidChangeBlock);
lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, keyboardWillHideBlock);
lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, keyboardDidHideBlock);

lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, popViewWillPopBlock);
lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, popViewDidPopBlock);
lst_property_block(LSTAlert_Block_Void, Lst_Block_Void, popViewWillDismissBlock);

- (LSTAlert_Block_Void)popViewDidDismissBlock
{
    return ^(Lst_Block_Void object) {
        if (object) {
            [self.config.popViewDidDismissBlocks addObject:object];
        }
        return self;
    };
}

lst_property_block(LSTAlert_Block_AlertCountDown, Lst_Block_AlertCountDown, popViewCountDownBlock);

- (LSTAlert_Void)pop
{
    return ^ {
        [self show];
        
        return self;
    };
}

- (LSTAlert_Void)dismiss
{
    return ^ {
        [self hide];
        
        return self;
    };
}

- (void)hide
{
    [_popView dismiss];
}

- (void)show
{
    LSTPopView * popView = ({
        LSTConfig *config = self.config;
        
        
        LSTPopView * object = [LSTPopView initWithCustomView:config.currCustomView parentView:config.parentView popStyle:config.popStyle dismissStyle:config.dismissStyle];
        for (id<LSTPopViewProtocol> de in config.delegate) {
            object.delegate = de;
        }
        object.identifier                   = config.identifier;
        object.hemStyle                     = config.hemStyle;
        object.popStyle                     = config.popStyle;
        object.dismissStyle                 = config.dismissStyle;
        object.popDuration                  = config.popDuration;
        object.dismissDuration              = config.dismissDuration;
        object.adjustX                      = config.adjustX;
        object.adjustY                      = config.adjustY;
        object.bgColor                      = config.bgColor;
        object.bgAlpha                      = config.bgAlpha;
        object.isHideBg                     = config.isHideBg;
        object.isClickBgDismiss             = config.isClickBgDismiss;
        object.isObserverScreenRotation     = config.isObserverScreenRotation;
        object.isClickFeedback              = config.isClickFeedback;
        object.isAvoidKeyboard              = config.isAvoidKeyboard;
        object.avoidKeyboardSpace           = config.avoidKeyboardSpace;
        object.showTime                     = config.showTime;
        object.rectCorners                  = config.rectCorners;
        object.cornerRadius                 = config.cornerRadius;
        object.isImpactFeedback             = config.isImpactFeedback;
        object.groupId                      = config.groupId;
        object.isStack                      = config.isStack;
        object.isSingle                     = config.isSingle;
        object.priority                     = config.priority;
        object.dragStyle                    = config.dragStyle;
        object.dragDistance                 = config.dragDistance;
        object.dragDismissStyle             = config.dragDismissStyle;
        object.dragDismissDuration          = config.dragDismissDuration;
        object.dragReboundTime              = config.dragReboundTime;
        object.sweepStyle                   = config.sweepStyle;
        object.swipeVelocity                = config.swipeVelocity;
        object.sweepDismissStyle            = config.sweepDismissStyle;
        object.bgClickBlock                 = config.bgClickBlock;
        object.bgLongPressBlock             = config.bgLongPressBlock;
        object.panOffsetBlock               = config.panOffsetBlock;
        object.keyboardWillShowBlock        = config.keyboardWillShowBlock;
        object.keyboardDidShowBlock         = config.keyboardDidShowBlock;
        object.keyboardFrameWillChangeBlock = config.keyboardFrameWillChangeBlock;
        object.keyboardFrameDidChangeBlock  = config.keyboardFrameDidChangeBlock;
        object.keyboardWillHideBlock        = config.keyboardWillHideBlock;
        object.keyboardDidHideBlock         = config.keyboardDidHideBlock;
        object.popViewWillPopBlock          = config.popViewWillPopBlock;
        object.popViewDidPopBlock           = config.popViewDidPopBlock;
        object.popViewWillDismissBlock      = config.popViewWillDismissBlock;
        for (Lst_Block_Void block in config.popViewDidDismissBlocks) {
            if (block) {
                object.popViewDidDismissBlock = block;
            }
        }
        object.popViewCountDownBlock        = config.popViewCountDownBlock;
        
        object;
    });
    _popView = popView;
    [popView pop];
}

+ (NSArray <LSTPopView *>*)getAllPopView
{
    return LSTPopView.getAllPopView;
}

+ (NSArray <LSTPopView *>*)getAllPopViewForParentView:(UIView *)parentView
{
    return [LSTPopView getAllPopViewForParentView:parentView];
}

+ (NSArray <LSTPopView *>*)getAllPopViewForPopView:(UIView *)popView
{
    return [LSTPopView getAllPopViewForPopView:popView];
}

+ (LSTPopView *)getPopViewForKey:(NSString *)key
{
    return [LSTPopView getPopViewForKey:key];
}

+ (void)dismissAllAlert:(Lst_Block_Void)complete
{
    [LSTPopView removeAllPopViewComplete:complete];
}

+ (void)dismissAlertComplete:(Lst_Block_Void)complete
{
    [LSTPopView removeLastPopViewComplete:complete];
}

+ (void)dismissAlertForAlert:(LSTAlert *)alert complete:(Lst_Block_Void)complete
{
    [LSTPopView removePopView:alert.popView complete:complete];
}

+ (void)dismissAlertForKey:(NSString *)key complete:(Lst_Block_Void)complete
{
    [LSTPopView removePopViewForKey:key complete:complete];
}

+ (void)dismissAlertForPopView:(LSTPopView *)popView complete:(Lst_Block_Void)complete
{
    [LSTPopView removePopView:popView complete:complete];
}
@end

