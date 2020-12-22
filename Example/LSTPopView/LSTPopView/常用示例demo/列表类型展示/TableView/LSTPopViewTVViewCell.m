//
//  LSTPopViewTVViewCell.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/12/16.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTPopViewTVViewCell.h"
#import <UIColor+LSTColor.h>
#import <LSTControlEvents.h>
#import "LSTPopViewTVCellView.h"
#import <UIView+LSTView.h>
#import <LSTGestureEvents.h>



@interface LSTPopViewTVViewCell ()





@end


@implementation LSTPopViewTVViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.titleLab.layer.cornerRadius = 25;
    self.titleLab.layer.masksToBounds = YES;
    
    self.titleLab.textColor = UIColor.whiteColor;
    self.titleLab.backgroundColor = self.lst_RandomColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
  
}

//随机色
- (nonnull LSTColor *)lst_RandomColor {
    return [UIColor lst_ColorWith8BitRed:arc4random_uniform(255) green:arc4random_uniform(255) blue:arc4random_uniform(255) alpha:1];
}



@end
