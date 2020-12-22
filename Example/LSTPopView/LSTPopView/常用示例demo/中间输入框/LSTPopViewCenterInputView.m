//
//  LSTPopViewCenterInputView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/24.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewCenterInputView.h"

@interface LSTPopViewCenterInputView ()



@end

@implementation LSTPopViewCenterInputView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
}

@end
