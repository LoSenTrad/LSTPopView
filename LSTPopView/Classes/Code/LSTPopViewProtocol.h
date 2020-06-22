//
//  LSTPopViewProtocol.h
//  LSTCategory
//
//  Created by LoSenTrad on 2020/5/30.
//

#import <Foundation/Foundation.h>
@class LSTPopView;

NS_ASSUME_NONNULL_BEGIN

@protocol LSTPopViewProtocol <NSObject>


/** 点击弹框 回调 */
- (void)lst_PopViewBgClickForPopView:(LSTPopView *)popView;
/** 长按弹框 回调 */
- (void)lst_PopViewBgLongPressForPopView:(LSTPopView *)popView;




// ****** 生命周期 ******
/** 将要显示 */
- (void)lst_PopViewWillPopForPopView:(LSTPopView *)popView;
/** 已经显示完毕 */
- (void)lst_PopViewDidPopForPopView:(LSTPopView *)popView;
/** 倒计时进行中 timeInterval:时长  */
- (void)lst_PopViewCountDownForPopView:(LSTPopView *)popView forCountDown:(NSTimeInterval)timeInterval;
/** 倒计时倒计时完成  */
- (void)lst_PopViewCountDownFinishForPopView:(LSTPopView *)popView;
/** 将要开始移除 */
- (void)lst_PopViewWillDismissForPopView:(LSTPopView *)popView;
/** 已经移除完毕 */
- (void)lst_PopViewDidDismissForPopView:(LSTPopView *)popView;
//***********************




@end

NS_ASSUME_NONNULL_END
