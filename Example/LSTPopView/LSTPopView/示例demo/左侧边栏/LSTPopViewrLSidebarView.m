//
//  LSTPopViewrLSidebarView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/24.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewrLSidebarView.h"

@interface LSTPopViewrLSidebarView ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation LSTPopViewrLSidebarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imgView.layer.cornerRadius = 40;
    self.imgView.layer.masksToBounds = YES;
    
}

@end
