//
//  Scores.m
//  Cellfense
//
//  Created by Luis Floreani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scores.h"

static Scores *sharedInstance = nil;

@implementation Scores

+ (Scores *)sharedInstance {
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [[Scores alloc] init];
			
			//key: level
			//value: number of unlocked art
			sharedInstance->art = [[NSMutableDictionary dictionary] retain];
			[sharedInstance->art setObject:@"2" forKey:@"2"];
			[sharedInstance->art setObject:@"3" forKey:@"5"];
			[sharedInstance->art setObject:@"3" forKey:@"9"];
			[sharedInstance->art setObject:@"3" forKey:@"12"];
			[sharedInstance->art setObject:@"3" forKey:@"17"];
			[sharedInstance->art setObject:@"3" forKey:@"21"];
			[sharedInstance->art setObject:@"3" forKey:@"26"];
		}
	}
	
	return sharedInstance;
}

- (NSArray *)unlockedArt {	
	NSMutableArray *unlocked = [NSMutableArray array];
	int maxScoredLevel = 0;
	for (int i = 0; i < [scores count]; i++) {
		if ([[scores objectAtIndex:i] intValue] > 0) {
			maxScoredLevel = i+1;
		}
	}
	
	if (maxScoredLevel == 0)
		return unlocked;
	
	int unlockedCount = 0;
	for (NSString *level in art) {
		if ([level intValue] <= maxScoredLevel) {
			unlockedCount += [[art objectForKey:level] intValue];
		}
	}
	
	for (int i = 0; i < unlockedCount; i++) {
		[unlocked addObject:[NSString stringWithFormat:@"art%d.png", i+1]];
	}
	
	return unlocked;
}

- (void)fillScores {
	for (int i = 0; i < [scores count]; i++) {
		NSNumber *old = [[scores objectAtIndex:i] retain];
		if (1 > [old intValue]) 
			[scores replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:1]];		
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsPath stringByAppendingPathComponent:@"scores.plist"];		
	[scores writeToFile:scoresPath atomically:YES];	
}

- (void)resetScores {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsPath stringByAppendingPathComponent:@"scores.plist"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:scoresPath error:NULL];
}

- (void)setLevels:(NSArray *)someLevels {
	if (levels == someLevels)
		return;
	
	[levels release];
	
	levels = [someLevels retain];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsPath stringByAppendingPathComponent:@"scores.plist"];
	
	scores = [[NSMutableArray arrayWithContentsOfFile:scoresPath] retain];
	if (scores) {
		if ([scores count] < [levels count]) {
			NSArray *oldScores = scores;
			scores = [[NSMutableArray arrayWithCapacity:[levels count]] retain];
			for (int i = 0; i < [levels count]; i++) {
				if (i < [oldScores count]) {
					[scores addObject:[oldScores objectAtIndex:i]];					
				} else {
					[scores addObject:[NSNumber numberWithInt:0]];
				}
			}
			[oldScores release];
		}
	} else {
		scores = [[NSMutableArray array] retain];
		for (int i = 0; i < [levels count]; i++) {
			[scores addObject:[NSNumber numberWithInt:0]];
		}
	}
}

- (int)getLevelIndex:(Level *)level {
	for (int i = 0; i < [levels count]; i++) {
		if (level == [levels objectAtIndex:i])
			return i;
	}
	
	return -1;
}

- (BOOL)isLastLevel:(Level *)level {
	return [self getLevelIndex:level] == [levels count] - 1;
}

- (BOOL)setScore:(int)newScore forLevel:(Level *)level {
	if (scores) {
		int levelIndex = [self getLevelIndex:level];
		
		NSNumber *old = [[scores objectAtIndex:levelIndex] retain];
		if (newScore <= [old intValue]) 
			return NO;
		
		[scores replaceObjectAtIndex:levelIndex withObject:[NSNumber numberWithInt:newScore]];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
		NSString *documentsPath = [paths objectAtIndex:0];
		NSString *scoresPath = [documentsPath stringByAppendingPathComponent:@"scores.plist"];		
		[scores writeToFile:scoresPath atomically:YES];
		
		if ([old intValue] == 0) {
			[old release];
			for (NSString *level in art) {
				if (levelIndex + 1 == [level intValue]) {
					return YES;
				}
			}
		} else {
			[old release];
		}
		
		return NO;
		
	} else {
		NSLog(@"Cellfense: levels were not set for scores!!!");
		return NO;
	}
}

- (int)scoreAtIndex:(int)index {
	if (index >= [scores count])
		return 0;
	
	return [[scores objectAtIndex:index] intValue];
}

- (void)dealloc {
	[art release];
	[levels release];
	[scores release];
	
	[super dealloc];
}

@end
