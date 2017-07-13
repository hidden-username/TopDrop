//
//  MEMTutorialScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 7/22/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMTutorialScene.h"
#import "MEMGameOverScene.h"
#import "MEMMyScene.h"
#import "MEMStoreScene.h"

#import "MEMGameData.h"
typedef NS_ENUM(int, TutorialScene)
{
    TutorialSceneWelcome,
    TutorialSceneMovement,
    TutorialSceneGold,
    TutorialSceneHat,
    TutorialScenePickAxe,
    TutorialSceneTNT,
    TutorialSceneBoulder,
    TutorialSceneFareWell,
};

enum TutorialScene  CurrentTurorialScene;

@implementation MEMTutorialScene
{
    SKTextureAtlas *tutorialAtlas;
    //Buttons
    SKSpriteNode *nextButton;
    SKSpriteNode *backButton;
    
    SKSpriteNode *man;
    SKSpriteNode *lF;
    SKSpriteNode *rF;
    SKSpriteNode *gold;
    SKSpriteNode *hat;
    SKSpriteNode *boulder;
    SKSpriteNode *detonatorBox;
    SKSpriteNode *pickAxe;
    
    SKSpriteNode *circle;
    SKSpriteNode *circleText;
    
}
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        CurrentTurorialScene = TutorialSceneWelcome;
        
        [self createSceneContents];
    }
    return self;
}
-(void)createSceneContents
{
    
    tutorialAtlas = [SKTextureAtlas atlasNamed:@"tutorial"];
    // background
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"BG_noSign"];
    bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    bg.zPosition = 1;
    [self addChild:bg];
    
   /* man = [SKSpriteNode spriteNodeWithImageNamed:@"Z1"];
    man.position = CGPointMake(400, 50);
    man.size = CGSizeMake(50, 100);
    man.zPosition = 0;
    [self addChild:man];
    */
    hat = [SKSpriteNode spriteNodeWithImageNamed:@"Hat"];
    hat.position = CGPointMake(CGRectGetMidX(self.frame)-75, 200);
    hat.zPosition = 0;
    hat.name = @"Hat";
    [self addChild:hat];
    
    
    gold = [SKSpriteNode spriteNodeWithImageNamed:@"GoldNugget"];
    gold.position = CGPointMake(CGRectGetMidX(self.frame)- 50, gold.size.height/2);
    gold.zPosition = 0;
    gold.name = @"Gold";
    [self addChild:gold];
    
    boulder = [SKSpriteNode spriteNodeWithImageNamed:@"Boulder"];
    boulder.position = CGPointMake(150, 150);
    boulder.zPosition = 0;
    boulder.name = @"Boulder";
    [self addChild:boulder];
    
    detonatorBox = [SKSpriteNode spriteNodeWithImageNamed:@"TNT1"];
    detonatorBox.position = CGPointMake(CGRectGetMidX(self.frame), detonatorBox.size.height/2);
    detonatorBox.size = CGSizeMake(100, 100);
    detonatorBox.zPosition = 0;
    detonatorBox.name = @"DetonatorBox";
    [self addChild:detonatorBox];
    
    
    pickAxe = [SKSpriteNode spriteNodeWithImageNamed:@"PickAxe"];
    pickAxe.size = CGSizeMake(50, 50);
    pickAxe.position = CGPointMake(CGRectGetMidX(self.frame) + 200, pickAxe.size.height/2);
    pickAxe.zRotation = M_PI - .50;
    pickAxe.zPosition = 0;
    pickAxe.name = @"PickAxe";
    [self addChild:pickAxe];

    nextButton = [SKSpriteNode spriteNodeWithTexture:[tutorialAtlas textureNamed:@"NextButton"]];
    nextButton.size = CGSizeMake(nextButton.size.width/2, nextButton.size.height/2);
    nextButton.position = CGPointMake(CGRectGetMidX(self.frame) + nextButton.size.width/2 + 2,
                                      CGRectGetMidY(self.frame) - 50);
    nextButton.zPosition = 3;
    [self addChild:nextButton];
    
    
    backButton = [SKSpriteNode spriteNodeWithTexture:[tutorialAtlas textureNamed:@"BackButton"]];
    backButton.size = CGSizeMake(backButton.size.width/2, backButton.size.height/2);

    backButton.position = CGPointMake(CGRectGetMidX(self.frame) - backButton.size.width/2 - 2,
                                      CGRectGetMidY(self.frame) - 50);
    backButton.zPosition = 3;
    [self addChild:backButton];
    
    //Left Finger
    lF = [SKSpriteNode spriteNodeWithTexture:[tutorialAtlas textureNamed:@"LeftFinger"]];
    lF.position = CGPointMake(lF.size.width/2 - 3, lF.size.height/2 - 5);
    lF.zPosition = 0;
    [self addChild:lF];
    
    //Right Finger
    rF = [SKSpriteNode spriteNodeWithTexture:[tutorialAtlas textureNamed:@"RightFinger"]];
    rF.position = CGPointMake(self.size.width + 3 - rF.size.width/2, rF.size.height/2 - 5);
    rF.zPosition = 0;
    [self addChild:rF];
    
    circle = [SKSpriteNode spriteNodeWithTexture:[tutorialAtlas textureNamed:@"GreenOval"]];
    circle.size =CGSizeMake(circle.size.width/2, circle.size.height/2);
    circle.position = gold.position;
    circle.zPosition = 0;
    [self addChild:circle];
    
    circleText = [SKSpriteNode spriteNodeWithTexture:[tutorialAtlas textureNamed:@"WelcomeText"]];
    circleText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100);
    circleText.size = circleText.texture.size;
    circleText.zPosition = 3;
    [self addChild:circleText];
    

    
}

-(void)updateTutorialScene
{
    switch (CurrentTurorialScene) {
        case TutorialSceneWelcome:
            lF.zPosition = 0;
            rF.zPosition = 0;
            [self showWelcome];
        
        case TutorialSceneMovement:
            lF.zPosition = 3;
            rF.zPosition = 3;
            [self showMovement];
            break;
            
        case TutorialSceneGold:
            lF.zPosition = 0;
            rF.zPosition = 0;
            [self showObject:gold];
            break;
            
        case TutorialSceneHat:
            [self showObject:hat];
            break;
            
        case TutorialScenePickAxe:
            [self showObject:pickAxe];
            break;
            
        case TutorialSceneTNT:
            [self showObject:detonatorBox];
            break;
            
        case TutorialSceneBoulder:
            [self showObject:boulder];
            break;
            
        case TutorialSceneFareWell:
            boulder.zPosition = 0;
            circle.zPosition = 0;
            [self showFareWell];
            
        default:
            break;
    }
}
-(void)showWelcome
{
    circleText.texture = [tutorialAtlas textureNamed:@"WelcomeText"];
    circleText.size = circleText.texture.size;
    circleText.zPosition = 3;
}
-(void)showMovement
{
    //man.zPosition = 3;
    lF.zPosition = 3;
    rF.zPosition = 3;
    
    circle.zPosition = 0;
    
    circleText.texture = [tutorialAtlas textureNamed:@"TapToMoveText"];
    circleText.size = circleText.texture.size;
    circleText.zPosition = 3;
    
}
-(void)showObject:(SKSpriteNode*)object
{
    [self zeroOutzPositionsExcept:object];
    
    // Boulder Uses different oval image
    circle.texture = ( object == boulder ) ? [tutorialAtlas textureNamed:@"RedOval"] : [tutorialAtlas textureNamed:@"GreenOval"];
    
    // detonator box looks better with circle off-center
    circle.position = ( object == detonatorBox ) ? CGPointMake(object.position.x, 10) : object.position;
    circle.zPosition = 3;
    
    circleText.texture = [tutorialAtlas textureNamed:[NSString stringWithFormat:@"%@Text",object.name]];
    circleText.size = circleText.texture.size;
    circleText.zPosition = 3;
    
}
-(void)showFareWell
{
    // Used only here
    //NSLog(@"Gold Purse: %d",[MEMGameData sharedGameData].goldPurse);
    if ([MEMGameData sharedGameData].highScore == 0 && [MEMGameData sharedGameData].goldPurse == 0) {
        circleText.texture = [tutorialAtlas textureNamed:@"FareWellGiveText"];
    } else {
        circleText.texture = [tutorialAtlas textureNamed:@"FareWellText"];
    }
    
    
    circleText.size = circleText.texture.size;
    circleText.zPosition = 3;

}

-(void)zeroOutzPositionsExcept:(SKSpriteNode*)currentlyShown
{
    man.zPosition = 0;
    gold.zPosition = 0;
    hat.zPosition = 0;
    pickAxe.zPosition = 0;
    detonatorBox.zPosition = 0;
    boulder.zPosition = 0;
    currentlyShown.zPosition = 3;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        self.view.userInteractionEnabled = YES;
        if ([self nodeAtPoint:location] == nextButton) {
            [nextButton runAction:[SKAction
                                       sequence:@[[SKAction scaleTo:.7 duration:.1],
                                                  [SKAction scaleTo:1 duration:.1],
                                                  [SKAction runBlock:^{
                if (CurrentTurorialScene == TutorialSceneFareWell) {
                
                    MEMMyScene *newGame = [[MEMMyScene alloc]initWithSize:self.size];
                    [self.view presentScene:newGame];
                    
                } else {
                    CurrentTurorialScene ++;
                    [self updateTutorialScene];
                }
                
            }]]]];
        }
        if ([self nodeAtPoint:location] == backButton) {
            
            [backButton runAction:[SKAction
                                    sequence:@[[SKAction scaleTo:.7 duration:.1],
                                               [SKAction scaleTo:1 duration:.1],
                                               [SKAction runBlock:^{
                if (CurrentTurorialScene > TutorialSceneWelcome) {
                    CurrentTurorialScene --;
                    [self updateTutorialScene];
                } else {
                    MEMGameOverScene *moreMenu = [[MEMGameOverScene alloc]initWithSize:self.size];
                    [self.view presentScene:moreMenu];
                }
                

            }]]]];
            
        }
    }
}
@end
