//
//  LSTSheetAlertViewVC.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/1/17.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTSheetAlertViewVC.h"
#import <LSTPopView.h>
#import "LSTPopViewXibView.h"
#import "LSTPopViewCodeView.h"
#import <LSTSheetAlertView.h>

@interface LSTSheetAlertViewVC ()
<
UITableViewDataSource,
UITableViewDelegate
>


/** 表 */
@property (nonatomic,strong) UITableView *tableView;


@end

@implementation LSTSheetAlertViewVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
   
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
    self.title = @"LSTSheetAlertViewVC示例";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
}

#pragma mark - ***** Other 其他 *****

#pragma mark - ***** Lazy Loading 懒加载 *****


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"没有action,只有标题";
        }
            break;
        case 1:
        {
             cell.textLabel.text = @"没有action,只有标题和副标题";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"动态增加action";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"自定义action view";
        }
            break;
            
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            [self zero];
        }
            break;
        case 1:
        {
            [self one];
        }
            break;
        case 2:
        {
            [self two];
        }
            break;
        case 3:
        {
            [self three];
        }
            break;
        case 4:
        {
            [self four];
        }
            break;
        default:
            break;
    }
}


- (void)zero {
    LSTSheetAlertView *popView1 = [[LSTSheetAlertView alloc] init];
    popView1.titleLab.text = @"我是标题啦 看到没有 是不是很酷我是标题啦 看到没有 是不是很酷";
    popView1.subTitleLab.text = @"我是短短的副标题";
    //    popView1.bgClickBlock = ^{
    //        [popView1 close];
    //    };
    LSTAlertViewAction *one = [[LSTAlertViewAction alloc] init];
    one.title = @"选项1";
    one.height = 44;
    one.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
        
    };
    
    LSTAlertViewAction *two = [[LSTAlertViewAction alloc] init];
    two.title = @"选项2";
    //    two.subTitle = @"左边";
    two.height = 44;
    two.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
        
    };
    
    LSTAlertViewAction *three = [[LSTAlertViewAction alloc] init];
    three.title = @"选项3";
    //    three.subTitle = @"左边";
    three.height = 100;
    three.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
        
    };
    
    
    LSTAlertViewAction *cancel = [[LSTAlertViewAction alloc] init];
    cancel.title = @"选项3";
    //    three.subTitle = @"左边";
    cancel.height = 100;
    cancel.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
        
    };
    
    [popView1 addAction:one];
    [popView1 addAction:two];
    [popView1 addAction:three];
    [popView1 show];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [popView1 addAction:cancel];
    });
}

- (void)one {
   
}

- (void)two {
    
}

- (void)three {
   
}

- (void)four {
    
}

- (void)five {
   
}

- (void)six {
    
}



@end
