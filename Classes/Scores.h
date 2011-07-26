//
//  Scores.h
//  Cellfense
//
//  Created by Luis Floreani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface Scores : NSObject {
	NSArray *levels;
	
	NSMutableArray *scores;
	
	NSMutableDictionary *art;
}

+ (Scores *)sharedInstance;

- (void)setLevels:(NSArray *)levels;
- (BOOL)setScore:(int)newScore forLevel:(Level *)level;
- (BOOL)isLastLevel:(Level *)level;
- (int)scoreAtIndex:(int)index;
- (NSArray *)unlockedArt;
- (void)resetScores;
- (void)fillScores;

@end
