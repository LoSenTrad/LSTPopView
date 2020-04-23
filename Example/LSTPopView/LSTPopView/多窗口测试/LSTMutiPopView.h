//
//  LSTMutiPopView.h
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/3/31.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LSTMutiPopViewBlock)(void);

NS_ASSUME_NONNULL_BEGIN


@interface LSTMutiPopView : UIView

/** <#...#> */
@property (nonatomic, copy) LSTMutiPopViewBlock closeBlock;

@end

NS_ASSUME_NONNULL_END
