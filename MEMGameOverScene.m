//
//  MEMGameOverScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 7/24/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMGameOverScene.h"
#import "MEMStoreScene.h"
#import "MEMTutorialScene.h"
#import "MEMShareScene.h"
#import "MEMMyScene.h"

#import "MEMGameData.h"

@implementation MEMGameOverScene
-(void)setUpSceneSpecificCode
{
    [MEMGameData sharedGameData].adCount ++;
    NSLog(@"Ad count: %i", [MEMGameData sharedGameData].adCount);
    NSLog(@"Score %i", [MEMGameData sharedGameData].score);
    
    // This prevents manipulation of adcount
    if ([MEMGameData sharedGameData].adCount < -1) {
        [MEMGameData sharedGameData].adCount = 7;
    }
    if ([MEMGameData sharedGameData].dynamitePurse > 8) {
        [MEMGameData sharedGameData].dynamitePurse = 0;
    }
    
    // Caches Ad which will be presented at next GameOver
    if ([MEMGameData sharedGameData].adCount > 9) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cacheAd" object:self];
    }
}
-(void)setUpButtonTextures
{    
    SKTextureAtlas *buttonAtlas = [SKTextureAtlas atlasNamed:@"sign"];
    firstButtonTexture = [buttonAtlas textureNamed:@"StoreButton"];
    secondButtonTexture = [buttonAtlas textureNamed:@"HelpButton"];
    thirdButtonTexture = [buttonAtlas textureNamed:@"ShareButton"];
    fourthButtonTexture = [buttonAtlas textureNamed:@"PlayButton"];
}
-(void)createBlocks
{
    __weak typeof(self) weakSelf = self;
    firstButtonBlock = ^(void){
        MEMStoreScene *storeScene =[[MEMStoreScene alloc]initWithSize:weakSelf.size];
        [weakSelf.scene.view presentScene:storeScene];
    };
    secondButtonBlock = ^(void){
        MEMTutorialScene *helpScene = [[MEMTutorialScene alloc]initWithSize:weakSelf.size];
        [weakSelf.scene.view presentScene:helpScene];

    };
    thirdButtonBlock = ^(void){
        MEMShareScene *shareScene = [[MEMShareScene alloc]initWithSize:weakSelf.size];
        [weakSelf.scene.view presentScene:shareScene];
    };
    fourthButtonBlock = ^(void){
        MEMMyScene *gameScene = [[MEMMyScene alloc]initWithSize:weakSelf.size];
        [weakSelf.scene.view presentScene:gameScene];
    };
    
}
-(void)setUpButtons
{
    //menuNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + topButtonSize.height + 20);
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
