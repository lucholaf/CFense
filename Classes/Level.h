//
//  UIImage+filename.h
//  FanCard
//
//  Created by Luis Floreani on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enemy.h"

@interface Level : NSObject<NSCopying> {
	UIImage *image;
	
	NSMutableArray *enemies;
	
	int resource;
	
	int number;
	
	NSString *name;
	NSString *towersString;
}

@property int resource;
@property int number;
@property(retain) UIImage *image;
@property(readonly) NSMutableArray *enemies;
@property(retain) NSString *name;
@property(retain) NSString *towersString;

+ (Level *)levelFromFilename:(NSString *)name;

- (void)addEnemy:(Enemy *)enemy;

@end
