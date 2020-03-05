//
//  LSTPopViewXibView.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/2/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewXibView.h"

@implementation LSTPopViewXibView



- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgBtn.adjustsImageWhenHighlighted = NO;
    self.bgBtn.adjustsImageWhenDisabled = NO;
}

- (IBAction)clickAction:(UIButton *)sender {
    
    if (self.clickBlock) {
        self.clickBlock();
    }
    
}


@end
