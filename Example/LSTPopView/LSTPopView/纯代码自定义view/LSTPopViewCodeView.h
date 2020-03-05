//
//  LSTPopViewCodeView.h
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/2/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^LSTPopViewCodeViewBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface LSTPopViewCodeView : UIView

/** <#...#> */
@property (nonatomic, copy) LSTPopViewCodeViewBlock closeBlock;

@end

NS_ASSUME_NONNULL_END
