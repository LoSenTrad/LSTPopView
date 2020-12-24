//
//  LSTPopViewTVView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/8/5.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTVView.h"
#import <Masonry.h>
#import "LSTPopViewTVViewCell.h"
#import <LSTControlEvents.h>
#import <LSTPopView.h>
#import <UIView+LSTView.h>
#import "LSTPopViewTVCellView.h"
#import <LSTGestureEvents.h>

@interface LSTPopViewTVView ()< UITableViewDelegate,UITableViewDataSource >

/** 表 */
@property (nonatomic,strong) UITableView *tableView;

/** <#.....#> */
@property (nonatomic,strong) NSMutableArray *dataMarr;

/** <#.....#> */
@property (nonatomic,strong) UILabel *titleLab;
/** <#.....#> */
@property (nonatomic,strong) UIView *cutView;

/** <#.....#> */
@property (nonatomic,weak) LSTPopView *popView;

/**  */
@property (nonatomic,strong) UIView *topLine;

@end

@implementation LSTPopViewTVView

#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

#pragma mark - ***** setter 设置器/数据处理 *****


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.titleLab];
    [self addSubview:self.cutView];
    [self addSubview:self.tableView];
    
    [self addSubview:self.topLine];
    
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(30);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 5));
        make.top.equalTo(self).offset(10);
        make.centerX.equalTo(self);
    }];
    
    [_cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_titleLab.mas_bottom);
        make.left.right.equalTo(self);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(_cutView.mas_bottom);
    }];
    
    
}

#pragma mark - ***** other 其他 *****

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataMarr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSTPopViewTVViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[LSTPopViewTVViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.descLab.text = self.dataMarr[indexPath.row];
    cell.titleLab.text = [cell.descLab.text substringToIndex:1];
    LSTPopViewWK(self);
    [cell.moreBtn addEventTouchUpInsideAction:^(id  _Nonnull sender) {
        
        if (wk_self.popView) {
            [wk_self.popView dismiss];
        }
        [wk_self openMoreView:cell];
    }];
    
    return cell;
}


- (void)openMoreView:(LSTPopViewTVViewCell *)cell {
    
    UIView *view = [LSTPopViewTVCellView getNibView:@"LSTPopViewTVCellView"];
    view.size = CGSizeMake(160, 80);
    view.backgroundColor = UIColor.whiteColor;
    
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:cell.contentView popStyle:LSTPopStyleSmoothFromRight dismissStyle:LSTDismissStyleSmoothToRight];
    self.popView = popView;
    popView.hemStyle = LSTHemStyleRight;
    popView.bgColor = UIColor.clearColor;
    LSTPopViewWK(popView);
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    [popView pop];
    
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"点击了cell");
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.popView) {
        [self.popView dismiss];
    }
}


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UITableView *)tableView {
    if(_tableView) return _tableView;
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    [_tableView registerNib:[UINib nibWithNibName:@"LSTPopViewTVViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    return _tableView;
}

- (NSMutableArray *)dataMarr {
    if(_dataMarr) return _dataMarr;
    _dataMarr = [NSMutableArray array];
    [_dataMarr addObject:@"赵丽颖"];
    [_dataMarr addObject:@"靳东"];
    [_dataMarr addObject:@"霍建华"];
    [_dataMarr addObject:@"胡歌"];
    [_dataMarr addObject:@"Angelababy"];
    [_dataMarr addObject:@"迪丽热巴"];
    [_dataMarr addObject:@"唐嫣"];
    [_dataMarr addObject:@"朱珠"];
    [_dataMarr addObject:@"刘德华"];
    [_dataMarr addObject:@"成龙"];
    [_dataMarr addObject:@"黄晓明"];
    [_dataMarr addObject:@"詹姆斯"];
    [_dataMarr addObject:@"吴磊"];
    return _dataMarr;
}

- (UILabel *)titleLab {
    if(_titleLab) return _titleLab;
    _titleLab = [[UILabel alloc] init];
    _titleLab.textColor = UIColor.blackColor;
    _titleLab.text = @"我的好友";
    _titleLab.textAlignment = NSTextAlignmentCenter;
    return _titleLab;
}

- (UIView *)cutView {
    if(_cutView) return _cutView;
    _cutView = [[UIView alloc] init];
    _cutView.backgroundColor = UIColor.lightGrayColor;
    return _cutView;
}

- (UIView *)topLine {
    if(_topLine) return _topLine;
    _topLine = [[UIView alloc] init];
    _topLine.backgroundColor = UIColor.lightGrayColor;
    _topLine.layer.cornerRadius = 2.5;
    _topLine.layer.masksToBounds = YES;
    return _topLine;
}

@end
