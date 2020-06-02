//
//  LSTPopViewProtocol.h
//  LSTCategory
//
//  Created by LoSenTrad on 2020/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSTPopViewProtocol <NSObject>


/** 点击弹框 回调 */
- (void)lst_PopViewBgClick;
/** 长按弹框 回调 */
- (void)lst_PopViewBgLongPress;

- (void)lst_PopViewDidDismiss111;


// ****** 生命周期 ******
/** 将要显示 */
- (void)lst_PopViewWillPop;
/** 已经显示完毕 */
- (void)lst_PopViewDidPop;
/** 将要开始移除 */
- (void)lst_PopViewWillDismiss;
/** 已经移除完毕 */
- (void)lst_PopViewDidDismiss;
//***********************


@end

NS_ASSUME_NONNULL_END
