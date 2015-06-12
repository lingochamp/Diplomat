//
//  AppDelegate.m
//  Diplomat
//
//  Created by Cloud Dai on 11/5/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "AppDelegate.h"

#import "WeiboProxy.h"
#import "WechatProxy.h"
#import "QQProxy.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [self configShareSDK];
  // Override point for customization after application launch.
  return YES;
}

- (void)configShareSDK
{
  [[Diplomat sharedInstance] registerWithConfigurations:@{kDiplomatTypeWeibo: @{kDiplomatAppIdKey: @"2045436852",
                                                                               kDiplomatAppRedirectUrlKey: @"http://www.sina.com"},
                                                         kDiplomatTypeWechat: @{kDiplomatAppIdKey: @"wxd930ea5d5a258f4f",
                                                                                kDiplomatAppSecretKey: @"db426a9829e4b49a0dcac7b4162da6b6"},
                                                         kDiplomatTypeQQ: @{kDiplomatAppIdKey: @"222222"}}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [[Diplomat sharedInstance] handleOpenURL:url];
}

@end
