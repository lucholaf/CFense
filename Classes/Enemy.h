//
//  Enemy.h
//  Cellfense
//
//  Created by Luis Floreani on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Movable.h"

#define SPIDER_FILE @"spider.png"
#define CATERPILLAR_FILE @"caterpillar.png"
#define CHIP_FILE @"chip.png"

@interface Enemy : Movable<NSCopying> {
	float speed;
	float life;
	int startLife;
	int lifeWidth; // pre-calculated for drawing
	
	float speedFactor;
	
	int row;
	int col;
	
	int dirX;
	int dirY;
	int pathIndex;
	
	NSArray *path;
}

@property float life;
@property float speed;
@property float speedFactor;
@property int row;
@property int col;
@property int dirX;
@property int dirY;
@property int pathIndex;
@property(retain) NSArray *path;

- (void)resurrect;

/**
 * Called when the enemy is being shot
 */
- (void)shoot:(float)damage;
- (void)slow;

/**
 * Returns the life remaining
 */
- (float)life;

- (void)startAnimating;

+ (id)spriteWithFile:(NSString*)filename speed:(float)speed;

@end
