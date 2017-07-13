//
//  MEMShareScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 6/22/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//
#import "MEMMyScene.h"
#import "MEMShareScene.h"
#import "MEMGameOverScene.h"
#import "MEMGameData.h"
#import <Social/Social.h>

@implementation MEMShareScene
-(void)setUpButtonTextures
{
    SKTextureAtlas *buttonAtlas = [SKTextureAtlas atlasNamed:@"sign"];
    firstButtonTexture = [buttonAtlas textureNamed:@"GameCenterButton"];
    secondButtonTexture = [buttonAtlas textureNamed:@"FacebookButton"];
    thirdButtonTexture = [buttonAtlas textureNamed:@"TwitterButton"];
    fourthButtonTexture = [buttonAtlas textureNamed:@"BackButton"];
}
-(void)createBlocks
{
    __weak typeof(self) weakSelf = self;
    firstButtonBlock = ^(void){
        [[MEMGameKitHelper sharedGameKitHelper]
         showGKGameCenterViewController:weakSelf.view.window.rootViewController];
    };
    
    secondButtonBlock = ^(void){
        SLComposeViewController *facebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebook setInitialText:[MEMGameData sharedGameData].newHighScore?[NSString stringWithFormat:@"Beat this. My new High Score, %i!", [MEMGameData sharedGameData].highScore]:[NSString stringWithFormat:@"Check out this awesome new game."]];
        [facebook addURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/topdrop/id881542391?ls=1&mt=8"]];
        [weakSelf.view.window.rootViewController presentViewController:facebook animated:YES completion:Nil];
    };
    
    thirdButtonBlock = ^(void){
        SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitter setInitialText:[MEMGameData sharedGameData].newHighScore?[NSString stringWithFormat:@"Beat this. My new High Score, %i!", [MEMGameData sharedGameData].highScore]:[NSString stringWithFormat:@"Check out this awesome new game."]];
        [twitter addURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/topdrop/id881542391?ls=1&mt=8"]];
        [weakSelf.view.window.rootViewController presentViewController:twitter animated:YES completion:Nil];
        
    };
    
    fourthButtonBlock = ^(void){
        MEMGameOverScene *gameOverScene = [[MEMGameOverScene alloc]initWithSize:weakSelf.size];
        [weakSelf.scene.view presentScene:gameOverScene];
    };
    
}
-(void)setUpButtons
{
    
    firstButton = [[MEMSpriteButton alloc]initWithTexture:firstButtonTexture size:topButtonSize position:firstButton.position zPosition:4];
    [menuNode addChild:firstButton];
    
    secondButton = [[MEMSpriteButton alloc]initWithTexture:secondButtonTexture size:buttonSize position:secondButton.position zPosition:3];
    [menuNode addChild:secondButton];
    
    thirdButton = [[MEMSpriteButton alloc]initWithTexture:thirdButtonTexture size:buttonSize position:thirdButton.position zPosition:2];
    [menuNode addChild:thirdButton];
    
    fourthButton = [[MEMSpriteButton alloc]initWithTexture:fourthButtonTexture size:buttonSize position:fourthButton.position zPosition:1];
    [menuNode addChild:fourthButton];
    
    [self addChild:menuNode];
}

@end
