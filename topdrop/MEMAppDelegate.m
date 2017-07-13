//
//  MEMAppDelegate.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/15/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "Chartboost.h"
#import "MEMAppDelegate.h"

#import "MEMGameData.h"
#import "MEMMainMenuScene.h"
// prevent background crash
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface MEMAppDelegate () <ChartboostDelegate>
@end

@implementation MEMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [[AVAudioSession sharedInstance] setActive:NO error:nil];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[AVAudioSession sharedInstance] setActive:NO error:nil];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Chart Boost SDK
    // Begin a user session.  Must not be dependent on user actions or any prior network requests.
    // Must be called every time you app becomes active.

  
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
 
    
    
    
    
    [Chartboost startWithAppId:@"5384dadac26ee4687501364d" appSignature:@"8542dcd72fc1479173563b7bcaa6a4c4b4bfa77b" delegate:self];
    
    // Show an ad at location "CBLocationHomeScreen"
    //[[Chartboost sharedChartboost] showInterstitial:CBLocationHomeScreen];
}
// Prevents ads in first session of game after download
-(BOOL)shouldRequestInterstitialsInFirstSession
{
    return NO;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[MEMGameData sharedGameData] save];
}

@end
