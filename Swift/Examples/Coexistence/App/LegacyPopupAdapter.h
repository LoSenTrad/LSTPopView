#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// This is an adapter for the example consumer, not a new OC library API.
/// Its header deliberately exposes only UIKit/Foundation types: importing the
/// original LSTPopView header into Swift would introduce another short type
/// name LSTPopView alongside the native Swift type.
@interface LegacyPopupAdapter : NSObject

- (instancetype)initWithHost:(UIView *)host NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// Nil after the original popup has been dismissed and deallocated. Calling
/// pop again creates a fresh original OC instance, following its ownership API.
@property (nonatomic, readonly, nullable) UIView *popupView;
@property (nonatomic, readonly) NSString *runtimeClassName;
@property (nonatomic, readonly) NSUInteger didPopCount;
@property (nonatomic, readonly) NSUInteger didDismissCount;
@property (nonatomic, copy, nullable) void (^onDidPop)(void);
@property (nonatomic, copy, nullable) void (^onDidDismiss)(void);

- (void)pop;
- (void)dismiss;
+ (NSUInteger)registeredPopupCount;
+ (void)removeAllLegacyPopups;
+ (BOOL)isRealTimerClassLoaded;

@end

NS_ASSUME_NONNULL_END
