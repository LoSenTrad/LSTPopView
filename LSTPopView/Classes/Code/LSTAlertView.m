//
//  LSTAlertView.m
//  LSTAlertView
//
//  Created by LoSenTrad on 2020/1/4.
//

#import "LSTAlertView.h"
#import "UIView+LSTView.h"
#import "NSString+LSTString.h"

@interface LSTAlertViewCell : UICollectionViewCell

/** <#.....#> */
@property (nonatomic,strong) LSTAlertViewAction *action;
/**  */
@property (nonatomic,strong) UILabel *titleLab;
/** <#.....#> */
@property (nonatomic,strong) UILabel *subTitleLab;
/** 分割线 */
@property (nonatomic,strong) UIView *cutView;
/** 分割线高度 */
@property (nonatomic, assign) CGFloat separatorHeight;


@end

@implementation LSTAlertViewCell


#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.separatorHeight = 0.333;
//        self.cutView.backgroundColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
        [self initSubViews];
    }
    return self;
}

#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setAction:(LSTAlertViewAction *)action {
    _action = action;
    
    [self setNeedsLayout];
    
  
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    _separatorHeight = separatorHeight;
    
    _cutView.height = separatorHeight;
}


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.subTitleLab];
    [self.contentView addSubview:self.cutView];
    self.contentView.clipsToBounds = YES;
    self.clipsToBounds = YES;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_action.actionView) {
        [self.titleLab removeFromSuperview];
        self.titleLab = nil;
        [self.subTitleLab removeFromSuperview];
        self.subTitleLab = nil;
        
        CGFloat actionViewW = _action.actionView.width<=0?self.contentView.width:_action.actionView.width;;
        CGFloat actionViewH = _action.actionView.height<=0?self.contentView.height:_action.actionView.height;
        
        [self.contentView addSubview:_action.actionView];
        
        _action.actionView.frame = CGRectMake(0, 0, actionViewW, actionViewH);
        _action.actionView.center = self.contentView.center;
        
    }else {
        
        [_action.actionView removeFromSuperview];

        CGFloat titleY = 0;
        CGFloat titleW = 0;
        CGFloat titleH = 0;
        
//        CGFloat subTitleY = 0;
        CGFloat subTitleW = 0;
        CGFloat subTitleH = 0;
        
        CGFloat pading = 3;
        
       

        
        if (_action.title.length>0 && _action.subTitle.length>0) {
            [self.contentView addSubview:self.titleLab];
            [self.contentView addSubview:self.subTitleLab];
            
            self.titleLab.text = _action.title;
            self.titleLab.font = _action.titleFont;
            self.titleLab.textColor = _action.titleColor;
            self.subTitleLab.text = _action.subTitle;
            self.subTitleLab.font = _action.subTitleFont;
            self.subTitleLab.textColor = _action.subTitleColor;
            
            titleW = self.contentView.width - 10 - 10;
            titleH = [self getHeightWithFont:self.titleLab.font andWidth:titleW andText:self.titleLab.text];
            subTitleH = [self.subTitleLab.text getHeightWithFont:self.subTitleLab.font andWidth:titleW];
            
            CGFloat allH = pading + titleH + subTitleH;
            
            CGFloat titleY = (self.contentView.height - allH)*0.5;
            
            _titleLab.frame = CGRectMake(10, titleY, self.contentView.width - 10 - 10, titleH);
            _subTitleLab.frame = CGRectMake(10, CGRectGetMaxY(_titleLab.frame)+pading, _titleLab.width, subTitleH);
            
        }else if (_action.title.length>0) {
            [self.contentView addSubview:self.titleLab];
            [self.subTitleLab removeFromSuperview];
            self.subTitleLab = nil;
            
            self.titleLab.text = _action.title;
            self.titleLab.font = _action.titleFont;
            self.titleLab.textColor = _action.titleColor;
            
            titleW = self.contentView.width - 10 - 10;
            titleH = [self getHeightWithFont:self.titleLab.font andWidth:titleW andText:self.titleLab.text];
            
            _titleLab.frame = CGRectMake(10, 0, self.contentView.width - 10 - 10, titleH);
            _titleLab.center = self.contentView.center;
            
        }else if (_action.subTitle.length>0) {
            [self.contentView addSubview:self.subTitleLab];
            [self.titleLab removeFromSuperview];
            self.titleLab = nil;
            
            self.subTitleLab.text = _action.subTitle;
            self.subTitleLab.font = _action.subTitleFont;
            self.subTitleLab.textColor = _action.subTitleColor;
            
            subTitleW = self.contentView.width - 10 - 10;
            subTitleH = [self.subTitleLab.text getHeightWithFont:self.subTitleLab.font andWidth:subTitleW];
            
            _subTitleLab.frame = CGRectMake(0, 0, _titleLab.width, subTitleH);
            _subTitleLab.center = self.contentView.center;
            
        }else {//都没有
            [self.titleLab removeFromSuperview];
            self.titleLab = nil;
            [self.subTitleLab removeFromSuperview];
            self.subTitleLab = nil;
        }
        
        
//        _titleLab.frame = CGRectMake(10, titleY, self.contentView.width - 10 - 10, titleH);
//
//        _subTitleLab.frame = CGRectMake(10, CGRectGetMaxY(_titleLab.frame)+pading, _titleLab.width, subTitleH);
    }
    
    
   
    _cutView.frame = CGRectMake(0, 0, self.contentView.width, self.separatorHeight);
    [self.contentView bringSubviewToFront:self.cutView];
}

#pragma mark - ***** other 其他 *****

///** 根据字符串获取宽度 (不适合富文本) */
//- (CGFloat)getWidthWithFont:(UIFont *)font {
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
//    label.text = self;
//    label.font = font;
//    [label sizeToFit];
//    return label.frame.size.width;
//}
/** 根据字符串获取高度(不适合富文本) */
- (CGFloat)getHeightWithFont:(UIFont *)font andWidth:(CGFloat)width andText:(NSString *)text{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = text;
    label.font = font;
    label.numberOfLines = 1;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UILabel *)titleLab {
    if(_titleLab) return _titleLab;
    _titleLab = [[UILabel alloc] init];
    _titleLab.backgroundColor = UIColor.clearColor;
    _titleLab.font = [UIFont systemFontOfSize:16];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.textColor = UIColor.blackColor;
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if(_subTitleLab) return _subTitleLab;
    _subTitleLab = [[UILabel alloc] init];
    _subTitleLab.backgroundColor = UIColor.clearColor;
    _subTitleLab.font = [UIFont systemFontOfSize:12];
    _subTitleLab.textAlignment = NSTextAlignmentCenter;
    _subTitleLab.textColor = UIColor.grayColor;
    return _subTitleLab;
}

- (UIView *)cutView {
    if(_cutView) return _cutView;
    _cutView = [[UIView alloc] init];
    _cutView.backgroundColor = UIColor.grayColor;
    return _cutView;
}



@end


@interface LSTAlertView () <UICollectionViewDelegate,UICollectionViewDataSource>


/** 内容 */
@property (nonatomic,strong) UIView *contentView;
/** <#.....#> */
@property (nonatomic,strong) NSMutableArray *actionMarr;


/** 顶部分割线 */
@property (nonatomic,strong) UIView *topCutView;
/** 竖分割线 */
@property (nonatomic,strong) UIView *vCutView;

/** <#.....#> */
@property (nonatomic,strong) UICollectionView *collectionView;
    
/** <#.....#> */
@property (nonatomic,strong) LSTPopView *popView;

@end

@implementation LSTAlertView


#pragma mark - ***** 初始化 *****

- (instancetype)init{
    if (self = [super init]) {
        self.size = CGSizeMake(270, 270);
        self.alertViewWith = 270;
        self.actionHeight = 50.0f;
        self.hemStyle = LSTHemStyleCenter;
        self.bgColor = UIColor.whiteColor;
        self.cornerRadius = 10.0f;
        self.separatorColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
        self.separatorHeight = 0.333;//系统标准
    }
    return self;
}


+ (instancetype)initAlertView {
    
    LSTAlertView *alertView = [[LSTAlertView alloc] initWithFrame:CGRectMake(0, 0, 270, 270)];
    return alertView;
    
}



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}



#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setBgColor:(UIColor *)bgColor {
    if (!bgColor) {return;}
    _bgColor = bgColor;
    self.contentView.backgroundColor = bgColor;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (!separatorColor) {return;}
    _separatorColor = separatorColor;
    
    [self.collectionView reloadData];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius<0) {
        cornerRadius = 0;
    }
    _cornerRadius = cornerRadius;
    self.contentView.layer.cornerRadius = cornerRadius;
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    if (separatorHeight<0) {
        separatorHeight = 0.0f;
    }
    _separatorHeight = separatorHeight;
    
}

- (void)setAlertViewWith:(CGFloat)alertViewWith {
    _alertViewWith = alertViewWith;
    
    self.width = alertViewWith;
    [self setNeedsLayout];
}

#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.subTitleLab];
    [self.contentView addSubview:self.topCutView];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.vCutView];

    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    CGFloat leftPadding = 10;
    CGFloat rightPadding = 10;
    
    self.contentView.frame = self.bounds;
    
    CGFloat titleLabX = leftPadding;
    CGFloat titleLabY = 30;
    CGFloat titleLabW;
    CGFloat titleLabH;
    
    CGFloat subTitleLabX = leftPadding;
    CGFloat subTitleLabY;
    CGFloat subTitleLabW;
    CGFloat subTitleLabH;
    
    CGFloat topCutViewX = 0;
    CGFloat topCutViewY;
    CGFloat topCutViewW = self.contentView.width;
    CGFloat topCutViewH = 0.5;
    
    CGFloat collectionViewX = 0;
    CGFloat collectionViewY;
    CGFloat collectionViewW;
    CGFloat collectionViewH = 0;
    
    BOOL isTitle = NO;//标记有标题
    BOOL isSubTitle = NO;//标记有副标题
    BOOL isTopCutView = NO;;//标题有顶部分割线
    BOOL isCollectionView = NO;//标记有collectionView
    
    CGFloat allHeight;
    
    //标题布局
    if (self.titleLab.text.length>0) {
        titleLabW = self.contentView.width-leftPadding-rightPadding;
        titleLabH = [self.titleLab.text getHeightWithFont:self.titleLab.font andWidth:titleLabW];
        self.titleLab.frame = CGRectMake(leftPadding, 30,titleLabW, titleLabH);
        isTitle = YES;
    }else {
        [self.titleLab removeFromSuperview];
        self.titleLab = nil;
        isTitle = NO;
    }
    
    //副标题布局
    if (self.subTitleLab.text.length>0) {
        subTitleLabY = self.titleLab.text.length<=0?30:CGRectGetMaxY(self.titleLab.frame)+5;
        subTitleLabW = self.contentView.width-leftPadding-rightPadding;
        subTitleLabH = [self.subTitleLab.text getHeightWithFont:self.subTitleLab.font andWidth:subTitleLabW];
        self.subTitleLab.frame = CGRectMake(leftPadding, CGRectGetMaxY(self.titleLab.frame)+5, subTitleLabW, subTitleLabH);
        isSubTitle = YES;
    }else {
        [self.subTitleLab removeFromSuperview];
        self.subTitleLab = nil;
        isSubTitle = NO;
    }
    
    //分割线
    if (self.actionMarr.count == 2) {

        //顶部分割线
        if (isTitle&&isSubTitle) {//有标题和副标题
            topCutViewY = CGRectGetMaxY(self.subTitleLab.frame)+20;
        }else if (isTitle) {//只有标题
            topCutViewY = CGRectGetMaxY(self.titleLab.frame)+20;
        }else if (isSubTitle) {//只有副标题
            topCutViewY = CGRectGetMaxY(self.subTitleLab.frame)+20;
        }else {//都没有
            topCutViewY = 30+20;
        }
        [self.contentView addSubview:self.topCutView];
        self.topCutView.frame = CGRectMake(0, topCutViewY, self.contentView.width, self.separatorHeight);
        isTopCutView = YES;
    }else {
        [self.topCutView removeFromSuperview];
        self.topCutView = nil;
        isTopCutView = NO;
    }
   
    
    
    //collectionView
    if (self.actionMarr.count>0) {
        [self.contentView addSubview:self.collectionView];
        collectionViewH = [self getAllActionHeight];
        if (isTopCutView) {//2个action
            collectionViewY = CGRectGetMaxY(self.topCutView.frame);
        }else {
            if (isTitle&&isSubTitle) {//有标题和副标题
                collectionViewY = CGRectGetMaxY(self.subTitleLab.frame)+20;
            }else if (isTitle) {//只有标题
                collectionViewY = CGRectGetMaxY(self.titleLab.frame)+20;
            }else if (isSubTitle) {//只有副标题
                collectionViewY = CGRectGetMaxY(self.subTitleLab.frame)+20;
            }else {//都没有
                collectionViewY = 30+20;
            }
        }
        self.collectionView.frame = CGRectMake(0, collectionViewY, self.contentView.width, collectionViewH);
        isCollectionView = YES;
    }else {
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
        isCollectionView = NO;
    }
    
    //竖直分割线
    if (isTopCutView) {
        
        [self.contentView addSubview:self.vCutView];
        CGFloat vCutViewX = self.topCutView.width*0.5-self.separatorHeight*0.5;
        CGFloat vCutViewY = CGRectGetMaxY(self.topCutView.frame);
        CGFloat vCutViewH = self.collectionView.height;
        self.vCutView.frame = CGRectMake(vCutViewX, vCutViewY, self.separatorHeight, vCutViewH);
        
    }else {
        [self.vCutView removeFromSuperview];
        self.vCutView = nil;
    }
    
   

  //计算最终高度
    if (isCollectionView) {
        allHeight = self.collectionView.y+collectionViewH;
    }else {
        if (isTitle&&isSubTitle) {//有标题和副标题
            allHeight = CGRectGetMaxY(self.subTitleLab.frame)+30;
        }else if (isTitle) {//只有标题
            allHeight = CGRectGetMaxY(self.titleLab.frame)+30;
        }else if (isSubTitle) {//只有副标题
            allHeight = CGRectGetMaxY(self.titleLab.frame)+30;
        }else {//都没有
             allHeight = 30+20;
        }
    }
    
    
    
    self.height = allHeight;
    self.contentView.height = self.height;
    
//    self.center = self.superview.center;
    
    [self.superview.superview setNeedsLayout];

}

- (CGFloat)getAllActionHeight {
    
    CGFloat allH = 0.0;
    if (self.actionMarr.count == 2) {
        LSTAlertViewAction *one = self.actionMarr[0];
        LSTAlertViewAction *two = self.actionMarr[1];
        allH = MAX(one.height, two.height);
    }else {
        for (LSTAlertViewAction *action in self.actionMarr) {
            allH = allH + action.height;
        }
    }
    return allH;
}




#pragma mark - ***** other 其他 *****

- (LSTAlertViewAction *)createActionViewForAction:(LSTAlertViewAction *)action {
    
    
    if (action.actionView) {
        return action;
    }
    
    CGFloat actionW;
    
    if (self.actionMarr.count<=2) {
        actionW = (self.alertViewWith-1)*0.5;
    }else {
        actionW = self.alertViewWith;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, actionW, action.height)];
    
    
    action.actionView = view;
    
    
    return action;
    
}

#pragma mark - ***** UICollectionViewDelegate,UICollectionViewDataSource  *****


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.actionMarr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    LSTAlertViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LSTAlertViewCell" forIndexPath:indexPath];
    LSTAlertViewAction *action = self.actionMarr[indexPath.item];
    if (indexPath.item == 2) {
        NSLog(@"");
    }
    cell.action = action;
    cell.cutView.backgroundColor = self.separatorColor;
    cell.separatorHeight = self.separatorHeight;
    if (self.actionMarr.count==2) {
        cell.cutView.hidden = YES;
    }else {
        cell.cutView.hidden = NO;
    }
    
    return cell;
    
    
}

- (UIColor*)RandomColor {

    NSInteger aRedValue = arc4random() %255;
    
    NSInteger aGreenValue = arc4random() %255;
    
    NSInteger aBlueValue = arc4random() %255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    
    return randColor;

}

- (CGSize)collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath {
    
    
    if (self.actionMarr.count==2) {

        LSTAlertViewAction *one = self.actionMarr[0];
        LSTAlertViewAction *two = self.actionMarr[1];
       
        CGFloat itemH = MAX(one.height, two.height);
        CGFloat itemW = self.contentView.width*0.5;
        
        return CGSizeMake(itemW, itemH);
    }else {
        LSTAlertViewAction *action = self.actionMarr[indexPath.item];
       return CGSizeMake(self.contentView.width, action.height);
    }

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    LSTAlertViewAction *action = self.actionMarr[indexPath.item];
    if (action.clickBlock) {
        action.clickBlock(action,indexPath.item);
    }
    
}


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UIView *)contentView {
    if(_contentView) return _contentView;
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = UIColor.whiteColor;
    _contentView.layer.cornerRadius = self.cornerRadius;
    _contentView.layer.masksToBounds = YES;
    return _contentView;
}

- (NSMutableArray *)actionMarr {
    if(_actionMarr) return _actionMarr;
    _actionMarr = [NSMutableArray array];
    return _actionMarr;
}

- (UILabel *)titleLab {
    if(_titleLab) return _titleLab;
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont boldSystemFontOfSize:17];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.textColor = UIColor.blackColor;
    _titleLab.numberOfLines = 0;
//    _titleLab.text = @"标题大的撒多撒大多标题大的撒多撒大多标题大的撒多撒大多标题大的撒多撒大多标题大的撒多撒大多";
    _titleLab.backgroundColor = UIColor.clearColor;
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if(_subTitleLab) return _subTitleLab;
    _subTitleLab = [[UILabel alloc] init];
    _subTitleLab.font = [UIFont systemFontOfSize:13];
    _subTitleLab.textAlignment = NSTextAlignmentCenter;
    _subTitleLab.textColor = UIColor.grayColor;
//    _subTitleLab.text = @"副标题sssssssssssssssssss";
    _subTitleLab.numberOfLines = 0;
    _subTitleLab.backgroundColor = UIColor.clearColor;
    return _subTitleLab;
}

- (UIView *)topCutView {
    if(_topCutView) return _topCutView;
    _topCutView = [[UIView alloc] init];
    _topCutView.backgroundColor = self.separatorColor;
    return _topCutView;
}

- (UIView *)vCutView {
    if(_vCutView) return _vCutView;
    _vCutView = [[UIView alloc] init];
    _vCutView.backgroundColor = self.separatorColor;
    return _vCutView;
}

- (UICollectionView *)collectionView {
    if(_collectionView) return _collectionView;
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    fl.minimumInteritemSpacing = 0;
    fl.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fl];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:LSTAlertViewCell.class forCellWithReuseIdentifier:@"LSTAlertViewCell"];
    _collectionView.backgroundColor = UIColor.clearColor;
    return _collectionView;
}




#pragma mark - ***** public api *****




- (void)addAction:(LSTAlertViewAction *)action {
    
    [self.actionMarr addObject:action];
    [self.collectionView reloadData];
    [self setNeedsLayout];
    
}

- (void)deleteActionForIndex:(NSUInteger)index {
    if (self.actionMarr.count<=0||index>=self.actionMarr.count||index<0) { return ;}
   
    [self.actionMarr removeObjectAtIndex:index];
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
}


- (void)deleteActionForIdentifier:(NSString *)identifier {

    if (self.actionMarr.count<=0||identifier.length<=0) { return ;}
    for (LSTAlertViewAction *action in self.actionMarr) {
        if ([action.identifier isEqualToString:identifier]) {
            [self.actionMarr removeObject:action];
        }
    }
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
}

- (void)deleteActionForAction:(LSTAlertViewAction *)action {
    
    
    if (self.actionMarr.count<=0||action==nil) { return ;}
    for (LSTAlertViewAction *tagAction in self.actionMarr) {
        if ([tagAction isEqual:action]) {
            [self.actionMarr removeObject:tagAction];
        }
    }
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
}

- (void)deleteActionForActions:(NSArray<LSTAlertViewAction *> *)actions {
    
    if (self.actionMarr.count<=0||actions.count<=0) { return ;}
  
    [self.actionMarr removeObjectsInArray:actions];
    
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
}




- (void)show {
    
  
    LSTPopView *alertView = [LSTPopView initWithCustomView:self popStyle:LSTPopStyleSpringFromBottom dismissStyle:0];
    self.popView = alertView;
    alertView.hemStyle = self.hemStyle;
//    alertView.adjustY = -34;
    alertView.bgClickBlock = ^{
        [alertView dismiss];
    };
    
 
    
    [alertView pop];
    
}

+ (instancetype)showWithTitle:(NSString *)title
                 actionTitles:(NSArray<NSString *> *)actionTitles
                   ClickBlock:(LSTAlertViewActionClickBlock)clickBlock {
    return [self showWithTitle:title subTitle:@"" actionTitles:actionTitles actionSubTitles:@[] ClickBlock:clickBlock];
}

+ (instancetype)showWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                 actionTitles:(NSArray<NSString *> *)actionTitles
              actionSubTitles:(NSArray<NSString *> *)actionSubTitles
                   ClickBlock:(LSTAlertViewActionClickBlock)clickBlock {
    
    
    if (actionTitles.count<=0&&actionSubTitles.count<=0) {
        return nil;
    }

    LSTAlertView *alertView = [[LSTAlertView alloc] init];
    alertView.titleLab.text = title;
    alertView.subTitleLab.text = subTitle;
    
    if (actionTitles.count>0 && actionSubTitles.count<=0) {
        for (int i = 0; i<actionTitles.count; i++) {
            LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
            action.clickBlock = clickBlock;
            action.title = actionTitles[i];
            [alertView addAction:action];
            
        }
    }else if (actionSubTitles.count>0 && actionTitles.count<=0) {
        for (int i = 0; i<actionSubTitles.count; i++) {
            LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
            action.clickBlock = clickBlock;
            action.subTitle = actionSubTitles[i];
            [alertView addAction:action];
            
        }
        
    }else {//两者都有
    
        if (actionTitles.count>=actionSubTitles.count) {
            for (int i = 0; i<actionTitles.count; i++) {
                LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
                action.clickBlock = clickBlock;
                action.title = actionTitles[i];
                if (i<actionSubTitles.count) {
                    action.subTitle = actionSubTitles[i];
                }
                [alertView addAction:action];
            }
            
        }else {
            for (int i = 0; i<actionSubTitles.count; i++) {
                LSTAlertViewAction *action = [[LSTAlertViewAction alloc] init];
                action.clickBlock = clickBlock;
                action.subTitle = actionSubTitles[i];
                if (i<actionSubTitles.count) {
                    action.title = actionTitles[i];
                }
                [alertView addAction:action];
            }
        }
    }
    [alertView show];
    return alertView;
    
}



- (void)close {
    
    [self.popView dismiss];
    
}

@end
