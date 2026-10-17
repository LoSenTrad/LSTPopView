#import "LegacyPopupAdapter.h"
#import <LSTPopView/LSTPopView.h>

@interface LegacyPopupAdapter ()
/// The original OC version sends didDismiss from dealloc. Holding a displayed
/// popup strongly in this adapter would prevent its documented final callback.
@property (nonatomic, weak) LSTPopView *popup;
/// Keep a newly created popup alive only until pop transfers ownership to the
/// original manager and its superview. This is never a displayed-popup owner.
@property (nonatomic, strong, nullable) LSTPopView *pendingPopup;
@property (nonatomic, weak) UIView *host;
@property (nonatomic, copy, readwrite) NSString *runtimeClassName;
/// Original OC stores didDismiss observers in a weak NSHashTable. The consumer
/// must own that copied block for as long as the adapter receives callbacks.
@property (nonatomic, copy) void (^retainedDidPopObserver)(void);
@property (nonatomic, copy) void (^retainedDidDismissObserver)(void);
@property (nonatomic, readwrite) NSUInteger didPopCount;
@property (nonatomic, readwrite) NSUInteger didDismissCount;
@end

@implementation LegacyPopupAdapter

- (instancetype)initWithHost:(UIView *)host {
    NSParameterAssert([NSThread isMainThread]);
    self = [super init];
    if (!self) { return nil; }

    _host = host;
    __weak typeof(self) weakSelf = self;
    _retainedDidPopObserver = [^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        strongSelf.didPopCount += 1;
        if (strongSelf.onDidPop) { strongSelf.onDidPop(); }
    } copy];
    _retainedDidDismissObserver = [^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        strongSelf.didDismissCount += 1;
        if (strongSelf.onDidDismiss) { strongSelf.onDidDismiss(); }
    } copy];
    [self prepareOriginalPopup];
    return self;
}

- (void)prepareOriginalPopup {
    UIView *host = self.host;
    NSAssert(host != nil, @"The example's host must outlive the adapter");
    if (!host) { return; }

    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 110)];
    content.text = @"Objective-C · original LSTPopView";
    content.textAlignment = NSTextAlignmentCenter;
    content.numberOfLines = 0;
    content.backgroundColor = UIColor.systemOrangeColor;
    content.layer.cornerRadius = 16;
    content.clipsToBounds = YES;

    // These are the original 0.3.10 header's selectors and enum constants.
    // Supplying an explicit host avoids relying on a process-wide key window.
    LSTPopView *popup = [LSTPopView initWithCustomView:content
                                        parentView:host
                                          popStyle:LSTPopStyleNO
                                      dismissStyle:LSTDismissStyleNO];
    NSAssert(popup != nil, @"Original OC factory must instantiate a popup");
    popup.identifier = @"coexistence.objective-c";
    popup.adjustY = -75;
    popup.isClickBgDismiss = YES;
    popup.popViewDidPopBlock = self.retainedDidPopObserver;
    popup.popViewDidDismissBlock = self.retainedDidDismissObserver;
    self.runtimeClassName = NSStringFromClass(popup.class);
    self.popup = popup;
    self.pendingPopup = popup;
}

- (nullable UIView *)popupView { return self.popup; }
- (void)pop {
    NSAssert([NSThread isMainThread], @"Call the legacy UIKit API on main");
    if (!self.popup) { [self prepareOriginalPopup]; }
    LSTPopView *popup = self.popup;
    // While an existing instance is visible or finishing dismissal, a second
    // button tap does not repop/re-register it. After dealloc the next tap
    // creates a fresh instance and attaches the still-owned callback blocks.
    if (!self.pendingPopup || !popup) { return; }
    [popup pop];
    self.pendingPopup = nil;
}
- (void)dismiss {
    NSAssert([NSThread isMainThread], @"Call the legacy UIKit API on main");
    LSTPopView *popup = self.popup;
    self.pendingPopup = nil;
    [popup dismiss];
    // The temporary strong local ends here. The original library's own
    // dispatch_after(0) removal can then deallocate it and deliver didDismiss.
}
+ (NSUInteger)registeredPopupCount { return [LSTPopView getAllPopView].count; }
+ (void)removeAllLegacyPopups { [LSTPopView removeAllPopView]; }
+ (BOOL)isRealTimerClassLoaded { return NSClassFromString(@"LSTTimer") != Nil; }

@end
