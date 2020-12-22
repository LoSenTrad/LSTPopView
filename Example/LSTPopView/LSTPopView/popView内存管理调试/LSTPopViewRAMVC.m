//
//  LSTPopViewRAMVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/21.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewRAMVC.h"
#import <LSTPopView.h>
#import "LSTPopViewCodeView.h"
#import <Masonry.h>
//#import <LSTPopViewManager.h>

@interface LSTPopViewRAMVC ()

/** <#.....#> */
@property (nonatomic,strong) UILabel *titleLab;

@end

@implementation LSTPopViewRAMVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
}
- (void)dealloc {
  
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.titleLab];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
}


- (void)open {
    LSTPopViewCodeView *view = [[LSTPopViewCodeView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    
    view.frame = CGRectMake(0, 0, 300, 300);
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:self.view popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToBottom];
    popView.hemStyle = LSTHemStyleCenter;
    popView.adjustY = 10;
    popView.isClickFeedback = YES;
    popView.bgColor = UIColor.blackColor;
    LSTPopViewWK(popView)
    popView.bgClickBlock = ^{
        NSLog(@"点击了背景");
        [wk_popView dismiss];
    };
    
    view.closeBlock = ^{
        [wk_popView dismissWithStyle:LSTDismissStyleSmoothToTop duration:1.0];
    };
    
    [popView popWithStyle:LSTPopStyleCardDropFromLeft duration:0.5];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self open];
}


#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

#pragma mark - ***** Lazy Loading 懒加载 *****

- (UILabel *)titleLab {
    if(_titleLab) return _titleLab;
    _titleLab = [[UILabel alloc] init];
    _titleLab.textColor = UIColor.blackColor;
//    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.numberOfLines = 0;
    _titleLab.text = @"1. 点击屏幕\n2. 在当前控制器view中弹出弹窗\n3. 保持弹窗显示状态,然后退出(pop)当前控制器. \n4. 当这个控制器销毁的时候,self.view上的弹窗也会随之一起销毁(自动内存管理回收) \n5. 注意查看控制台日志输出或者右上角调试小窗";
    return _titleLab;
}

@end
