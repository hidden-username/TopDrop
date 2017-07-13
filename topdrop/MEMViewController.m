//
//  MEMViewController.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/15/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//
#import "Chartboost.h"
#import "MEMViewController.h"
#import "MEMMainMenuScene.h"
#import "MEMMyScene.h"
#import "MEMTDNavigationControllerViewController.h"
#import "MEMGameData.h"


#import <MediaPlayer/MediaPlayer.h>
#import <StoreKit/StoreKit.h>

@interface MEMViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (strong, nonatomic) SKProduct *product;

-(void)getProductInfo;
@end
@implementation MEMViewController
{
    SKView *_skView;
}

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Necessary, if application quits during purchase, it should go through on re-launch
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buyGold)
                                                 name:@"buyGold"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cacheAD)
                                                 name:@"cacheAd"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAd)
                                                 name:@"showAd"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    /// This is Code to ask for Review
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Ask for Rating
    BOOL neverRate = [prefs boolForKey:@"neverRate"];
    
    
    
    NSUInteger launchCount = 0;
    //Get the number of launches
    launchCount = [prefs integerForKey:@"launchCount"];
    launchCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
    
    if (launchCount == 1) {
        [[MEMGameData sharedGameData] setInitialEquipment];
        [[MEMGameData sharedGameData] save];
    }
    
    if (!neverRate)
    {
        if ( (launchCount == 3) || (launchCount == 9) || (launchCount == 15) || (launchCount == 21) )
        {
            [self rateApp];
        }
    }
    [prefs synchronize];
    
    [self getProductInfo];
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // Configure the view.
    if (!_skView) {
        _skView = [[SKView alloc]initWithFrame:self.view.bounds];

    
   /// Create and configure the scene.
    MEMMainMenuScene * mainMenu = [[MEMMainMenuScene alloc] initWithSize:_skView.bounds.size];
    mainMenu.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene.
    [_skView presentScene:mainMenu];
    
    
    [self.view addSubview:_skView];

    }
}

- (void)willEnterForeground
{
    // Need to unpause the view, but not the scene.
    _skView.paused = NO;
   
}

- (void)willEnterBackground
{
    // Need to pause the view to prevent bad access, but also need to pause scene.
    _skView.scene.paused = YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark- StoreKit Methods
-(void)getProductInfo
{
    if ([SKPaymentQueue canMakePayments]) {
        
        NSMutableArray *productIdentifierList = [[NSMutableArray alloc]init];
        [productIdentifierList addObject:[NSString stringWithFormat:@"com.topdrop.1000gold"]];
        
        SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithArray:productIdentifierList]];
        
        request.delegate = self;
        [request start];
    } else {
        NSLog(@"InApp Puchase Not Registered");
    }
    
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    // Must change product = products[0], if i have multiple products.
    if (products.count != 0) {
        _product = products[0];
        NSLog(@"Ready For Purchase");
    } else {
        NSLog(@"Product Not Found");
    }
    products = response.invalidProductIdentifiers;
    
}
-(void)buyGold
{
    //NSLog(@"Purchase Gold Buttun Tapped");
    SKPayment *payment = [SKPayment paymentWithProduct:_product];
    [[SKPaymentQueue defaultQueue]addPayment:payment];
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                //NSLog(@"Gold Purse Before: %d", [MEMGameData sharedGameData].goldPurse);
                [MEMGameData sharedGameData].goldPurse += 1000;
                [[MEMGameData sharedGameData] save];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateHud" object:self];
                
               // NSLog(@"Gold Purse After: %d", [MEMGameData sharedGameData].goldPurse);
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction Failed");
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}



#pragma mark- ChartBoost Methods

-(void)cacheAD
{
    NSLog(@"Cached Ad");
    [[Chartboost sharedChartboost] cacheInterstitial:CBLocationMainMenu];
}
- (void)showAd
{
    if ([[Chartboost sharedChartboost] hasCachedInterstitial:CBLocationMainMenu]) {
        NSLog(@"Showing Ad");
        [[Chartboost sharedChartboost] showInterstitial:CBLocationMainMenu];
    } else {
        NSLog(@"No Cached Ad");
    }
}

#pragma mark- App Rate Methods
- (void)rateApp {
    BOOL neverRate = [[NSUserDefaults standardUserDefaults] boolForKey:@"neverRate"];
    
    if (neverRate != YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Rate Us!"
                                                        message:@"If you like it, show your support."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"No Thanks", @"Remind Me Later", @"RATE NOW", nil];
        alert.delegate = self;
        
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverRate"];

    }
    
    else if (buttonIndex == 1) {
        
    }
    
    else if (buttonIndex == 2) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverRate"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=881542391&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]]];
     
        // Main App Page
        //@"itms-apps://itunes.apple.com/us/app/topdrop/id881542391"
    }
}

@end
