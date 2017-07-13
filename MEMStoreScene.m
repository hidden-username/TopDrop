//
//  MEMStoreScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 7/24/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMStoreScene.h"
#import "MEMGameOverScene.h"

#import "MEMGameData.h"
@interface MEMStoreScene ()
@property (strong, nonatomic) UIAlertView *alert;
@end

@implementation MEMStoreScene


-(void)setUpSceneSpecificCode
{
    //__weak typeof(self) weakSelf = self;
    self.alert = [[UIAlertView alloc] initWithTitle:nil
                                            message:nil
                                            delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
    self.alert.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateHud)
                                                 name:@"updateHud"
                                               object:nil];
}
-(void)setUpButtonTextures
{
    SKTextureAtlas *buttonAtlas = [SKTextureAtlas atlasNamed:@"sign"];
    firstButtonTexture = [buttonAtlas textureNamed:@"BuyGold"];
    secondButtonTexture = [buttonAtlas textureNamed:@"BuyDynamite"];
    thirdButtonTexture = [buttonAtlas textureNamed:@"BuyPickAxe"];
    fourthButtonTexture = [buttonAtlas textureNamed:@"BackButton"];
}
-(void)createBlocks
{
    NSString *notEnoughMoney = [NSString stringWithFormat:@"Not enough Gold, purchase some or earn some."];
    __weak typeof(self) weakSelf = self;
    firstButtonBlock = ^(void){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"buyGold" object:weakSelf];
    };
    
    secondButtonBlock = ^(void){
        if ([MEMGameData sharedGameData].dynamitePurse >= 8) {
        
            weakSelf.alert.message = [NSString stringWithFormat:@"Dynamite is full max is 8."];
            [weakSelf.alert show];
            
        } else if ([MEMGameData sharedGameData].goldPurse < 50){
            
            weakSelf.alert.message = notEnoughMoney;
            [weakSelf.alert show];
        } else {
            [MEMGameData sharedGameData].goldPurse -= 50;
            [MEMGameData sharedGameData].dynamitePurse += 1;
            [weakSelf updateHud];
        }
        
  
    };
    
    thirdButtonBlock = ^(void){
        if ([MEMGameData sharedGameData].hasPickAxe) {
            weakSelf.alert.message = [NSString stringWithFormat:@"Pick-Axe is full max is 1."];
            [weakSelf.alert show];
        } else if ([MEMGameData sharedGameData].goldPurse < 50){
            weakSelf.alert.message = notEnoughMoney;
            [weakSelf.alert show];
        } else {
            [MEMGameData sharedGameData].goldPurse -= 50;
            [MEMGameData sharedGameData].hasPickAxe = YES;
            [weakSelf updateHud];
        }

        
    };
    
    fourthButtonBlock = ^(void){
        MEMGameOverScene *gameOverScene = [[MEMGameOverScene alloc]initWithSize:weakSelf.size];
        [weakSelf.scene.view presentScene:gameOverScene];
        [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:@"updateHud"object:nil];
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
