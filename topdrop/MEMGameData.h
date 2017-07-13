//
//  MEMGameData.h
//  TopDrop
//
//  Created by Michael McCafferty on 5/23/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEMGameData : NSObject <NSCoding>

@property (assign, nonatomic) int score;
@property (assign, nonatomic) int highScore;
// test
@property (assign, nonatomic) int adCount;
@property (assign, nonatomic) int goldPurse;
@property (assign, nonatomic) int dynamitePurse;
@property (assign, nonatomic) BOOL hasPickAxe;
@property (assign, nonatomic) BOOL newHighScore;

+(instancetype)sharedGameData;
-(void)setInitialEquipment;
-(void)resetScore;
-(void)save;
@end
