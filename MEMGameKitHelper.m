//
//  MEMGameKitHelper.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/24/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMGameKitHelper.h"

NSString *const PresentAuthenticationViewController =
@"present_authentication_view_controller";

@interface MEMGameKitHelper ()<GKGameCenterControllerDelegate>

@end

@implementation MEMGameKitHelper
{
    BOOL _enableGameCenter;
}

+(instancetype)sharedGameKitHelper
{
    static MEMGameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[MEMGameKitHelper alloc]init];
    });
    return sharedGameKitHelper;
}

-(id)init
{
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

-(void)authenticateLocalPlayer
{
    // 1
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    // 2
    localPlayer.authenticateHandler =
        ^(UIViewController *viewController, NSError *error) {
        // 3
        [self setLastError:error];
        
        if (viewController != nil) {
                // 4
            [self setAuthenticationViewController:viewController];
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            // 5
            _enableGameCenter = YES;
        } else {
            // 6
            _enableGameCenter = NO;
        }
    };
}


-(void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PresentAuthenticationViewController object:self];
    }
}
- (void)showGKGameCenterViewController:(UIViewController *)viewController
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    // 1
    GKGameCenterViewController *gameCenterViewController = [[GKGameCenterViewController alloc]init];
    
    // 2
    gameCenterViewController.gameCenterDelegate = self;
    
    // 3
    gameCenterViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    
    // 4
    [viewController presentViewController:gameCenterViewController
                                 animated:YES
                               completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"MEMGameKitHelper ERROR: %@", [[_lastError userInfo]description]);
    }
}


-(void)reportScore:(int64_t)score forLeaderboardID:(NSString *)leaderboardID
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    
    GKScore *scoreReporter =
    [[GKScore alloc]initWithLeaderboardIdentifier:leaderboardID];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    
    [GKScore reportScores:scores
    withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
    }];
}






















@end
