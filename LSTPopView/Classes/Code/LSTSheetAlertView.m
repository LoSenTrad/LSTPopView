//
//  LSTSheetAlertView.m
//  LSTAlertView
//
//  Created by LoSenTrad on 2020/1/10.
//

#import "LSTSheetAlertView.h"
#import "UIView+LSTView.h"
#import "NSString+LSTString.h"
#import "LSTPopView.h"


@interface LSTSheetAlertViewCell : UITableViewCell

/** <#.....#> */
@property (nonatomic,strong) LSTAlertViewAction *action;
/**  */
@property (nonatomic,strong) UILabel *titleLab;
/** <#.....#> */
@property (nonatomic,strong) UILabel *subTitleLab;
/** 分割线 */
@property (nonatomic,strong) UIView *cutView;
/** 分割线高度 */
@property (nonatomic, assign) CGFloat cutViewHeight;
/** 是否是底部action */
@property (nonatomic, assign) BOOL isBottomAction;

/** 内容view */
@property (nonatomic,strong) UIView *cnView;



@end

@implementation LSTSheetAlertViewCell

#pragma mark - ***** 初始化 *****

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
          self.cutViewHeight = 0.333;
        self.cutView.backgroundColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
        [self initSubViews];
    }
    return self;
}

#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setAction:(LSTAlertViewAction *)action {
    _action = action;
    
    self.titleLab.text = action.title;
    self.subTitleLab.text = action.subTitle;
    
}

- (void)setCutViewHeight:(CGFloat)cutViewHeight {
    _cutViewHeight = cutViewHeight;
    [self setNeedsLayout];
}

- (void)setIsBottomAction:(BOOL)isBottomAction {
    _isBottomAction = isBottomAction;
    
    [self setNeedsLayout];
}


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self.contentView addSubview:self.cutView];
    
    self.cnView = [[UIView alloc] init];
    self.cnView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.cnView];
    

    
    [self.cnView addSubview:self.titleLab];
    [self.cnView addSubview:self.subTitleLab];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cutView.frame = CGRectMake(0, 0, self.contentView.width, self.cutViewHeight);

    self.cnView.frame = CGRectMake(0, CGRectGetMaxY(_cutView.frame), LSTScreenWidth(), self.contentView.height-self.cutViewHeight);

    CGFloat titleW = self.cnView.width - 10 - 10;

    CGFloat pading = 3;

    CGFloat titleH = [self.titleLab.text getHeightWithFont:self.titleLab.font andWidth:titleW];
    CGFloat subTitleH = [self.subTitleLab.text getHeightWithFont:self.subTitleLab.font andWidth:titleW];

    CGFloat titleY;
    if (lst_IsIphoneX_ALL()&&self.isBottomAction) {
        CGFloat allH = pading + titleH + subTitleH;
        titleY = (self.cnView.height  - allH - 34*0.8)*0.5 + self.cutViewHeight;
    }else {
        CGFloat allH = pading + titleH + subTitleH;
        titleY = (self.cnView.height - allH)*0.5;
    }
    _titleLab.frame = CGRectMake(10, titleY, self.cnView.width - 10 - 10, titleH);
    _subTitleLab.frame = CGRectMake(10, CGRectGetMaxY(_titleLab.frame)+pading, _titleLab.width, subTitleH);

    
}

#pragma mark - ***** other 其他 *****


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


@interface LSTSheetAlertView ()
<
UITableViewDataSource,
UITableViewDelegate
>

/** action表 */
@property (nonatomic,strong) UITableView *tableView;
/** 内容 */
@property (nonatomic,strong) UIView *contentView;
/** <#.....#> */
@property (nonatomic,strong) NSMutableArray *actionMarr;
/** 顶部分割线 */
@property (nonatomic,strong) UIView *topCutView;
/** <#.....#> */
@property (nonatomic,strong) LSTPopView *popView;


@end

@implementation LSTSheetAlertView

#pragma mark - ***** 初始化 *****

+ (instancetype)initAlertView {
    
    LSTSheetAlertView *alertView = [[LSTSheetAlertView alloc] initWithFrame:CGRectMake(0, 0, LSTScreenWidth(), 270)];
    return alertView;
    
}


- (instancetype)init{
    if (self = [super init]) {
        self.size = CGSizeMake(LSTScreenWidth(), 270);
        self.alertViewWith = 270;
        self.actionHeight = 50.0f;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}


#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setAlertViewWith:(CGFloat)alertViewWith {
    _alertViewWith = alertViewWith;
    
}


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.subTitleLab];
    [self.contentView addSubview:self.tableView];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftPadding = 10;
    CGFloat rightPadding = 10;
    
    CGFloat titleX;
    CGFloat titleY;
    
    
    
    self.contentView.frame = self.bounds;
    
    CGFloat titleLabW = self.contentView.width-leftPadding-rightPadding;
    CGFloat titleLabH = [self.titleLab.text getHeightWithFont:self.titleLab.font andWidth:titleLabW];
    
    self.titleLab.frame = CGRectMake(leftPadding, 30,titleLabW, titleLabH);
    
    CGFloat subTitleLabW = self.contentView.width-leftPadding-rightPadding;
    CGFloat subTitleLabH = [self.subTitleLab.text getHeightWithFont:self.subTitleLab.font andWidth:subTitleLabW];
    
    self.subTitleLab.frame = CGRectMake(leftPadding, CGRectGetMaxY(self.titleLab.frame)+5, subTitleLabW, subTitleLabH);
    
    //顶部分割线
    self.topCutView.frame = CGRectMake(0, CGRectGetMaxY(self.subTitleLab.frame)+20, self.contentView.width, 0.5);
    
    if (self.actionMarr.count == 2||self.actionMarr.count <= 0) {
        self.topCutView.hidden = NO;
    }else {
        self.topCutView.hidden = YES;
    }
    
    CGFloat tableViewH = [self getAllActionHeight];
    
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.topCutView.frame), self.contentView.width, tableViewH);
    
    
    self.height = self.tableView.y+tableViewH;
    self.contentView.height = self.height;
    
    [self.superview.superview setNeedsLayout];

    
}

- (CGFloat)getAllActionHeight {
    
    CGFloat allH = 0.0;
    
    for (LSTAlertViewAction *action in self.actionMarr) {
        allH = allH + action.height;
    }
 
    return allH;
}


#pragma mark - ***** other 其他 *****


#pragma mark - ***** UITableViewDelegate,UITableViewDataSource *****


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actionMarr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSTSheetAlertViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LSTSheetAlertViewCell"];
    if (!cell) {
        cell = [[LSTSheetAlertViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LSTSheetAlertViewCell"];
    }

    LSTAlertViewAction *action = self.actionMarr[indexPath.item];
    
    if ((indexPath.row+1) == self.actionMarr.count) {
         cell.cutViewHeight = 8;
        cell.isBottomAction = YES;
    }else {
        cell.cutViewHeight = 0.333;
        cell.isBottomAction = NO;
    }
    
   
    cell.action = action;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSTAlertViewAction *action = self.actionMarr[indexPath.row];
    
    return action.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



#pragma mark - ***** Lazy Loading 懒加载 *****

- (UILabel *)titleLab {
    if(_titleLab) return _titleLab;
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont boldSystemFontOfSize:17];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.textColor = UIColor.blackColor;
    _titleLab.numberOfLines = 0;
    _titleLab.backgroundColor = UIColor.clearColor;
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if(_subTitleLab) return _subTitleLab;
    _subTitleLab = [[UILabel alloc] init];
    _subTitleLab.font = [UIFont systemFontOfSize:13];
    _subTitleLab.textAlignment = NSTextAlignmentCenter;
    _subTitleLab.textColor = UIColor.grayColor;
    _subTitleLab.numberOfLines = 0;
    _subTitleLab.backgroundColor = UIColor.clearColor;
    return _subTitleLab;
}

- (UITableView *)tableView {
    if(_tableView) return _tableView;
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[LSTSheetAlertViewCell class] forCellReuseIdentifier:@"LSTSheetAlertViewCell"];
    return _tableView;
}

- (UIView *)contentView {
    if(_contentView) return _contentView;
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = UIColor.whiteColor;
    _contentView.layer.cornerRadius = 10;
    _contentView.layer.masksToBounds = YES;
    return _contentView;
}

- (NSMutableArray *)actionMarr {
    if(_actionMarr) return _actionMarr;
    _actionMarr = [NSMutableArray array];
    return _actionMarr;
}

- (UIView *)topCutView {
    if(_topCutView) return _topCutView;
    _topCutView = [[UIView alloc] init];
    _topCutView.backgroundColor = UIColor.redColor;
    return _topCutView;
}

#pragma mark - ***** public api *****




- (void)addAction:(LSTAlertViewAction *)action {
    
    [self.actionMarr addObject:action];
   
   
    [self.tableView reloadData];
    [self setNeedsLayout];
    
}


- (void)deleteActionForIdentifier:(NSString *)identifier {

    if (self.actionMarr.count<=0||identifier.length<=0) { return ;}
    for (LSTAlertViewAction *action in self.actionMarr) {
        if ([action.identifier isEqualToString:identifier]) {
            [self.actionMarr removeObject:action];
        }
    }
    
    [self.tableView reloadData];
    [self setNeedsLayout];
}

- (void)deleteActionForAction:(LSTAlertViewAction *)action {
    
    
    if (self.actionMarr.count<=0||action==nil) { return ;}
    for (LSTAlertViewAction *tagAction in self.actionMarr) {
        if ([tagAction isEqual:action]) {
            [self.actionMarr removeObject:tagAction];
        }
    }
    
    [self.tableView reloadData];
    [self setNeedsLayout];
}

- (void)deleteActionForActions:(NSArray<LSTAlertViewAction *> *)actions {
    
    if (self.actionMarr.count<=0||actions.count<=0) { return ;}
  
    [self.actionMarr removeObjectsInArray:actions];
    
    
    [self.tableView reloadData];
    [self setNeedsLayout];
}




- (void)show {
    
  
    LSTPopView *alertView = [LSTPopView initWithCustomView:self popStyle:LSTPopStyleSmoothFromBottom dismissStyle:0];
    self.popView = alertView;
    alertView.hemStyle = LSTHemStyleBottom;
//    alertView.adjustY = 0;
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

    LSTSheetAlertView *alertView = [[LSTSheetAlertView alloc] init];
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
