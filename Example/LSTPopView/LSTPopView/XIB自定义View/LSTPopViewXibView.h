//
//  LSTPopViewXibView.h
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/2/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void(^LSTPopViewXibViewBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface LSTPopViewXibView : UIView

/** <#...#> */
@property (nonatomic, copy) LSTPopViewXibViewBlock clickBlock;
@property (weak, nonatomic) IBOutlet UIButton *bgBtn;

@end

NS_ASSUME_NONNULL_END
