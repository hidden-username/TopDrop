//
//  MEMGameData.m
//  TopDrop
//
//  Created by Michael McCafferty on 5/23/14.
//  Copyright (c) 2014 Michael McCafferty. All rights reserved.
//

#import "MEMGameData.h"

@implementation MEMGameData
+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

-(void)resetScore
{
    self.score = 0;
    self.newHighScore = NO;
}
-(void)setInitialEquipment
{
    self.dynamitePurse = 8;
    self.hasPickAxe = YES;
    self.goldPurse = 0;
}
#pragma mark- Encoding Methods

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.highScore forKey:@"highScore"];
    
    [aCoder encodeInt:self.adCount forKey:@"adCount"];
    
    [aCoder encodeInt:self.goldPurse forKey:@"goldPurse"];
    
    [aCoder encodeInt:self.dynamitePurse forKey:@"dynamitePurse"];
    
    [aCoder encodeBool:self.hasPickAxe forKey:@"hasPickAxe"];
    
    [aCoder encodeBool:_newHighScore forKey:@"newHighScore"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        _highScore = [aDecoder decodeIntForKey:@"highScore"];
        
        _adCount = [aDecoder decodeIntForKey:@"adCount"];
        
        _goldPurse = [aDecoder decodeIntForKey:@"goldPurse"];
        
        _dynamitePurse = [aDecoder decodeIntForKey:@"dynamitePurse"];
        
        _hasPickAxe = [aDecoder decodeBoolForKey:@"hasPickAxe"];
        
        _newHighScore = [aDecoder decodeBoolForKey:@"newHighScore"];
    }
    return self;
    
}
+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}
+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [MEMGameData filePath]];
    if (decodedData) {
        MEMGameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[MEMGameData alloc] init];
}
-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[MEMGameData filePath] atomically:YES];
}
@end
