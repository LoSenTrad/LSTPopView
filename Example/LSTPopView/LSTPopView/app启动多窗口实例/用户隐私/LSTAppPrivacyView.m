//
//  LSTAppPrivacyView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/12/9.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTAppPrivacyView.h"

@implementation LSTAppPrivacyView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

@end
