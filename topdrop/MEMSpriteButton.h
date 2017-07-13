//
//  MEMSpriteButton.h
//  TopDrop
//
//  Created by Michael McCafferty on 7/23/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
static const CGSize topButtonSize = {200, 58};
static const CGSize buttonSize = {200, 80};

@interface MEMSpriteButton : SKSpriteNode

-(id)initWithTexture:(SKTexture *)texture size:(CGSize)size position:(CGPoint)pos zPosition:(int)zPos;
-(void)runTappedActionWithBlock:(void (^)(void))completionBlock;


@end
