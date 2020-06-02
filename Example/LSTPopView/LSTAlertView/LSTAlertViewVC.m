//
//  LSTAlertViewVC.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/1/17.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTAlertViewVC.h"
//#import <LSTPopView.h>
#import "LSTPopViewXibView.h"
#import "LSTPopViewCodeView.h"
//#import <LSTAlertView.h>
#import "LSTActionViewImage.h"
#import "LSTActionViewEmoji.h"

@interface LSTAlertViewVC ()
<
UITableViewDataSource,
UITableViewDelegate
>


/** 表 */
@property (nonatomic,strong) UITableView *tableView;


@end

@implementation LSTAlertViewVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    
//    [self layoutSubViewUI];
//   
//    
//}
//
//
//
//#pragma mark - ***** setupUI 界面布局 *****
//
//- (void)layoutSubViewUI {
//    
//    self.title = @"LSTAlertView示例";
//    
//    self.tableView = [[UITableView alloc] init];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    [self.view addSubview:self.tableView];
//    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.bottom.equalTo(self.view);
//    }];
//    
//    
//}
//
//#pragma mark - ***** Other 其他 *****
//
//#pragma mark - ***** Lazy Loading 懒加载 *****
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 10;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    switch (indexPath.row) {
//        case 0:
//        {
//            cell.textLabel.text = @"没有action,只有标题";
//        }
//            break;
//        case 1:
//        {
//             cell.textLabel.text = @"没有action,只有标题和副标题";
//        }
//            break;
//        case 2:
//        {
//            cell.textLabel.text = @"动态增加action";
//        }
//            break;
//        case 3:
//        {
//            cell.textLabel.text = @"自定义action view";
//        }
//            break;
//        case 4:
//        {
//            cell.textLabel.text = @"基本属性调试(宽度,背景颜色,分割线属性,圆角等)";
//        }
//            break;
//        default:
//            break;
//    }
//    return cell;
//    
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//     switch (indexPath.row) {
//         case 0:
//         {
//             [self zero];
//         }
//             break;
//         case 1:
//         {
//             [self one];
//         }
//             break;
//         case 2:
//         {
//             [self two];
//         }
//             break;
//         case 3:
//         {
//             [self three];
//         }
//             break;
//         case 4:
//         {
//             [self four];
//         }
//             break;
//         default:
//             break;
//       }
//}
//
//- (void)zero {
//    LSTAlertView *popView1 = [[LSTAlertView alloc] init];
//    popView1.titleLab.text = @"我是标题啦 看到没有 是不是很酷我是标题啦 看到没有 是不是很酷";
//    popView1.alertViewWith = 400;
//    [popView1 show];
//}
//
//- (void)one {
//    LSTAlertView *popView1 = [[LSTAlertView alloc] init];
//    popView1.titleLab.text = @"我是标题啦 看到没有 是不是很酷我是标题啦 看到没有 是不是很酷";
//    popView1.subTitleLab.text = @"我是短短的副标题";
//    [popView1 show];
//}
//
//- (void)two {
//    LSTAlertView *popView1 = [[LSTAlertView alloc] init];
//    popView1.titleLab.text = @"我是标题啦 看到没有 是不是很酷我是标题啦 看到没有 是不是很酷";
//    popView1.subTitleLab.text = @"我是短短的副标题";
//    popView1.bgClickBlock = ^{
//        [popView1 close];
//    };
//    
//    LSTAlertViewAction *one = [[LSTAlertViewAction alloc] init];
//    one.title = @"选项1";
//    one.height = 50;
//    one.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *two = [[LSTAlertViewAction alloc] init];
//    two.title = @"选项2(做大长度测试做大长度测试做大长度测试做大长度测试)";
//    two.subTitle = @"左边";
//    two.height = 44;
//    two.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *three = [[LSTAlertViewAction alloc] init];
//    three.title = @"选项3";
//    three.subTitle = @"自定义高度44";
//    three.height = 44;
//    three.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *four = [[LSTAlertViewAction alloc] init];
//    four.title = @"选项4";
//    four.subTitle = @"自定义高度60";
//    four.height = 60;
//    four.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    [popView1 addAction:one];
//    [popView1 addAction:two];
//    [popView1 show];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 deleteActionForIndex:1];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:two];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:three];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:four];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:four];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:three];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:four];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:four];
//    });
//}
//
//- (void)three {//自定义actionView
//    LSTAlertView *popView1 = [[LSTAlertView alloc] init];
//    popView1.titleLab.text = @"自定义actionView";
//    popView1.subTitleLab.text = @"我是短短的副标题";
//    popView1.bgClickBlock = ^{
//        [popView1 close];
//    };
//    
//    LSTAlertViewAction *one = [[LSTAlertViewAction alloc] init];
//    one.title = @"选项1";
//    one.height = 50;
//    one.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    UINib *imagenib = [UINib nibWithNibName:@"LSTActionViewImage" bundle:nil];
//    LSTActionViewImage *imageview = [imagenib instantiateWithOwner:nil options:nil].firstObject;
//    imageview.frame = CGRectMake(0, 0, 0, 60);
//    one.actionView = imageview;
//    
//    
//    LSTAlertViewAction *two = [[LSTAlertViewAction alloc] init];
//    two.title = @"楼上是自定义actionView";
////    two.subTitle = @"左边";
//    two.height = 44;
//    two.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *three = [[LSTAlertViewAction alloc] init];
//    three.title = @"选项3";
//    three.subTitle = @"楼下是自定义actionView";
//    three.height = 44;
//    three.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *four = [[LSTAlertViewAction alloc] init];
//    four.title = @"选项4";
//    four.subTitle = @"自定义高度60";
//    four.height = 60;
//    four.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    UINib *nib = [UINib nibWithNibName:@"LSTActionViewEmoji" bundle:nil];
//    LSTActionViewEmoji *emojiview = [nib instantiateWithOwner:nil options:nil].firstObject;
//    emojiview.frame = CGRectMake(0, 0, 0, 60);
//    four.actionView = emojiview;
//    
////    [popView1 addAction:one];
////    [popView1 addAction:two];
////    [popView1 addAction:three];
////    [popView1 addAction:four];
//
//    [popView1 show];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:one];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:two];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:three];
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:four];
//    });
//}
//
//- (void)four {
//    LSTAlertView *popView1 = [[LSTAlertView alloc] init];
//    popView1.titleLab.text = @"自定义actionView";
//    popView1.subTitleLab.text = @"我是短短的副标题";
//    popView1.bgColor = UIColor.yellowColor;
//    popView1.separatorColor = UIColor.greenColor;
//    popView1.cornerRadius = 10;
//    popView1.separatorHeight = 2;
//    popView1.bgClickBlock = ^{
//        [popView1 close];
//    };
//    
//    LSTAlertViewAction *one = [[LSTAlertViewAction alloc] init];
//    one.title = @"选项1";
//    one.height = 50;
//    one.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    UINib *imagenib = [UINib nibWithNibName:@"LSTActionViewImage" bundle:nil];
//    LSTActionViewImage *imageview = [imagenib instantiateWithOwner:nil options:nil].firstObject;
//    imageview.frame = CGRectMake(0, 0, 0, 60);
//    one.actionView = imageview;
//    
//    
//    LSTAlertViewAction *two = [[LSTAlertViewAction alloc] init];
//    two.title = @"楼上是自定义actionView";
//    //    two.subTitle = @"左边";
//    two.height = 44;
//    two.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *three = [[LSTAlertViewAction alloc] init];
//    three.title = @"选项3";
//    three.titleFont = [UIFont systemFontOfSize:15];
//    three.titleColor = UIColor.redColor;
//    three.subTitle = @"楼下是自定义actionView";
//    three.subTitleColor = UIColor.blueColor;
//    three.subTitleFont = [UIFont systemFontOfSize:10];
//    three.height = 44;
//    three.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    LSTAlertViewAction *four = [[LSTAlertViewAction alloc] init];
//    four.title = @"选项4";
//    four.subTitle = @"自定义高度60";
//    four.height = 60;
//    four.clickBlock = ^(LSTAlertViewAction * _Nonnull action, NSUInteger index) {
//        
//    };
//    
//    UINib *nib = [UINib nibWithNibName:@"LSTActionViewEmoji" bundle:nil];
//    LSTActionViewEmoji *emojiview = [nib instantiateWithOwner:nil options:nil].firstObject;
//    emojiview.frame = CGRectMake(0, 0, 0, 60);
//    four.actionView = emojiview;
//    
//    [popView1 show];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:one];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:two];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:three];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [popView1 addAction:four];
//    });
//}
//
//- (void)five {
//   
//}
//
//- (void)six {
//    
//}



@end
