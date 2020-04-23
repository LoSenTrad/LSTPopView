//
//  LSTPopViewTestView.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/3/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTestView.h"

@implementation LSTPopViewTestView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.xStepper.minimumValue = -100;
    self.xStepper.maximumValue = 100;
    self.xStepper.stepValue = 5.0;
    
    
    self.yStepper.minimumValue = -100;
    self.yStepper.maximumValue = 100;
    self.yStepper.stepValue = 5.0;
    
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
