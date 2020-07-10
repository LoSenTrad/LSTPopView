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

@interface LSTPopViewListView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

/** 表 */
@property (nonatomic,strong) UICollectionView *collectionView;

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
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了第%zd个item",indexPath.item);
}



#pragma mark - ***** Lazy Loading 懒加载 *****

- (UICollectionView *)collectionView {
    if(_collectionView) return _collectionView;
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fl];
    fl.itemSize = CGSizeMake(80, 80);
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"LSTPopViewListCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    _collectionView.backgroundColor = UIColor.whiteColor;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popViewBgViewTap)];
//    [_collectionView addGestureRecognizer:tap];
    return _collectionView;
}

- (void)popViewBgViewTap {
    
}


@end
