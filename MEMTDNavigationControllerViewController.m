//
//  MEMTDNavigationControllerViewController.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/24/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMTDNavigationControllerViewController.h"
#import "MEMGameKitHelper.h"



@interface MEMTDNavigationControllerViewController ()

@end

@implementation MEMTDNavigationControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Game Center
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(showAuthenticationViewController)
                                                name:PresentAuthenticationViewController
                                              object:nil];
    
    [[MEMGameKitHelper sharedGameKitHelper]
     authenticateLocalPlayer];
    

}
- (void)showAuthenticationViewController
{
    MEMGameKitHelper *gameKitHelper = [MEMGameKitHelper sharedGameKitHelper];
    
    [self.topViewController presentViewController:
     gameKitHelper.authenticationViewController
                                         animated:YES
                                       completion:nil];
    
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
