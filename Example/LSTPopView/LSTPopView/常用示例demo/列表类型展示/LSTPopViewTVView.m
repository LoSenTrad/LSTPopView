//
//  LSTPopViewTVView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/8/5.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTVView.h"
#import <Masonry.h>

@interface LSTPopViewTVView ()< UITableViewDelegate,UITableViewDataSource >

/** 表 */
@property (nonatomic,strong) UITableView *tableView;

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
    
    [self addSubview:self.tableView];
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    
}

#pragma mark - ***** other 其他 *****

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"我的row";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"点击了cell");
}


#pragma mark - ***** Lazy Loading 懒加载 *****

- (UITableView *)tableView {
    if(_tableView) return _tableView;
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    return _tableView;
}


@end
