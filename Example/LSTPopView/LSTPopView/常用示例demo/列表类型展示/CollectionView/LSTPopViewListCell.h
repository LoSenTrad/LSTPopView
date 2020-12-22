//
//  LSTPopViewListCell.h
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/7/10.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSTPopViewListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

NS_ASSUME_NONNULL_END
