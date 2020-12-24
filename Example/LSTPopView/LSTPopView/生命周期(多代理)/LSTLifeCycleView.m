//
//  LSTLifeCycleView.m
//  LSTPopView_Example
//
//  Created by LoSenTrad on 2020/6/6.
//  Copyright © 2020 490790096@qq.com. All rights reserved.
//

#import "LSTLifeCycleView.h"
#import <UIView+LSTPV.h>
#import <Masonry.h>

@interface LSTLifeCycleView ()

/** <#.....#> */
@property (nonatomic,strong) UIImageView *shareImgView;
/** <#.....#> */
@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation LSTLifeCycleView

#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

#pragma mark - ***** setter 设置器/数据处理 *****


#pragma mark - ***** setupUI 界面布局 *****

- (void)initSubViews {
    
    [self addSubview:self.imgView];
    
    [self addSubview:self.timeLab];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    

    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(15);
    }];
    
}

#pragma mark - ***** other 其他 *****


#pragma mark - ***** LSTPopViewProtocol *****
/** 点击弹窗 回调 */
- (void)lst_PopViewBgClick {
    NSLog(@"点了弹窗");
    
}
/** 长按弹窗 回调 */
- (void)lst_PopViewBgLongPress {
     NSLog(@"长按弹窗");
}


// ****** 生命周期 ******
/** 将要显示 */
- (void)lst_PopViewWillPopForPopView:(LSTPopView *)popView {
     NSLog(@"将要显示");
}
/** 已经显示完毕 */
- (void)lst_PopViewDidPopForPopView:(LSTPopView *)popView {
     NSLog(@"已经显示完毕");
}
- (void)lst_PopViewCountDownForPopView:(LSTPopView *)popView forCountDown:(NSTimeInterval)timeInterval {
    NSLog(@"倒计时---%u",timeInterval);
}
- (void)lst_PopViewCountDownFinishForPopView:(LSTPopView *)popView {
    NSLog(@"倒计时完成");
}
/** 将要开始移除 */
- (void)lst_PopViewWillDismissForPopView:(LSTPopView *)popView {
     NSLog(@"将要开始移除");
}
/** 已经移除完毕 */
- (void)lst_PopViewDidDismissForPopView:(LSTPopView *)popView {
     NSLog(@"已经移除完毕");
}

#pragma mark - ***** Lazy Loading 懒加载 *****


- (UIImageView *)shareImgView {
    if(_shareImgView) return _shareImgView;
    _shareImgView = [UIImageView new];
    _shareImgView.image = [UIImage imageNamed:@"lst_logo"];
    _shareImgView.backgroundColor = UIColor.yellowColor;
    _shareImgView.layer.cornerRadius = 10;
    _shareImgView.layer.masksToBounds = YES;
    return _shareImgView;
}

- (UIImageView *)imgView {
    if(_imgView) return _imgView;
    _imgView = [[UIImageView alloc] init];
    _imgView.image = [UIImage imageNamed:@"lst_logo"];
    _imgView.layer.cornerRadius = 5;
    _imgView.layer.masksToBounds = YES;
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
//    _imgView.alpha = 0.0;
    return _imgView;
}

- (UILabel *)timeLab {
    if(_timeLab) return _timeLab;
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = UIColor.whiteColor;
    _timeLab.font = [UIFont systemFontOfSize:50];
    return _timeLab;
}

@end
