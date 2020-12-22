//
//  LSTPopViewListView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/7/10.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewListView.h"
#import <Masonry.h>
#import "LSTPopViewListCell.h"
#import <UIView+LSTView.h>
#import "LSTPopViewTVCellView.h"
#import <LSTGestureEvents.h>
#import <LSTPopView.h>
#import "LSTPopViewListBuyView.h"

@interface LSTPopViewListView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

/** 表 */
@property (nonatomic,strong) UICollectionView *collectionView;
/** <#.....#> */
@property (nonatomic,weak) LSTPopView *popView;

@end

@implementation LSTPopViewListView

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
    [self addSubview:self.collectionView];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    
}

#pragma mark - ***** other 其他 *****


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSTPopViewListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.titleLab.text = [NSString stringWithFormat:@"第%zd",indexPath.item];
    LSTPopViewWK(self);
    [cell.bottomView addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_self openMoreView:cell];
    }];
    [cell.imgView addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_self openCollectionView:cell];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了第%zd个item",indexPath.item);
}


- (void)openCollectionView:(LSTPopViewListCell *)cell {
    LSTPopViewListBuyView *view = [LSTPopViewListBuyView getNibView:@"LSTPopViewListBuyView"];
    view.backgroundColor = UIColor.whiteColor;
    view.size = CGSizeMake(cell.contentView.width, cell.contentView.height-50);
    view.backgroundColor = UIColor.clearColor;
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:cell.imgView popStyle:LSTPopStyleSmoothFromLeft dismissStyle:LSTDismissStyleSmoothToRight];
    popView.hemStyle = LSTHemStyleRight;
    popView.bgColor = UIColor.blackColor;
    popView.bgAlpha = 0.2;
    LSTPopViewWK(popView);
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
    };
    [popView pop];
    [view addTapGestureEventHandle:^(id  _Nonnull sender, UITapGestureRecognizer * _Nonnull gestureRecognizer) {
        [wk_popView dismiss];
    }];
}



- (void)openMoreView:(LSTPopViewListCell *)cell {
    
    LSTPopViewTVCellView *view = [LSTPopViewTVCellView getNibView:@"LSTPopViewTVCellView"];
    view.backgroundColor = UIColor.whiteColor;
    view.size = CGSizeMake(100, 50);

    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:cell.bottomView popStyle:LSTPopStyleSmoothFromRight dismissStyle:LSTDismissStyleSmoothToRight];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.popView) {
        [self.popView dismiss];
    }
}


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UICollectionView *)collectionView {
    if(_collectionView) return _collectionView;
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fl];
    fl.itemSize = CGSizeMake((LSTScreenWidth()-40-30)*0.5, ((LSTScreenWidth()-40-30)*0.5)+50);
    fl.minimumLineSpacing = 10;
    fl.minimumInteritemSpacing = 10;
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"LSTPopViewListCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    _collectionView.backgroundColor = UIColor.whiteColor;
//    _collectionView.delaysContentTouches
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popViewBgViewTap)];
//    [_collectionView addGestureRecognizer:tap];
    return _collectionView;
}

- (void)popViewBgViewTap {
    
}


@end
