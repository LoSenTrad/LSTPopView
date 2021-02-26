//
//  LSTPopViewDragVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2021/2/25.
//  Copyright © 2021 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewDragVC.h"
#import "LSTPopViewTVView.h"

@interface LSTPopViewDragVC ()
<
UITableViewDelegate,
UITableViewDataSource
>

/** <#.....#> */
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation LSTPopViewDragVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
    self.title = @"拖拽轻扫手势示例";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 13;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"底部拖拽轻扫移除";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"顶部拖拽轻扫移除";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"左侧边拖拽移除";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"右侧边拖拽移除";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"纯代码自定义view";
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"XIB自定义view";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"多个popView窗口测试";
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"规避键盘遮挡调试";
        }
            break;
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LSTPopViewTVView *customView = [[LSTPopViewTVView alloc] initWithFrame:CGRectMake(0, 0, pv_ScreenWidth(), pv_ScreenHeight()*(0.8))];
        LSTPopView *popView = [LSTPopView initWithCustomView:customView
                                                  parentView:self.view
                                                    popStyle:LSTPopStyleSmoothFromBottom
                                                dismissStyle:LSTDismissStyleSmoothToBottom];
    //    self.popView = popView;
        popView.priority = 1000;
        popView.hemStyle = LSTHemStyleBottom;
        popView.dragStyle = LSTDragStyleY_Positive;
        popView.dragDistance =  customView.pv_Height*0.5;
        popView.sweepStyle = LSTSweepStyleY_Positive;
        popView.swipeVelocity = 1600;
        popView.sweepDismissStyle = LSTSweepDismissStyleSmooth;
        popView.isImpactFeedback = YES;
        
        [popView pop];
    }
}

#pragma mark - ***** Lazy Loading 懒加载 *****



@end
