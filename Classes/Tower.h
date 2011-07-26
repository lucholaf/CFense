//
//  Tower.h
//  Cellfense
//
//  Created by Luis Floreani on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Enemy.h"
#import "Movable.h"

#define TURRET_TOWER @"turret_button.png"
#define TANK_TOWER @"tank_button.png"
#define LASER_TOWER @"laser_button.png"
#define BOMB_TOWER @"bomb_button.png"

@interface Tower : Movable {
	float range;
	float rate;
	int cost;
	int lineWidth;
	
	int level;
	int shootTimer;
	int crazyTimer;

	NSString *shootSound;
	
	Enemy *shootingAt;
	
	CGPoint origPosition;
}

@property(readonly) int level;
@property(readonly) int cost;
@property(readonly) float range;
@property(retain) Enemy *shootingAt;
@property CGPoint origPosition;

+ (id)towerWithFile:(NSString*)filename;

/**
 * Returns YES if the enemy is being shooted by this tower
 */
- (BOOL)tryShoot:(Enemy *)enemy;

- (void)tick:(ccTime)dt;

- (void)resetTimers;

- (void)goCrazy;

- (BOOL)isCrazy;

- (void)savePosition;

@end

@interface Bomb : Tower {
	BOOL exploded;
	int explosionTimer;
}

@property(readonly) BOOL exploded;

- (void)explode;

@end