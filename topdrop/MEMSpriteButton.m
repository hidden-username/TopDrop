//
//  MEMSpriteButton.m
//  TopDrop
//
//  Created by Michael McCafferty on 7/23/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMSpriteButton.h"
static      SKAction *ClickSound;


@implementation MEMSpriteButton
-(id)initWithTexture:(SKTexture *)texture size:(CGSize)size position:(CGPoint)pos zPosition:(int)zPos
{
    self = [super init];
    
    if(self) {
        self.texture = texture;
        self.size = size;
        self.position = pos;
        self.zPosition = zPos;
        
        
        // NSLog(@"%@", (musicPlaying ? @"Yes" : @"No"));

        
        ClickSound = [SKAction playSoundFileNamed:@"ClickSound.wav" waitForCompletion:NO];
        
    }
    return self;
}

-(void)runTappedActionWithBlock:(void (^)(void))completionBlock
{
    
    [self runAction:ClickSound]; // Has to be kept out of sequence, because it has a chance of being nil.
    [self runAction:[SKAction
                                 sequence:@[
                                            [SKAction scaleTo:.7 duration:.1],
                                            [SKAction scaleTo:1 duration:.1],
                                            [SKAction runBlock:^{
            completionBlock();
        
    }]]]];
}
@end
