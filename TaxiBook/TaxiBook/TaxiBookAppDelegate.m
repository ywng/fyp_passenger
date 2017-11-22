//
//  TaxiBookAppDelegate.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 30/10/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "TaxiBookAppDelegate.h"
#import <NSUserDefaults+SecureAdditions.h>
#import <GoogleMaps/GoogleMaps.h>


@implementation TaxiBookAppDelegate

- (void)setNSSecret
{
    NSString *userDefaultKey  = @"thisIsASecretKey";
    [[NSUserDefaults standardUserDefaults] setSecret:userDefaultKey];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    
    // Override point for customization after application launch.
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNSSecret];
    
    // start google map service
    [GMSServices provideAPIKey:TaxiBookGoogleAPIIOSKey];
    
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"receive remote notification dict %@", userInfo);
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    
    if (state != UIApplicationStateActive) {
        NSInteger badgeValue = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
        
        NSLog(@"Total badge Value:%ld", (long)badgeValue);
        
        for (id key in userInfo) {
            NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeValue;
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"register for remote notification device token %@", hexToken);
    
    //    BOOL userLogin = [[NSUserDefaults standardUserDefaults] secretObjectForKey:TaxiBookInternalKeySessionToken] == nil? NO: YES;
    //
    //    if (userLogin) {
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:SensbeatNotificationUserDeviceTokenRetrieved object:nil userInfo:@{@"deviceToken": hexToken}];
    //    }
    
    // directly save the device token
    [[NSUserDefaults standardUserDefaults] setSecretObject:hexToken forKey:TaxiBookInternalKeyAPNSToken];
    BOOL userLogin = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyLoggedIn];
    if (userLogin) {
        // send to server to update
        
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"fail to register for remote notification %ld %@",(long)error.code, error.localizedDescription);
}



@end
