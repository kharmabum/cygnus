//
//  CYGAppDelegate.m
//  Cygnus
//
//  Created by IO on 2/4/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGAppDelegate.h"
#import <TSMessage.h>
#import "CYGMapViewController.h"
#import "CYGProfileViewController.h"
#import "CYGUser.h"
#import "CYGPoint.h"


@implementation CYGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self applyStylesheet];
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController pushViewController:[[CYGMapViewController alloc] init] animated:NO];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    [TSMessage setDefaultViewController: self.window.rootViewController];
    
    [self performBlockInBackground:^{
        [CYGUser registerSubclass];
        [CYGPoint registerSubclass];
        [PFUser enableAutomaticUser];
        PFACL *defaultACL = [PFACL ACL];
        [defaultACL setPublicReadAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        [Parse setApplicationId:kCYGParseApplicationId clientKey:kCYGParseClientKey];
        [PFTwitterUtils initializeWithConsumerKey:kCYGTwitterKey consumerSecret:kCYGTwitterSecret];
    }];
    
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

- (void)applyStylesheet
{
//    [self.window setTintColor:tintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}


@end
