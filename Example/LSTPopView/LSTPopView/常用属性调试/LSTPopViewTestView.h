//
//  LSTPopViewTestView.h
//  LSTAlertView_Example
//
//  Created by LoSenTrad on 2020/3/3.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^stepperBlock)(float value);
typedef void(^LSTPopViewTestViewBlock)(id value);

NS_ASSUME_NONNULL_BEGIN

@interface LSTPopViewTestView : UIView
@property (weak, nonatomic) IBOutlet UIStepper *xStepper;
@property (weak, nonatomic) IBOutlet UIStepper *heightStepper;
@property (weak, nonatomic) IBOutlet UIStepper *yStepper;
@property (weak, nonatomic) IBOutlet UILabel *xLab;
@property (weak, nonatomic) IBOutlet UILabel *yLab;
/** <#...#> */
@property (nonatomic, copy) stepperBlock xStepperBlock;
/** <#...#> */
@property (nonatomic, copy) stepperBlock yStepperBlock;
/** <#...#> */
@property (nonatomic, copy) LSTPopViewTestViewBlock closeBlock;
/** <#...#> */
@property (nonatomic, copy) LSTPopViewTestViewBlock pushBlock;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;


@end

NS_ASSUME_NONNULL_END
