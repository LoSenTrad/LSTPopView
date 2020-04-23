//
//  LSTKeyboardXibView.h
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/4/15.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^LSTKeyboardXibViewBlock)(id sender);

NS_ASSUME_NONNULL_BEGIN

@interface LSTKeyboardXibView : UIView

/** <#...#> */
@property (nonatomic, copy) LSTKeyboardXibViewBlock addBlock;

@end

NS_ASSUME_NONNULL_END
