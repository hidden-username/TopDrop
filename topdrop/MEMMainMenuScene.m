//
//  MEMMainMenuScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/26/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//
#import "MEMMainMenuScene.h"
#import "MEMMyScene.h"
#import "MEMShareScene.h"
#import "MEMGameOverScene.h"
#import "MEMTutorialScene.h"
#import "MEMGameData.h"
#import <Social/Social.h>

@implementation MEMMainMenuScene


-(void)setUpButtonTextures
{
    SKTextureAtlas *buttonAtlas = [SKTextureAtlas atlasNamed:@"sign"];
    firstButtonTexture = [buttonAtlas textureNamed:@"BigButton"];
    secondButtonTexture = [buttonAtlas textureNamed:@"PlayButton"];
    thirdButtonTexture = [buttonAtlas textureNamed:@"MoreButton"];
}
-(void)createBlocks
{
    __weak typeof(self) weakSelf = self;
    secondButtonBlock = ^(void){
        // If first time playing we want play to take user to tutorial.
        if ([MEMGameData sharedGameData].goldPurse == 0 && [MEMGameData sharedGameData].highScore == 0) {
            MEMTutorialScene *turorialScene = [[MEMTutorialScene alloc]initWithSize:weakSelf.size];
            [weakSelf.view presentScene:turorialScene];
            
        } else {
            MEMMyScene *newGame = [[MEMMyScene alloc]initWithSize:weakSelf.size];
            [weakSelf.view presentScene:newGame];
        }
    };
    
    thirdButtonBlock = ^(void){
        MEMGameOverScene *moreScene = [[MEMGameOverScene alloc]initWithSize:weakSelf.size];
        [weakSelf.view presentScene:moreScene];
    };
    
}
-(void)setUpButtons
{
    
    // Over-ride MenuNode posiion Because Big Sign
    menuNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 95);// change menu height here
    
    
    firstButton = [[MEMSpriteButton alloc]initWithTexture:firstButtonTexture size:CGSizeMake(200, 150) position:firstButton.position zPosition:3];
    [menuNode addChild:firstButton];
    
    secondButton = [[MEMSpriteButton alloc]initWithTexture:secondButtonTexture size:buttonSize position:secondButton.position zPosition:2];
    [menuNode addChild:secondButton];
    
    thirdButton = [[MEMSpriteButton alloc]initWithTexture:thirdButtonTexture size:buttonSize position:thirdButton.position zPosition:1];
    [menuNode addChild:thirdButton];
    
    
    [self addChild:menuNode];
}
-(void)setUpHud
{
    NSLog(@"Main Menu should not contain HUD");
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        self.view.userInteractionEnabled = YES;
        
        
        if ([self nodeAtPoint:location] == firstButton) {
            return;
        }
        if ([self nodeAtPoint:location] == secondButton) {
            [secondButton runTappedActionWithBlock:secondButtonBlock];
        }
        if ([self nodeAtPoint:location] == thirdButton) {
            [thirdButton runTappedActionWithBlock:thirdButtonBlock];
        }
        
    }
}
@end
