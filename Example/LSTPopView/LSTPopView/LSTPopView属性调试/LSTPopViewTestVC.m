//
//  LSTPopViewTestVC.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/2/5.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTestVC.h"
#import "LSTPopViewTestView.h"
#import <LSTPopView.h>
#import <UIView+LSTView.h>

#import <objc/runtime.h>

@interface LSTPopViewTestVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *popStyleSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dismissStyleSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hemStyleSC;
@property (weak, nonatomic) IBOutlet UITextField *popBGAlpha;
@property (weak, nonatomic) IBOutlet UITextField *popTime;
@property (weak, nonatomic) IBOutlet UITextField *dismissTime;
@property (weak, nonatomic) IBOutlet UITextField *adjustX;
@property (weak, nonatomic) IBOutlet UITextField *adjustY;
@property (weak, nonatomic) IBOutlet UISwitch *bgDismissSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *screenSwith;
@property (weak, nonatomic) IBOutlet UISwitch *parentSwitch;
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet UIView *yellowView;
@property (weak, nonatomic) IBOutlet UIView *yellowResView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *parentViewSC;


@end

@implementation LSTPopViewTestVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****


- (void)viewDidLoad {
    [super viewDidLoad];
    
   

    
    self.yellowResView.hidden = YES;
    
    [self layoutSubViewUI];
    
}

- (void)dealloc {
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
}


#pragma mark - ***** Other 其他 *****

- (IBAction)openBtnAction:(UIButton *)sender {
    
    
    if (self.parentSwitch.isOn) {
        
        [self yellowPopView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bulePopView];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self vcViewPopView];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self windowPopView];
        });
        
        return;
    }
    
    
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTestView" bundle:nil];
    LSTPopViewTestView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    LSTPopView *popView;
    switch (self.parentViewSC.selectedSegmentIndex) {
        case 0:
        {
            popView  = [LSTPopView initWithCustomView:view parentView:nil popStyle:1 dismissStyle:1];
            
        }
            break;
        case 1:
        {
            popView  = [LSTPopView initWithCustomView:view parentView:self.view popStyle:1 dismissStyle:1];
            
        }
            break;
        case 2:
        {
            popView  = [LSTPopView initWithCustomView:view parentView:self.parentView popStyle:1 dismissStyle:1];
            
        }
            break;
        case 3:
        {
            popView  = [LSTPopView initWithCustomView:view parentView:self.yellowResView popStyle:1 dismissStyle:1];
            
        }
            break;
        default:
            break;
    }
    
    
    
    
    switch (self.hemStyleSC.selectedSegmentIndex) {
        case 1:
        {
            popView.hemStyle = LSTHemStyleTop;
        }
            break;
        case 2:
        {
            popView.hemStyle = LSTHemStyleLeft;
        }
            break;
        case 3:
        {
            popView.hemStyle = LSTHemStyleBottom;
        }
            break;
        case 4:
        {
            popView.hemStyle = LSTHemStyleRight;
        }
            break;
        default:
        {
            popView.hemStyle = LSTHemStyleCenter;
        }
            break;
    }
    
    switch (self.popStyleSC.selectedSegmentIndex) {
        case 1:
        {
            popView.popStyle = LSTPopStyleSpringFromTop;
        }
            break;
        case 2:
        {
            popView.popStyle = LSTPopStyleSpringFromLeft;
        }
            break;
        case 3:
        {
            popView.popStyle = LSTPopStyleSpringFromBottom;
        }
            break;
        case 4:
        {
            popView.popStyle = LSTPopStyleSpringFromRight;
        }
            break;
        default:
        {
            popView.popStyle = LSTPopStyleNO;
        }
            break;
    }
    
    switch (self.dismissStyleSC.selectedSegmentIndex) {
        case 1:
        {
            popView.dismissStyle = LSTDismissStyleSmoothToTop;
        }
            break;
        case 2:
        {
            popView.dismissStyle = LSTDismissStyleSmoothToLeft;
        }
            break;
        case 3:
        {
            popView.dismissStyle = LSTDismissStyleSmoothToBottom;
        }
            break;
        case 4:
        {
            popView.dismissStyle = LSTDismissStyleSmoothToRight;
        }
            break;
        default:
        {
            popView.dismissStyle = LSTPopStyleNO;
        }
            break;
    }
    
    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.bgAlpha = [self.popBGAlpha.text floatValue];
    popView.popDuration  = [self.popTime.text floatValue];
    popView.dismissDuration = [self.dismissTime.text floatValue];
    popView.adjustY = lst_IsIphoneX_ALL()?LSTNavBarHeight()*0.5:0;
    
    
    
    popView.isClickBgDismiss = self.bgDismissSwitch.on?YES:NO;
    
    //    view.clickBlock = ^{
    //        [wk_popView dismiss];
    //    };
    
    popView.bgClickBlock = ^{
        
        //        [wk_popView dismiss];
    };
    
    popView.popViewWillPop = ^{
        wk_self.yellowResView.hidden = NO;
    };
    popView.popViewDidDismiss = ^{
        wk_self.yellowResView.hidden = YES;
    };
    
    view.xStepperBlock = ^(float value) {
        wk_popView.adjustX = value;
    };
    view.yStepperBlock = ^(float value) {
        wk_popView.adjustY = value;
    };
    view.closeBlock = ^(id value) {
        [wk_popView dismiss];
    };
    view.pushBlock = ^(id value) {
        [wk_self.navigationController pushViewController:[LSTPopViewTestVC new] animated:YES];
    };
    
    [popView pop];
}

- (IBAction)resetAction:(UIButton *)sender {
    
    
    
}


- (void)yellowPopView {
    
    self.yellowResView.hidden = NO;
    
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTestView" bundle:nil];
    LSTPopViewTestView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:self.yellowResView popStyle:LSTPopStyleSmoothFromTop dismissStyle:LSTDismissStyleSmoothToTop];
    popView.adjustY = lst_IsIphoneX_ALL()?LSTNavBarHeight()*0.5:0;
    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.bgAlpha = [self.popBGAlpha.text floatValue];
    popView.popDuration  = [self.popTime.text floatValue];
    popView.dismissDuration = [self.dismissTime.text floatValue];
    
    popView.isClickBgDismiss = self.bgDismissSwitch.on?YES:NO;
    
    //    view.clickBlock = ^{
    //        [wk_popView dismiss];
    //    };
    
    popView.bgClickBlock = ^{
        
        //        [wk_popView dismiss];
    };
    
    popView.popViewDidDismiss = ^{
//        [wk_popView dismiss];
        self.yellowResView.hidden = YES;
    };
    
    view.xStepperBlock = ^(float value) {
        wk_popView.adjustX = value;
    };
    view.yStepperBlock = ^(float value) {
        wk_popView.adjustY = value;
    };
    view.closeBlock = ^(id value) {
        [wk_popView dismiss];
    };
    view.pushBlock = ^(id value) {
        [wk_self.navigationController pushViewController:[LSTPopViewTestVC new] animated:YES];
    };
    
    [popView pop];
}

- (void)bulePopView {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTestView" bundle:nil];
    LSTPopViewTestView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:self.parentView popStyle:LSTPopStyleSmoothFromBottom dismissStyle:LSTDismissStyleSmoothToBottom];
    
    
    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.bgAlpha = [self.popBGAlpha.text floatValue];
    popView.popDuration  = [self.popTime.text floatValue];
    popView.dismissDuration = [self.dismissTime.text floatValue];
    
    popView.isClickBgDismiss = self.bgDismissSwitch.on?YES:NO;
    
    //    view.clickBlock = ^{
    //        [wk_popView dismiss];
    //    };
    
    popView.bgClickBlock = ^{
        
        //        [wk_popView dismiss];
    };
    
    popView.popViewDidDismiss = ^{
//        [wk_popView dismiss];
    };
    
    view.xStepperBlock = ^(float value) {
        wk_popView.adjustX = value;
    };
    view.yStepperBlock = ^(float value) {
        wk_popView.adjustY = value;
    };
    view.closeBlock = ^(id value) {
        [wk_popView dismiss];
    };
    view.pushBlock = ^(id value) {
        [wk_self.navigationController pushViewController:[LSTPopViewTestVC new] animated:YES];
    };
    
    [popView pop];
}

- (void)vcViewPopView {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTestView" bundle:nil];
    LSTPopViewTestView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:self.view popStyle:LSTPopStyleSmoothFromLeft dismissStyle:LSTDismissStyleSmoothToLeft];
    
    
    
    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.bgAlpha = [self.popBGAlpha.text floatValue];
    popView.popDuration  = [self.popTime.text floatValue];
    popView.dismissDuration = [self.dismissTime.text floatValue];
    
    popView.isClickBgDismiss = self.bgDismissSwitch.on?YES:NO;
    
    //    view.clickBlock = ^{
    //        [wk_popView dismiss];
    //    };
    
    popView.bgClickBlock = ^{
        
        //        [wk_popView dismiss];
    };
    
    popView.popViewDidDismiss = ^{
//        [wk_popView dismiss];
    };
    
    view.xStepperBlock = ^(float value) {
        wk_popView.adjustX = value;
    };
    view.yStepperBlock = ^(float value) {
        wk_popView.adjustY = value;
    };
    view.closeBlock = ^(id value) {
        [wk_popView dismiss];
    };
    view.pushBlock = ^(id value) {
        [wk_self.navigationController pushViewController:[LSTPopViewTestVC new] animated:YES];
    };
    
    [popView pop];
}

- (void)windowPopView {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTestView" bundle:nil];
    LSTPopViewTestView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    LSTPopView *popView = [LSTPopView initWithCustomView:view parentView:nil popStyle:LSTPopStyleSmoothFromRight dismissStyle:LSTDismissStyleSmoothToRight];

    LSTPopViewWK(popView);
    LSTPopViewWK(self);
    popView.bgAlpha = [self.popBGAlpha.text floatValue];
    popView.popDuration  = [self.popTime.text floatValue];
    popView.dismissDuration = [self.dismissTime.text floatValue];
    
    popView.isClickBgDismiss = self.bgDismissSwitch.on?YES:NO;
    
    //    view.clickBlock = ^{
    //        [wk_popView dismiss];
    //    };
    
    popView.bgClickBlock = ^{
        
        //        [wk_popView dismiss];
    };
    
    popView.popViewDidDismiss = ^{
//        [wk_popView dismiss];
    };
    
    view.xStepperBlock = ^(float value) {
        wk_popView.adjustX = value;
    };
    view.yStepperBlock = ^(float value) {
        wk_popView.adjustY = value;
    };
    view.closeBlock = ^(id value) {
        [wk_popView dismiss];
    };
    view.pushBlock = ^(id value) {
        [wk_self.navigationController pushViewController:[LSTPopViewTestVC new] animated:YES];
    };
    
    [popView pop];
}

- (IBAction)pushVCAction:(UIButton *)sender {
    [self.navigationController pushViewController:[LSTPopViewTestVC new] animated:YES];
}


#pragma mark - ***** Lazy Loading 懒加载 *****





@end
