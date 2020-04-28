//
//  LSTAutoKeyboardVC.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/15.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTAutoKeyboardVC.h"
#import "LSTKeyboardXibView.h"
#import <LSTPopView.h>

@interface LSTAutoKeyboardVC ()

@end

@implementation LSTAutoKeyboardVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
    [self show];
    
    
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
        
    self.view.backgroundColor = UIColor.whiteColor;
    

}
#pragma mark - ***** Data Request 数据请求 *****


#pragma mark - ***** Other 其他 *****

- (void)show {
    UINib *nib = [UINib nibWithNibName:@"LSTKeyboardXibView" bundle:nil];
    LSTKeyboardXibView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:1 dismissStyle:LSTDismissStyleSmoothToBottom];
//    popView.parentView = self.view;
    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.avoidKeyboardSpace = 15;
    popView.bgClickBlock = ^{
        [wk_popView dismiss];
        NSLog(@"点击了背景");
    };
    view.addBlock = ^(id sender) {
        [wk_self show];
    };
    [popView pop];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self show];
}

#pragma mark - ***** Lazy Loading 懒加载 *****


@end
