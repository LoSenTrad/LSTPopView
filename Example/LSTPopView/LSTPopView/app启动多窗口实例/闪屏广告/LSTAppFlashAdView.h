//
//  LSTAppFlashAdView.h
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/12/9.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LSTAppFlashAdViewBlock)(id sender);

NS_ASSUME_NONNULL_BEGIN

@interface LSTAppFlashAdView : UIView
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topH;

/** <#...#> */
@property (nonatomic, copy) LSTAppFlashAdViewBlock skipBlock;

@end

NS_ASSUME_NONNULL_END
