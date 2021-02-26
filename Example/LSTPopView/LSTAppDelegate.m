//
//  LSTAppDelegate.m
//  LSTPopView
//
//  Created by 490790096@qq.com on 03/06/2020.
//  Copyright (c) 2020 490790096@qq.com. All rights reserved.
//

#import "LSTAppDelegate.h"
#import "LSTPopViewVC.h"
#import <LSTPopView.h>
#import "LSTLaunchMutiPopViewVC.h"
#import <Bugly/Bugly.h>

@implementation LSTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [Bugly startWithAppId:@"a0b4f38d89"];

  
#ifdef DEBUG
    //测试开启调试log
    [LSTPopView setLogStyle:LSTPopViewLogStyleALL];
#else
    //正式关闭调试log
    [LSTPopView setLogStyle:LSTPopViewLogStyleNO];
#endif

    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    LSTPopViewVC *vc = [[LSTPopViewVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    
    
    //以下是通过优先级机制 进行了弹窗的排序 逐个展示
    
    //打开闪屏ad
//    [LSTLaunchMutiPopViewVC appFlashAdPopView];
//    //打开app新版本更新(模拟网络请求延时)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [LSTLaunchMutiPopViewVC appUpdatePopView];
//    });
//    //打开app首页广告弹窗//打开app新版本更新(模拟网络请求延时)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [LSTLaunchMutiPopViewVC appIndexAdPopView];
//    });
//    //打开推送弹窗
//    [LSTLaunchMutiPopViewVC appPushPopView];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
