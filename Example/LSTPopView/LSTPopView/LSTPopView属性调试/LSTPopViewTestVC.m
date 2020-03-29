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


@end

@implementation LSTPopViewTestVC

#pragma mark - ***** Controller Life Cycle 控制器生命周期 *****

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self layoutSubViewUI];
    
}



#pragma mark - ***** setupUI 界面布局 *****

- (void)layoutSubViewUI {
    
}


#pragma mark - ***** Other 其他 *****

- (IBAction)openBtnAction:(UIButton *)sender {
    UINib *nib = [UINib nibWithNibName:@"LSTPopViewTestView" bundle:nil];
    LSTPopViewTestView *view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;

   
    
        
    LSTPopView *popView = [LSTPopView initWithCustomView:view popStyle:1 dismissStyle:1];
    
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
               popView.dismissStyle = LSTDismissStyleDropToTop;
           }
               break;
           case 2:
           {
               popView.dismissStyle = LSTDismissStyleDropToLeft;
           }
               break;
           case 3:
           {
               popView.dismissStyle = LSTDismissStyleDropToBottom;
           }
               break;
           case 4:
           {
               popView.dismissStyle = LSTDismissStyleDropToRight;
           }
               break;
           default:
           {
               popView.dismissStyle = LSTPopStyleNO;
           }
               break;
       }
    
    
    popView.popBGAlpha = [self.popBGAlpha.text floatValue];
    popView.popDuration  = [self.popTime.text floatValue];
    popView.dismissDuration = [self.dismissTime.text floatValue];
    
    popView.bgClickBlock = ^{
        
//        [popView dismiss];
    };
    
    popView.isClickBGDismiss = self.bgDismissSwitch.on?YES:NO;
    
//    view.clickBlock = ^{
//        [popView dismiss];
//    };
    
    view.xStepperBlock = ^(float value) {
        popView.adjustX = value;
    };
    view.yStepperBlock = ^(float value) {
        popView.adjustY = value;
    };
    view.closeBlock = ^(id value) {
         [popView dismiss];
    };
    
    [popView pop];
}

- (IBAction)resetAction:(UIButton *)sender {
    
    
    
}



#pragma mark - ***** Lazy Loading 懒加载 *****





@end
