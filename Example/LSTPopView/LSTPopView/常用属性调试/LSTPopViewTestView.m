//
//  LSTPopViewTestView.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/3/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTestView.h"
#import <UIView+LSTPV.h>

@interface LSTPopViewTestView ()

/** <#...#> */
@property (nonatomic, assign) double wValue;

/** <#...#> */
@property (nonatomic, assign) double sValue;
/** <#...#> */
@property (nonatomic, assign) double xValue;
/** <#...#> */
@property (nonatomic, assign) double yValue;

@end

@implementation LSTPopViewTestView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sValue = 0;
    self.xValue = 0;
    self.yValue = 0;
    self.wValue = 0;
    
    self.timeLab.layer.cornerRadius = 15;
    self.timeLab.layer.masksToBounds = YES;
    
    self.xStepper.minimumValue = -100;
    self.xStepper.maximumValue = 100;
    self.xStepper.stepValue = 5.0;
    
    
    self.yStepper.minimumValue = -100;
    self.yStepper.maximumValue = 100;
    self.yStepper.stepValue = 5.0;
    
    self.heightStepper.minimumValue = -100;
    self.heightStepper.maximumValue = 100;
    self.heightStepper.stepValue = 5.0;
    
    [self.xStepper addTarget:self action:@selector(xValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    [self.yStepper addTarget:self action:@selector(yValueChanged:) forControlEvents:(UIControlEventValueChanged)];
}

- (void)xValueChanged:(UIStepper *)sender{
    
    self.xLab.text = [NSString stringWithFormat:@"%1.0lf",sender.value];
    if (self.xStepperBlock) {
        self.xStepperBlock(sender.value);
    }
}

- (void)yValueChanged:(UIStepper *)sender{
    
    self.yLab.text = [NSString stringWithFormat:@"%1.0lf",sender.value];
    if (self.yStepperBlock) {
        self.yStepperBlock(sender.value);
    }
}
- (IBAction)height:(UIStepper *)sender {
    
    if (sender.value>self.sValue) {
        self.height = self.height+10;
    }else{
        self.height = self.height-10;
    }
    self.sValue = sender.value;
}
- (IBAction)width:(UIStepper *)sender {
    if (sender.value>self.wValue) {
        self.width = self.width+10;
    }else{
        self.width = self.width-10;
    }
    self.wValue = sender.value;
}

- (IBAction)closePopView:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock(nil);
    }
    
}

- (IBAction)pushVCAction:(UIButton *)sender {
    if (self.pushBlock) {
        self.pushBlock(sender);
    }
}

@end
