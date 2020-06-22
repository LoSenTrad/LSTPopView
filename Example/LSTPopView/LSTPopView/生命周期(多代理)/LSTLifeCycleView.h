//
//  LSTLifeCycleView.h
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/6/6.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LSTPopView.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSTLifeCycleView : UIView <LSTPopViewProtocol>


/** 倒计时lab */
@property (nonatomic,strong) UILabel *timeLab;

@end

NS_ASSUME_NONNULL_END
