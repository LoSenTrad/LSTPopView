//
//  LSTPopViewXibView.m
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/2/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewXibView.h"


@interface LSTPopViewXibView ()

@property (weak, nonatomic) IBOutlet UIView *myView;

@end

@implementation LSTPopViewXibView



- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgBtn.adjustsImageWhenHighlighted = NO;
    self.bgBtn.adjustsImageWhenDisabled = NO;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popViewBgViewTap)];
    [self.myView addGestureRecognizer:tap];
    
}

- (void)popViewBgViewTap {
    
}

- (IBAction)clickAction:(UIButton *)sender {
    
    if (self.clickBlock) {
        self.clickBlock();
    }
    
}

- (IBAction)btnAction:(UIButton *)sender {
    
}

@end
