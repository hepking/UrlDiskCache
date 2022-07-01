//
//  AppDelegate.m
//  UrlDiskCache
//
//  Created by hpking　 on 15/10/7.
//  Copyright © 2015年 hpking　. All rights reserved.
//

#import "AppDelegate.h"
#import "AIURLCache.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 各种资源过期时间
    NSTimeInterval assetsTimeout = 60*60*24*2;
    NSTimeInterval htmlTimeout = 60*5;
    
    AIURLCache *sharedCache = [[AIURLCache alloc] initWithMemoryCapacity:1024*1024*4 diskCapacity: 1024*1024*10 diskPath:@"urlCache"];
    
    [sharedCache cacheResourcesForURL:@"http://jonoon.iuact.com" withMIMEType:allImages timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://jonoon.iuact.com" withMIMEType:html timeOutInterval:htmlTimeout];
    [sharedCache cacheResourcesForURL:@"http://jonoon.iuact.com/app" withMIMEType:css timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://jonoon.iuact.com/app" withMIMEType:js timeOutInterval:assetsTimeout];
    
    [sharedCache cacheResourcesForURL:@"http://7xix44.com1.z0.glb.clouddn.com" withMIMEType:all timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://www.google-analytics.com" withMIMEType:js timeOutInterval:assetsTimeout];
    
    
//    [sharedCache cacheResourcesForURL:@"http://oyster.ignimgs.com/ignmedia/wikimaps" withMIMEType:allImages timeOutInterval:assetsTimeout];
//    [sharedCache cacheResourcesForURL:@"http://oyster.ignimgs.com/mediawiki" withMIMEType:allImages timeOutInterval:assetsTimeout];
//    [sharedCache cacheResourcesForURL:@"http://oystatic.ignimgs.com/src/ignmediamobile" withMIMEType:allImages timeOutInterval:assetsTimeout];
//    [sharedCache cacheResourcesForURL:@"http://m.ign.com/wikis" withMIMEType:html timeOutInterval:htmlTimeout];
//    [sharedCache cacheResourcesForURL:@"http://www.ign.com/maps" withMIMEType:html timeOutInterval:htmlTimeout];
//    [sharedCache cacheResourcesForURL:@"http://oystatic.ignimgs.com" withMIMEType:css timeOutInterval:assetsTimeout];
//    [sharedCache cacheResourcesForURL:@"http://oystatic.ignimgs.com" withMIMEType:js timeOutInterval:assetsTimeout];
    
    
    [NSURLCache setSharedURLCache:sharedCache];
    
    return YES;
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

@end
