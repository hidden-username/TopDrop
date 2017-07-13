//
//  MEMMenuScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 7/23/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMMenuScene.h"
#import "MEMGameData.h"

@implementation MEMMenuScene


-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        menuNode = [SKNode node];
        menuNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + buttonSize.height);//+195/2);

        
        // background
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"BG_noSign"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:bg];
        
        // Scene Custom Code
        [self setUpSceneSpecificCode];
        
        // Textures
        [self setUpButtonTextures];
        
        // Blocks
        [self createBlocks];
        

        
        // Buttons
        [self setUpButtons];
        
        // I need to set position after Buttons.
        // Button Positions
        [self setUpButtonPositions];
        [self setUpHud];
        
    }
    return self;
}
-(void)setUpSceneSpecificCode
{
    NSLog(@"setUpSceneSpecificCode has not been overridden");
}
-(void)setUpButtonTextures
{
    NSLog(@"setUpButtonTextures has not been overridden.");
}
-(void)createBlocks
{
    NSLog(@"createBlocks has not been overridden.");

}
-(void)setUpButtonPositions
{
    firstButton.position = firstButton.position;
    secondButton.position = CGPointMake(firstButton.position.x, firstButton.position.y - firstButton.size.height/2 - 25);
    thirdButton.position = CGPointMake(secondButton.position.x, secondButton.position.y - secondButton.size.height/2 - 25);
    fourthButton.position = CGPointMake(thirdButton.position.x, thirdButton.position.y - thirdButton.size.height/2 - 25);
   
    // If I decide to add Banner Ads, we can do something like below
    
    /*
    firstButton.position = firstButton.position;
    secondButton.position = CGPointMake(firstButton.position.x, firstButton.position.y - firstButton.size.height/2-20);
    thirdButton.position = CGPointMake(secondButton.position.x, secondButton.position.y - secondButton.size.height/2-20);
    fourthButton.position = CGPointMake(thirdButton.position.x, thirdButton.position.y - thirdButton.size.height/2 - 20);
    */
}
-(void)setUpButtons
{
    NSLog(@"setUpButtons has not been overridden.");
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        self.view.userInteractionEnabled = YES;
        
        
        if ([self nodeAtPoint:location] == firstButton) {
            [firstButton runTappedActionWithBlock:firstButtonBlock];
        }
        if ([self nodeAtPoint:location] == secondButton) {
            [secondButton runTappedActionWithBlock:secondButtonBlock];
        }
        if ([self nodeAtPoint:location] == thirdButton) {
            [thirdButton runTappedActionWithBlock:thirdButtonBlock];
        }
        if ([self nodeAtPoint:location] == fourthButton) {
            [fourthButton runTappedActionWithBlock:fourthButtonBlock];
        }
    }
}
-(void)setUpHud
{
    // Score
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", [MEMGameData sharedGameData].score];
    scoreLabel.fontSize = 20;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-40);
    [self addChild:scoreLabel];
    
    //HighScore
    SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    highScoreLabel.text = [NSString stringWithFormat:@"Best: %i", [MEMGameData sharedGameData].highScore];
    highScoreLabel.fontSize = 20;
    highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-20);
    [self addChild:highScoreLabel];
    
    // Gold Purse
    SKTexture *goldTexture = [SKTexture textureWithImageNamed:@"GoldNugget"];
    SKSpriteNode* gold = [SKSpriteNode spriteNodeWithTexture:goldTexture];
    gold.size = CGSizeMake(30, 30);
    gold.name = [NSString stringWithFormat:@"gold"];
    NSString *goldPath = [[NSBundle mainBundle]pathForResource:@"Gold" ofType:@"sks"];
    SKEmitterNode *goldSparkle = [NSKeyedUnarchiver unarchiveObjectWithFile:goldPath];
    [gold addChild:goldSparkle];
    gold.zPosition = 4;
    
    // Fixed Position by adding to menu Node
    gold.position = CGPointMake(highScoreLabel.position.x + buttonSize.width/2 + gold.size.width/2, highScoreLabel.position.y);
    [self addChild:gold];
    NSLog(@"Gold Position:%f, %f", gold.position.x, gold.position.y);
    NSLog(@"Third Button Position: %f, %f", thirdButton.position.x, thirdButton.position.y);
    
    // Purse Labe
    goldPurse = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    goldPurse.text = [NSString stringWithFormat:@"%i", [MEMGameData sharedGameData].goldPurse];
    goldPurse.fontSize = 20;
    goldPurse.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    goldPurse.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    goldPurse.position = CGPointMake(gold.position.x + gold.size.width, gold.position.y);// - gold.size.height/2);
    [self addChild:goldPurse];
    
    // Dynamite HUD
    SKTexture *dHud = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%dHud", [MEMGameData sharedGameData].dynamitePurse]];
    dynamiteHud = [SKSpriteNode spriteNodeWithTexture: dHud];
    dynamiteHud.position = CGPointMake(scoreLabel.position.x - buttonSize.width/2 - dHud.size.width/2, highScoreLabel.position.y);
    [self addChild:dynamiteHud];
    
    
    // PickAxeHud gets added to self, not menu node.
    pickAxeHud = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"PickAxe"]];
    pickAxeHud.size = CGSizeMake(50, 50);
    pickAxeHud.position = CGPointMake(CGRectGetMidX(self.frame) + 200, pickAxeHud.size.height/2);
    pickAxeHud.zRotation = M_PI - .50;
    pickAxeHud.zPosition = 0;
    pickAxeHud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pickAxeHud.size];
    pickAxeHud.physicsBody.dynamic = NO;
        //pickAxeHud.zRotation = M_PI - .50;
    [self addChild:pickAxeHud];
    
    if (![MEMGameData sharedGameData].hasPickAxe){
        pickAxeHud.zPosition = -10;
    } else{
        pickAxeHud.zPosition = 3;
    }
    

}
-(void)updateHud
{
    dynamiteHud.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%dHud", [MEMGameData sharedGameData].dynamitePurse]];
  
    if (![MEMGameData sharedGameData].hasPickAxe){
        pickAxeHud.zPosition = -10;
    } else{
        pickAxeHud.zPosition = 3;
    }
    
    goldPurse.text = [NSString stringWithFormat:@"%i", [MEMGameData sharedGameData].goldPurse];
}
@end
