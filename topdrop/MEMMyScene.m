//
//  MEMMyScene.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/15/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMMyScene.h"
#import "MEMShareScene.h"
#import "MEMGameData.h"
#import "MEMViewController.h"
#import "MEMGameOverScene.h"
#import "MEMGameKitHelper.h"



typedef NS_OPTIONS(uint32_t, TDPhysicsCategory)
{
    TDPhysicsCategoryManCont    = 1 << 0,  
    TDPhysicsCategoryFloor      = 1 << 1,
    TDPhysicsCategoryBoulder    = 1 << 2,
    TDPhysicsCategoryHat        = 1 << 3,
    TDPhysicsCategoryGold       = 1 << 4,
    TDPhysicsCategoryEdge       = 1 << 5,
    TDPhysicsCategoryPickAxeHud = 1 << 6,
    TDPhysicsCategoryPickAxe    = 1 << 7,
    
};

typedef NS_ENUM(int, GameRound)
{
    GameRoundFirst      = 4,//2,5,
    GameRoundSecond     = 8,//4,10,
    GameRoundThird      = 13,//6,20,
    GameRoundFourth     = 19,//8,30,
    GameRoundFifth      = 26,//12,40,
    GameRoundSixth      = 34,//20,50,
    
};
enum GameRound CurrentGameRound;

static      SKAction *GameOverSound;
static      SKAction *GoldSound;
static      SKAction *RockSound;
static      SKAction *ManSound;
static      SKAction *HatSound;
static      SKAction *ExplosionSound;
static      SKAction *AxeSound;

static      SKAction *blink;


static      SKSpriteNode *gameOverSign;
static      SKSpriteNode *newHighScoreSign;

static      SKTextureAtlas *GameObjectAtlas;
static      SKTexture *boulderTexture;

static      SKTexture *goldTexture;
static      SKTexture *hatTexture;
static      SKTexture *pickAxeTexture;








@implementation MEMMyScene
{
    
    SKSpriteNode *pauseButton;
    SKSpriteNode *playButton;

    SKSpriteNode *dynamiteHud;
    SKSpriteNode *detonatorBox;
    SKSpriteNode *pickAxeEquipped;
    SKPhysicsJointPin *pin;
    
    SKNode* _backGroundLayer;
    SKNode* _hudLayerNode;
    SKNode* _gameLayerNode;
    
    SKSpriteNode *_man;
    int multiplierForDirection;
    
    NSArray *_manWalkingFrames;
    NSArray *_tntFrames;
    
    SKNode* _manCont;
    
    SKLabelNode *_scoreLabel;
    SKLabelNode *_highScoreLabel;
    SKSpriteNode *sign;
    
    BOOL _isHatted;
    BOOL _gameOver;
    BOOL _manDisabled;
    BOOL _shouldPause;
    BOOL _hammerTime;
    
    
    int a;
    int b;
}

static inline CGFloat skRandf(){
    return rand() / (CGFloat)RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}
float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}

#pragma mark- Set Up Scene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, -5);
        
        
        // Abstraction layer

        _gameOver = NO;
        _isHatted = NO;
        _manDisabled = NO;
        [[MEMGameData sharedGameData] resetScore];
        
        a = 2;
        b = 4;
        
      //  NSLog(@"GoldPurse: %i",[MEMGameData sharedGameData].goldPurse);
        
        
        
        
        multiplierForDirection = 1; // Placed here so the initial xScale faces man right.
        

        // Sound
        GameOverSound   = [SKAction playSoundFileNamed:@"GameOverSound.wav" waitForCompletion:NO];
        GoldSound       = [SKAction playSoundFileNamed:@"GoldSound.wav" waitForCompletion:NO];
        RockSound       = [SKAction playSoundFileNamed:@"RockSound.wav" waitForCompletion:NO];
        ManSound        = [SKAction playSoundFileNamed:@"NewSwoosh.wav" waitForCompletion:NO];
        HatSound        = [SKAction playSoundFileNamed:@"HatSound.wav" waitForCompletion:NO];
        ExplosionSound  = [SKAction playSoundFileNamed:@"ExplosionSound.wav" waitForCompletion:NO];
        AxeSound        = [SKAction playSoundFileNamed:@"AxeSound.wav" waitForCompletion:NO];
       

        
        //
        blink = [SKAction repeatAction:[SKAction sequence:@[
                                                            [SKAction fadeOutWithDuration:.15],
                                                            [SKAction fadeInWithDuration:.15]
                                                            ]] count:4];//2
        

        
        // Sign Cache
        newHighScoreSign = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"NewHighScore"]];
        gameOverSign = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"GameOver"]];
        
        // GameObjectTextures
        GameObjectAtlas = [SKTextureAtlas atlasNamed:@"GameObjects"];
        boulderTexture = [GameObjectAtlas textureNamed:@"Boulder"];

        // Gold and Hat Cache
        goldTexture = [GameObjectAtlas textureNamed:@"GoldNugget"];
        hatTexture = [GameObjectAtlas textureNamed:@"Hat"];
        pickAxeTexture = [GameObjectAtlas textureNamed:@"PickAxe"];

        
        

        
        
        [self createSceneContents];
        
        
        
        
    }
    return self;
}
-(CGPoint)center
{
    _center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return _center;
}
-(void)createSceneContents
{
    
    
    // Level Setup
    [self setUpLayers];
    [self setUpBackGround];
    [self setUpEdge];
    [self setUpMan];
    [self setUpScoreLabel];
    [self setUpPlayPauseButton];
    [self setUpDynamiteHud];
    [self setUpDetonator];
    [self setUpPickAxeHud];
    
   
    
    
    
    // Spawn Actions
    [self rightBoulderAction];
    [self hatAction];
    [self goldAction];

    

}
-(void)setUpLayers
{
    _backGroundLayer = [SKNode node];
    _backGroundLayer.zPosition = 1;
    
    
    _hudLayerNode = [SKNode node];
    _hudLayerNode.zPosition = 5;
    
    
    _gameLayerNode = [SKNode node];
    _gameLayerNode.zPosition = 10;
    
    
    
    [self addChild:_backGroundLayer];
    [self addChild:_hudLayerNode];
    [self addChild:_gameLayerNode];
}
-(void)setUpBackGround
{
    SKSpriteNode *backGround = [SKSpriteNode spriteNodeWithImageNamed:@"Artboard 1"];
    backGround.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame));
    backGround.zPosition = 1;
    [_backGroundLayer addChild:backGround];
    
}
-(void)setUpEdge
{
    SKNode *leftWallNode = [SKNode node];
    SKNode *floorNode = [SKNode node];
    SKNode *rightWallNode = [SKNode node];
    
    leftWallNode.position = CGPointZero;
    floorNode.position = CGPointZero;
    rightWallNode.position = CGPointZero;
    
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:CGPointMake(self.center.x - 174, 0)];
    [leftPath addLineToPoint:CGPointMake(self.center.x-274,self.center.y*2-20)];
    [leftPath addLineToPoint:CGPointMake(self.center.x - self.center.x -50,self.center.y * 2)];
    

    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath moveToPoint:CGPointMake(self.center.x+188, 0)];
    [rightPath addLineToPoint:CGPointMake(self.center.x+266, self.center.y*2 - 40)];
    [rightPath addLineToPoint:CGPointMake(self.center.x*2+50, self.center.y*2)];
    
    SKPhysicsBody *leftBody = [SKPhysicsBody bodyWithEdgeChainFromPath:leftPath.CGPath];
    SKPhysicsBody *floorBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(self.center.x * 2, 0)];
    SKPhysicsBody *rightBody = [SKPhysicsBody bodyWithEdgeChainFromPath:rightPath.CGPath];
    
    leftWallNode.physicsBody = leftBody;
    leftWallNode.physicsBody.categoryBitMask = TDPhysicsCategoryEdge;
    leftWallNode.physicsBody.collisionBitMask = TDPhysicsCategoryGold | TDPhysicsCategoryManCont | TDPhysicsCategoryBoulder | TDPhysicsCategoryPickAxe;
    
    floorNode.physicsBody = floorBody;
    floorNode.physicsBody.categoryBitMask = TDPhysicsCategoryFloor;
    floorNode.physicsBody.contactTestBitMask = TDPhysicsCategoryBoulder;
    
    rightWallNode.physicsBody = rightBody;
    rightWallNode.physicsBody.categoryBitMask = TDPhysicsCategoryEdge;
    rightWallNode.physicsBody.collisionBitMask = TDPhysicsCategoryGold | TDPhysicsCategoryManCont | TDPhysicsCategoryBoulder | TDPhysicsCategoryPickAxe;
    
    
    [_backGroundLayer addChild:leftWallNode];
    [_backGroundLayer addChild:floorNode];
    [_backGroundLayer addChild:rightWallNode];
    
}


-(void)setUpMan
{
    NSMutableArray *walkFrames = [NSMutableArray array];
    SKTextureAtlas *manAtlas = _isHatted?[SKTextureAtlas atlasNamed:@"rHat"]:[SKTextureAtlas atlasNamed:@"z_r"];
    NSUInteger imageCount = manAtlas.textureNames.count;
    for (int i = 1; i <= imageCount; i++) {
        NSString *textureName = _isHatted?[NSString stringWithFormat:@"R%d", i]:[NSString stringWithFormat:@"Z%d", i];
        SKTexture *temp = [manAtlas textureNamed:textureName];
        [walkFrames addObject:temp];
    }
    _manWalkingFrames = walkFrames;
    SKTexture *temp = _manWalkingFrames[0];
    _man = [SKSpriteNode spriteNodeWithTexture:temp];
    _man.physicsBody.dynamic = NO;
    _man.size = CGSizeMake(50, 100);
    _man.xScale = multiplierForDirection;
    _man.zPosition = 5;
    
    // I needed to add this container due to the negative xScale
    if (!_manCont) { // I need this conditional to prevent duplicating the manCont when _isHatted
      //  NSLog(@"Original Man, Test to see if only done once");
        
        _manCont = [SKNode node];
        _manCont.position = CGPointMake(CGRectGetMidX(self.frame), 50);
        _manCont.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 100)];
        _manCont.physicsBody.allowsRotation = NO;
        _manCont.physicsBody.dynamic = YES;
        _manCont.physicsBody.categoryBitMask = TDPhysicsCategoryManCont;
        _manCont.physicsBody.contactTestBitMask = TDPhysicsCategoryBoulder;
        _manCont.physicsBody.collisionBitMask = TDPhysicsCategoryBoulder |TDPhysicsCategoryEdge |TDPhysicsCategoryFloor;
        _manCont.physicsBody.mass = 10;
    
        [_gameLayerNode addChild:_manCont];
    }
        
    [_manCont addChild:_man];


}
    
-(void)setUpScoreLabel
{
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _scoreLabel.text = [NSString stringWithFormat:@"Score: 0" ];//, [MEMGameData sharedGameData].score];
    _scoreLabel.fontSize = 20;
    _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-40);
    [_hudLayerNode addChild:_scoreLabel];
    
    _highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _highScoreLabel.text = [NSString stringWithFormat:@"Best: %i", [MEMGameData sharedGameData].highScore];
    _highScoreLabel.fontSize = 20;
    _highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-20);
    [_hudLayerNode addChild:_highScoreLabel];
    
    
}
-(void)setUpPlayPauseButton
{
    pauseButton = [SKSpriteNode spriteNodeWithTexture:[GameObjectAtlas textureNamed:@"PauseButton"]];
    pauseButton.position = CGPointMake(CGRectGetMidX(self.frame), _scoreLabel.position.y - 20);
    pauseButton.zPosition = 1;
    [_gameLayerNode addChild:pauseButton]; // Used GameLayer, so it woudld detect touch
    
    playButton = [SKSpriteNode spriteNodeWithTexture:[GameObjectAtlas textureNamed:@"PlayButton"]];
    playButton.position = pauseButton.position;
    playButton.zPosition = -30;
    [_gameLayerNode addChild:playButton]; // Used GameLayer, so it woudld detect touch
}
-(void)setUpDynamiteHud
{
    SKTexture *dHud = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%dHud", [MEMGameData sharedGameData].dynamitePurse]];
    dynamiteHud = [SKSpriteNode spriteNodeWithTexture: dHud];
    dynamiteHud.position = pauseButton.position;
    [_hudLayerNode addChild:dynamiteHud];
}
-(void)setUpPickAxeHud
{
    if (![MEMGameData sharedGameData].hasPickAxe){
        return;
    } else{
        SKSpriteNode* pickAxeHud = [self pickAxe];
        pickAxeHud.size = CGSizeMake(50, 50);
        pickAxeHud.position = CGPointMake(CGRectGetMidX(self.frame) + 200, pickAxeHud.size.height/2);
        pickAxeHud.zRotation = M_PI - .50;
        
        pickAxeHud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(pickAxeHud.size.width/2, pickAxeHud.size.height/2)];
        pickAxeHud.physicsBody.dynamic = NO;
        //pickAxeHud.zRotation = M_PI - .50;
        pickAxeHud.physicsBody.categoryBitMask = TDPhysicsCategoryPickAxeHud;
        pickAxeHud.physicsBody.collisionBitMask = 0;
        pickAxeHud.physicsBody.contactTestBitMask = TDPhysicsCategoryManCont;
        [_gameLayerNode addChild: pickAxeHud];
    }
}
-(void)setUpDetonator
{
    NSMutableArray *tntFrames = [NSMutableArray array];
    SKTextureAtlas *tntAtlas = [SKTextureAtlas atlasNamed:@"TNT"];
    NSUInteger imageCount = tntAtlas.textureNames.count;
    for (int i = 1; i <= imageCount; i++) {
        NSString *textureName = [NSString stringWithFormat:@"TNT%d", i];
        SKTexture *temp = [tntAtlas textureNamed:textureName];
        [tntFrames addObject:temp];
    }
    _tntFrames = tntFrames;
    SKTexture *temp = _tntFrames[0];
    detonatorBox = [SKSpriteNode spriteNodeWithTexture:temp];
    detonatorBox.position = CGPointMake(CGRectGetMidX(self.frame), detonatorBox.size.height/2);
    detonatorBox.size = CGSizeMake(100, 100);
    detonatorBox.zPosition = 2;
    [_gameLayerNode addChild:detonatorBox];
    
    
}

#pragma mark- Game Loop
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // Used to show real node count
   // NSLog(@"node count: %u", (unsigned int)_backGroundLayer.children.count);

   if (_shouldPause) {
       self.scene.paused = YES;
       pauseButton.zPosition = -30;
       playButton.zPosition = 1;
    } else if (!_shouldPause)
    {
        pauseButton.zPosition = 1;
        playButton.zPosition = -30;
        self.scene.paused = NO;
        
    }
    /*if (self.scene.isPaused) {
        pauseButton.zPosition = -30;
        playButton.zPosition = 1;
    } else {
        pauseButton.zPosition = 1;
        playButton.zPosition = -30;
    }
    */
    if (_gameOver) {
        _gameOver = NO;
        _manDisabled = YES;
        
        [self presentSign];
        [MEMGameData sharedGameData].goldPurse += [MEMGameData sharedGameData].score;
        [[MEMGameData sharedGameData]save];
        [self reportScoreToGameCenter];
        [self runAction:[SKAction sequence:@[
                                             [SKAction waitForDuration:3],//5
                                             [SKAction runBlock:^{
            if (![MEMGameData sharedGameData].newHighScore) {
                
                // Every 10 lives;
                if ([MEMGameData sharedGameData].adCount > 9) {
                    [MEMGameData sharedGameData].adCount = 0;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:self];
                }

                MEMGameOverScene *gameOverScene = [[MEMGameOverScene alloc]initWithSize:self.size];
                [self.view presentScene:gameOverScene];
            } else {
                MEMShareScene *shareScene = [[MEMShareScene alloc]initWithSize:self.size];
                [self.view presentScene:shareScene];
            }
        }]]]];
    }
}

-(void)updateScore
{
    // Score
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %i", [MEMGameData sharedGameData].score];
    
   
    // High Score
    if ([MEMGameData sharedGameData].score>[MEMGameData sharedGameData].highScore) {
        [MEMGameData sharedGameData].newHighScore = YES;
    }
    [MEMGameData sharedGameData].highScore = MAX([MEMGameData sharedGameData].score,
                                                 [MEMGameData sharedGameData].highScore);
    _highScoreLabel.text = [NSString stringWithFormat:@"Best: %i", [MEMGameData sharedGameData].highScore];
    

}
-(void)updateDynamiteHud
{
    dynamiteHud.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%dHud", [MEMGameData sharedGameData].dynamitePurse]];
}
-(void)updateGameDifficulty
{
    switch ([MEMGameData sharedGameData].score) {
        case GameRoundFirst:
           // NSLog(@"FirstRound");
            [self removeActionForKey:@"makeRightBoulder"];
            a = 1;
            b = 2;
            [self resetBoulderSpawn];
            break;
            
        case GameRoundSecond:
          //  NSLog(@"SecondRound");

            [self removeActionForKey:@"makeRightBoulder"];
            a = 3;
            b = 5;
            [self resetBoulderSpawn];
            break;
            
        case GameRoundThird:
           // NSLog(@"thirdRound");

            [self removeActionForKey:@"makeLeftBoulder"];
            [self removeActionForKey:@"makeRightBoulder"];
            a = 2;
            b = 4;
            [self resetBoulderSpawn];
            break;
            
        case GameRoundFourth:
            [self removeActionForKey:@"makeLeftBoulder"];
            [self removeActionForKey:@"makeRightBoulder"];
            a = 2;
            b = 3;
            [self resetBoulderSpawn];
            break;
            
        case GameRoundFifth:
            [self removeActionForKey:@"makeLeftBoulder"];
            [self removeActionForKey:@"makeRightBoulder"];
            a = 1;
            b = 2;
            [self resetBoulderSpawn];
            break;
            
        case GameRoundSixth:
            [self removeActionForKey:@"makeLeftBoulder"];
            [self removeActionForKey:@"makeRightBoulder"];
            a = 1;
            b = 1;
            [self resetBoulderSpawn];
            break;
            
        default:
            break;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    // Prevents man from moving at gameover
    if (_manDisabled) return;
    

    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGFloat middleScreen = CGRectGetMidX(self.frame);
        
#pragma mark Dynamite
        // Dynamite
        if (location.x > self.center.x-50 && location.x < self.center.x + 50 && location.y < 100 && !self.scene.isPaused && [MEMGameData sharedGameData].dynamitePurse > 0) {
            [_gameLayerNode runAction:ExplosionSound];// Has to be kept out of sequence, because it has a chance of being nil.
           // NSLog(@"Touched Detonator");
            [_gameLayerNode enumerateChildNodesWithName:@"boulder" usingBlock:^(SKNode *node, BOOL *stop) {
                SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"explosion" ofType:@"sks"]];
                explosion.position = node.position;
                explosion.numParticlesToEmit = 500;
                [_gameLayerNode addChild:explosion];
                SKSpriteNode*gold = [self gold];
                gold.position = node.position;
                [_gameLayerNode addChild:gold];
                [node removeFromParent];
                
                [detonatorBox runAction:[SKAction animateWithTextures:_tntFrames
                                                         timePerFrame:.066
                                                               resize:NO
                                                              restore:YES]];
                
      
            }];
            [MEMGameData sharedGameData].dynamitePurse --;
            [self updateDynamiteHud];
            return;
        }
        
#pragma mark Pause
        // Play Pause Button
        
        if (self.scene.isPaused) {
            if ([self nodeAtPoint:location] != playButton) return; // prevent changing direction while paused.
            
            if ([self nodeAtPoint:location] == playButton)
            {
                _shouldPause = NO;
                return;
            }
        } else if ([self nodeAtPoint:location] == pauseButton) {

            _shouldPause = YES;
            return;
        }
        
        
        
#pragma mark Move Man
        
        [self runAction:ManSound];// Has to be kept out of sequence, because it has a chance of being nil.
        if (location.x < middleScreen) { // Move man left
            multiplierForDirection = -1;
        }else if (location.x >= middleScreen) { // Move man Right
            multiplierForDirection = 1;
        }

        // Test Here prevent man direction moving when paused
        if (!self.scene.isPaused) {
            _man.xScale = multiplierForDirection;
            pickAxeEquipped.zRotation = degToRad(45 * -multiplierForDirection);
        }
        
        

        if ([_manCont actionForKey:@"manMoving"]) {
            [_manCont removeActionForKey:@"manMoving"];
            
            //
            
            [pickAxeEquipped removeActionForKey:@"axeRotateAction"];
            [self hammerAnimationAction];
            //
            
        }

        if  (![_man actionForKey:@"walkingInPlaceMan"]) {
            [self walkingMan];
            [self hammerAnimationAction];
        }
        
        SKAction *moveAction = [SKAction moveByX:(75 * multiplierForDirection) // Still unsure about distance
                                               y:0
                                        duration:.4];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            //NSLog(@"Animation Completed");
            [self moveEnded];
            [pickAxeEquipped removeActionForKey:@"axeRotateAction"];
        }];
        
        SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction]];
        
        [_manCont runAction:moveActionWithDone withKey:@"manMoving"];

    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    uint32_t collision = (contact.bodyA.categoryBitMask |
                          contact.bodyB.categoryBitMask);

#pragma mark Man - Hat
    
    /// MAN - HAT
    if (collision == (TDPhysicsCategoryHat | TDPhysicsCategoryManCont)) {
        SKSpriteNode *hat = (contact.bodyA.categoryBitMask==TDPhysicsCategoryHat)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        
        _manCont.physicsBody.contactTestBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge;
        _manCont.physicsBody.collisionBitMask =TDPhysicsCategoryFloor | TDPhysicsCategoryEdge;
        
        [self removeActionForKey:@"makeHat"];
        _isHatted = YES;
        [_man removeFromParent]; // Need to remove man first, because i add a new man to updat man xScale
                                 // this allows man to face proper direction when _isHatted
        [self setUpMan];
        [_manCont removeActionForKey:@"manMoving"];
        [hat removeFromParent];
        
        
        
        SKAction *sequence = [SKAction sequence:@[blink, [SKAction runBlock:^{
            _manCont.physicsBody.contactTestBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge | TDPhysicsCategoryBoulder;
            _manCont.physicsBody.collisionBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge | TDPhysicsCategoryBoulder;
            _man.hidden = NO;

        }]]];

        // Used to be [_man runAction: sequence], but I belive thats what led to the invincibility glitch, because contact between man boulder calls [_man removeFromParent];, which removes action before it finishes.
        
        
        
        [self runAction:HatSound];// Has to be kept out of sequence, because it has a chance of being nil.
        [_manCont runAction: sequence];


    }
#pragma mark Man - Boulder
    
    /// MAN - BOULDER
    if (collision == (TDPhysicsCategoryManCont|TDPhysicsCategoryBoulder)) {
        SKSpriteNode *boulder = (contact.bodyA.categoryBitMask==TDPhysicsCategoryBoulder)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        // First Test to see if wielding axe because invincible and dont want to lose hat.
        if (_hammerTime) {
            [boulder removeFromParent];
            [boulder runAction:RockSound];// Has to be kept out of sequence, because it has a chance of being nil.
            return;
        } else {
            // The original test
            if (_isHatted) {
                [boulder removeFromParent];
                [boulder runAction:RockSound];// Has to be kept out of sequence, because it has a chance of being nil.
                [_manCont removeActionForKey:@"manMoving"];
                _isHatted = NO;
                [self hatAction];
                [_man removeFromParent];
                [self setUpMan];
            } else {
                _manCont.physicsBody.allowsRotation = YES;
                [_man removeAllActions];
                [_manCont removeAllActions];
                _manCont.physicsBody.categoryBitMask = 0; // prevents multiple game over signs from spawining
                _gameOver = YES;
        }
        }
    }
#pragma mark Man - Gold
    
    /// MAN - GOLD
    if (collision == (TDPhysicsCategoryManCont | TDPhysicsCategoryGold)) {
        SKSpriteNode *gold = (contact.bodyA.categoryBitMask==TDPhysicsCategoryGold)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        
        // Need to add score by 1
        [MEMGameData sharedGameData].score ++;
        [gold removeFromParent];
        [self updateGameDifficulty];
        [self updateScore];
        [self runAction:GoldSound];// Has to be kept out of sequence, because it has a chance of being nil.
        

    }
#pragma mark Man - PickAxeHud
    /// MAN - PICKAXEHUD
    if (collision == (TDPhysicsCategoryManCont | TDPhysicsCategoryPickAxeHud)) {
        SKSpriteNode *pickAxeHud= (contact.bodyA.categoryBitMask==TDPhysicsCategoryPickAxeHud)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        
        [pickAxeHud removeFromParent];
        _hammerTime = YES;
        [self hammerTime];
        
    }
#pragma mark PickAxe - Boulder
    if (collision == (TDPhysicsCategoryPickAxe | TDPhysicsCategoryBoulder)) {
        SKSpriteNode *boulder= (contact.bodyA.categoryBitMask==TDPhysicsCategoryBoulder)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        
        /// Cannot Get This Working WTF
        
/*      Needed this work around because spritekit bug.
 *
 *      Basically must remove physics body, set position, and then add physics back.
 *
 */
        
        
        SKSpriteNode*gold = [self gold];
        gold.physicsBody = nil;
        gold.position = boulder.position;
        gold.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gold.size];
        gold.physicsBody.categoryBitMask = TDPhysicsCategoryGold;
        gold.physicsBody.contactTestBitMask = TDPhysicsCategoryManCont;
        gold.physicsBody.collisionBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge;
        [_gameLayerNode addChild:gold];
        
        
        // [self removeBoulder:boulder withWaitDuration:0];
        [self runAction:AxeSound];// Has to be kept out of sequence, because it has a chance of being nil.
        [boulder removeFromParent];
    }
    
#pragma mark Floor - Boulder
    
    /// Floor - Boulder
    if (collision == (TDPhysicsCategoryBoulder | TDPhysicsCategoryFloor)) {
        SKSpriteNode *boulder = (contact.bodyA.categoryBitMask==TDPhysicsCategoryBoulder)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        

        [self removeBoulder:boulder withWaitDuration:.1];
        
        
        
    }
#pragma mark Floor - Gold
    /// Floor - Gold
    if (collision == (TDPhysicsCategoryGold | TDPhysicsCategoryFloor)) {
        SKSpriteNode *gold = (contact.bodyA.categoryBitMask==TDPhysicsCategoryGold)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
        SKAction *blink = [SKAction  sequence:@[[SKAction fadeOutWithDuration:.2],
                                                [SKAction fadeInWithDuration:.2]]];
        SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:skRand(3, 7)],
                                                  [SKAction repeatAction:blink count:3],
                                                [SKAction runBlock:^{
            [gold removeFromParent];
        }]]];
        [gold runAction:sequence];
    }
#pragma mark Floor - Hat
    
    
    /// Floor - Hat
    if (collision == (TDPhysicsCategoryHat | TDPhysicsCategoryFloor)) {
        SKSpriteNode *hat = (contact.bodyA.categoryBitMask==TDPhysicsCategoryGold)?(SKSpriteNode*)contact.bodyA.node:(SKSpriteNode*)contact.bodyB.node;
 
        SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:3],
                                                  [SKAction runBlock:^{
            [hat removeFromParent];
        }]]];
        [hat runAction:sequence];
    }
}



-(void)presentSign
{
    if ([MEMGameData sharedGameData].newHighScore) {
        sign = newHighScoreSign;
    } else {
        sign = gameOverSign;
    }
    sign.size = CGSizeMake(200, 150);
    [self runAction:GameOverSound];// Has to be kept out of sequence, because it has a chance of being nil.
    sign.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sign.size];
    sign.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)+100);
    sign.physicsBody.affectedByGravity = YES;
    sign.physicsBody.collisionBitMask = TDPhysicsCategoryFloor;
    sign.zPosition = 5;
    [_gameLayerNode addChild:sign];
}

#pragma mark- Manimation Helpers
-(void)moveEnded
{
    [_man removeAllActions];
    [pickAxeEquipped removeActionForKey:@"axeRotateAction"];
}
-(void)walkingMan
{
    if (_manDisabled) return;
   
    [_man runAction:[SKAction repeatActionForever:
                     [SKAction animateWithTextures:_manWalkingFrames
                                      timePerFrame:.066 
                                            resize:NO
                                           restore:YES]] withKey:@"walkingInPlaceMan"];
    return;

}
#pragma mark- Objects
-(SKSpriteNode *)boulder
{
    SKSpriteNode *boulder = [SKSpriteNode spriteNodeWithTexture:boulderTexture];
    boulder.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:boulder.size.width/2 ];
    boulder.physicsBody.dynamic = YES;
    boulder.physicsBody.restitution = 1;
    boulder.physicsBody.categoryBitMask = TDPhysicsCategoryBoulder;
    boulder.physicsBody.contactTestBitMask = TDPhysicsCategoryFloor;
    boulder.physicsBody.collisionBitMask = TDPhysicsCategoryEdge;
    boulder.name = [NSString stringWithFormat:@"boulder"];
    boulder.zPosition = 2;
    return boulder;

}
-(SKSpriteNode*)hat
{
    SKSpriteNode *_hat = [SKSpriteNode spriteNodeWithTexture:hatTexture];
    _hat.size = CGSizeMake(25, 15);
    _hat.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hat.size];
    _hat.physicsBody.affectedByGravity = YES;
    _hat.physicsBody.categoryBitMask = TDPhysicsCategoryHat;
    _hat.physicsBody.contactTestBitMask = TDPhysicsCategoryManCont | TDPhysicsCategoryFloor;
    _hat.physicsBody.collisionBitMask = kNilOptions;
    _hat.physicsBody.affectedByGravity = NO;
    _hat.name = [NSString stringWithFormat:@"hat"];
    _hat.zPosition = 3;
    return _hat;
    
}
-(SKSpriteNode*)gold
{
    SKSpriteNode* _gold = [SKSpriteNode spriteNodeWithTexture:goldTexture];
    _gold.size = CGSizeMake(15, 15);
    _gold.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_gold.size];
    _gold.physicsBody.categoryBitMask = TDPhysicsCategoryGold;
    _gold.physicsBody.contactTestBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryManCont;
    _gold.physicsBody.collisionBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge;
    _gold.name = [NSString stringWithFormat:@"gold"];
    NSString *goldPath = [[NSBundle mainBundle]pathForResource:@"Gold" ofType:@"sks"];
    SKEmitterNode *goldSparkle = [NSKeyedUnarchiver unarchiveObjectWithFile:goldPath];
    [_gold addChild:goldSparkle];
    _gold.zPosition = 4;
    return _gold;
    
    
}
-(SKSpriteNode*)pickAxe
{
    SKSpriteNode *pickAxe = [SKSpriteNode spriteNodeWithTexture:pickAxeTexture];
    return pickAxe;
}
#pragma mark- Spawn Objects
-(void)resetBoulderSpawn
{
    if ([MEMGameData sharedGameData].score <= GameRoundFirst) {
        [self runAction:[SKAction waitForDuration:1] completion:^{
            [self rightBoulderAction];
        }];
    } else {
    
        [self runAction:[SKAction waitForDuration:1] completion:^{
            [self rightBoulderAction];
            [self leftBoulderAction];
        }];
    }
}
-(void)spawnLeftBoulders
{

    SKSpriteNode *leftBoulder = [self boulder];
    leftBoulder.position = CGPointMake(skRand(self.center.x-self.center.x-40, self.center.x-274), skRand(self.size.height+20, self.size.height+100));
    [_gameLayerNode addChild:leftBoulder];
}
-(void)spawnRightBoulders
{

    SKSpriteNode *rightBoulder = [self boulder];
    rightBoulder.position = CGPointMake(skRand(self.center.x*2-10, self.center.x*2+50), skRand(self.size.height+20, self.size.height+100));
    [_gameLayerNode addChild:rightBoulder];
    
}
-(void)spawnHat
{
    SKSpriteNode *hat =[self hat];
    hat.position = CGPointMake(skRand(self.center.x-174, self.center.x + 188), self.size.height+20);
    [_gameLayerNode addChild:hat];
    [hat.physicsBody applyForce:CGVectorMake(0, -100)];

}

-(void)spawnGold
{

    SKSpriteNode *_gold = [self gold];
    _gold.position = CGPointMake(skRand(self.center.x-174, self.center.x + 188), self.size.height + 20);
    [_gameLayerNode addChild:_gold];
}
-(void)removeBoulder:(SKSpriteNode *)boulder withWaitDuration:(float)waitDuration
{
    SKEmitterNode *boulderDust = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"BoulderDust" ofType:@"sks"]];
    boulderDust.numParticlesToEmit = 10;
    boulderDust.position = CGPointMake(boulder.position.x, boulder.position.y-boulder.size.height);
    [_gameLayerNode addChild:boulderDust];
    [self runAction:RockSound];// Has to be kept out of sequence, because it has a chance of being nil.
    
    [boulder runAction:[SKAction sequence:@[
                                            [SKAction waitForDuration:waitDuration],
                                            [SKAction removeFromParent]]]];
}

#pragma mark- Object Actions
-(void)hatAction
{
    SKAction *makeHat = [SKAction sequence:@[[SKAction waitForDuration:skRand(10, 20)],//10,20
                                             [SKAction performSelector:@selector(spawnHat)
                                                              onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:makeHat]withKey:@"makeHat"];
}
//Right
-(void)rightBoulderAction
{
    SKAction *makeRightBoulder = [SKAction sequence:@[[SKAction performSelector:@selector(spawnRightBoulders)
                                                                       onTarget:self],
                                                      [SKAction waitForDuration:skRand(a, b) withRange:.5]]];
    [self runAction:[SKAction repeatActionForever:makeRightBoulder]withKey:@"makeRightBoulder"];
}

//Left
-(void)leftBoulderAction
{
    SKAction *makeLeftBoulder = [SKAction sequence:@[[SKAction performSelector:@selector(spawnLeftBoulders)
                                                                      onTarget:self],
                                                     [SKAction waitForDuration:skRand(a, b) withRange:.5]]];
    [self runAction:[SKAction repeatActionForever:makeLeftBoulder]withKey:@"makeLeftBoulder"];
}


-(void)goldAction
{
    // Was 3,6
    SKAction *makeGold = [SKAction sequence:@[[SKAction waitForDuration:skRand(2, 5)],
                                              [SKAction performSelector:@selector(spawnGold)
                                                               onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:makeGold]];
}
-(void)hammerTime
{
    [MEMGameData sharedGameData].hasPickAxe = NO;
    pickAxeEquipped = [self pickAxe];
    pickAxeEquipped.anchorPoint = CGPointMake(0.5, 0.2);
    pickAxeEquipped.zRotation = degToRad(-multiplierForDirection * 55);
    pickAxeEquipped.position = CGPointMake(0, -10);
    
    
    pickAxeEquipped.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(pickAxeEquipped.size.width/1.5,
                                                                                     pickAxeEquipped.size.height)
                                                                  center:CGPointMake(0, 30)];
    
    
    pickAxeEquipped.physicsBody.categoryBitMask = TDPhysicsCategoryPickAxe;
    pickAxeEquipped.physicsBody.collisionBitMask = TDPhysicsCategoryEdge;
    pickAxeEquipped.physicsBody.contactTestBitMask = TDPhysicsCategoryGold | TDPhysicsCategoryBoulder | TDPhysicsCategoryHat;
    pickAxeEquipped.physicsBody.allowsRotation = NO;
    pickAxeEquipped.physicsBody.affectedByGravity = NO;

    [_manCont addChild:pickAxeEquipped];
    
    _manCont.physicsBody.contactTestBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge;
    _manCont.physicsBody.collisionBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge;
    
    CGPoint anchor = CGPointMake(_manCont.position.x, _manCont.position.y - 10);
    pin = [SKPhysicsJointPin jointWithBodyA:_manCont.physicsBody
                                                         bodyB:pickAxeEquipped.physicsBody
                                                        anchor:anchor];

    
    [self.physicsWorld addJoint: pin];
    


    
    SKAction *sequence = [SKAction sequence:@[blink, [SKAction waitForDuration:15], blink, [SKAction runBlock:^{
        
        [pickAxeEquipped removeFromParent];
        
    }], blink, blink, [SKAction runBlock:^{
        _manCont.physicsBody.contactTestBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge | TDPhysicsCategoryBoulder;
        _manCont.physicsBody.collisionBitMask = TDPhysicsCategoryFloor | TDPhysicsCategoryEdge | TDPhysicsCategoryBoulder;
        _man.hidden = NO;
        _hammerTime = NO;
    }]]];
    
    // Used to be [_man runAction: sequence], but I belive thats what led to the invincibility glitch, because contact between man boulder calls [_man removeFromParent];, which removes action before it finishes.
    [self runAction:HatSound];  // Has to be kept out of sequence, because it has a chance of being nil.
    [_manCont runAction: sequence];

}
-(void)hammerAnimationAction
{
    // Axe Animation
    SKAction *rotToTen = [SKAction rotateToAngle:degToRad(-multiplierForDirection*10) duration:.12 shortestUnitArc:YES];
    SKAction *rotToFiftyFive = [SKAction rotateToAngle:degToRad(-multiplierForDirection*55) duration:.12 shortestUnitArc:YES];
    [pickAxeEquipped runAction:[SKAction sequence:@[rotToTen, rotToFiftyFive]]withKey:@"axeRotateAction"];
}
#pragma mark- Report Score
-(void)reportScoreToGameCenter
{
    int64_t maxScore = [MEMGameData sharedGameData].highScore;
    [[MEMGameKitHelper sharedGameKitHelper]reportScore:maxScore forLeaderboardID:@"com.topdropgames.topdrop.leaderboard"];
}
@end
