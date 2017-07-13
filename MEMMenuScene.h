//
//  MEMMenuScene.h
//  TopDrop
//
//  Created by Michael McCafferty on 7/23/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import "MEMSpriteButton.h"
@interface MEMMenuScene : SKScene
{
    SKNode *menuNode;
    SKSpriteNode *dynamiteHud;
    SKSpriteNode *pickAxeHud;
    SKLabelNode *goldPurse;
    
    MEMSpriteButton *firstButton;
    MEMSpriteButton *secondButton;
    MEMSpriteButton *thirdButton;
    MEMSpriteButton *fourthButton;
    
    SKTexture *firstButtonTexture;
    SKTexture *secondButtonTexture;
    SKTexture *thirdButtonTexture;
    SKTexture *fourthButtonTexture;
    
    void(^firstButtonBlock)(void);
    void(^secondButtonBlock)(void);
    void(^thirdButtonBlock)(void);
    void(^fourthButtonBlock)(void);
}



-(void)setUpSceneSpecificCode;
-(void)setUpButtonTextures;
-(void)createBlocks;
-(void)setUpButtonPositions;
-(void)setUpButtons;

// Should Only over-write this in MainMenu, because we don't want HUD there.
-(void)setUpHud;
-(void)updateHud;






@end
