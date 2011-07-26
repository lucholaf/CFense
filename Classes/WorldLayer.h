//
//  WorldLayer.h
//  Cellfense
//
//  Created by Luis Floreani on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Tower.h"
#import "Enemy.h"
#import "Level.h"

#define WORLD_HEIGHT 960
#define WORLD_WIDTH 320

#define EMITTER_PARTICLES 350
#define EMITTER_LIFE 0.3

@class ControlLayer;

typedef struct vector {
	float x;
	float y;
	int size;
	int red;
	float vx;
	float vy;
	ccTime ttl;
} vector;

@interface WorldLayer : CCLayer {
	NSMutableArray *towers;
	NSMutableArray *enemies;
	NSMutableSet *bullets;
	NSMutableArray *addedEnemies;
	NSMutableArray *addedTowers;
	
	vector *particles;
	CGPoint *drawingParticles;
	
	ControlLayer *control;
	
	BOOL enemiesAlreadyPlanned;
	
	int startEnergy;
	int energy;
	int lives;
	
	ccTime elapsed;
	
	BOOL levelDone;
	
	NSString *enemiesLog;
	
	CGSize sampleCellSize;
}


@property(nonatomic, retain) NSMutableArray *towers;
@property(nonatomic, retain) NSMutableArray *enemies;
@property(nonatomic, retain) NSMutableSet *bullets;
@property(nonatomic, retain) NSMutableArray *addedEnemies;
@property(nonatomic, retain) NSMutableArray *addedTowers;
@property(retain) Level *levelData;

+ (id)nodeWithLevel:(Level *)level andEnergy:(int)energy;

/**
 * This will spawn enemies and a new level is started
 */
- (void)prepareLevel;

- (void)prepareLevel:(int)startEnergy;

/**
 * Called in order to advance in the world
 */
- (void)tick:(ccTime)dt;

/**
 * Add a tower to the world at tower.position
 */
- (void)addTower:(Tower *)tower;

- (void)addEnemy:(Enemy *)enemy;

/**
 * Remove it from the world
 */
- (void)removeTower:(Tower *)tower;

- (void)removeEnemy:(Enemy *)enemy;

/**
 * Returns the tower if a tower exist in that position otherwise nil
 */
- (Tower *)towerAtLocation:(CGPoint)location;

- (Enemy *)enemyAtLocation:(CGPoint)location;

/**
 * Returns a new location adapted to the grid
 */
- (CGPoint)worldToGrid:(CGPoint)location;

/**
 * Add a shoot to the world
 */
- (void)addShoot:(vector)shoot;

- (CGSize)cellSize;

/**
 * Returns YES if path is blocked at location
 */
- (BOOL)doesBlockPathIfAddedTo:(CGPoint)location;

- (BOOL)consumeEnergy:(int)someEnergy;

- (void)restart;

- (void)startDefending;

- (void)explode:(Tower *)tower;

- (void)spawnEnemy:(Enemy *)enemy;

- (void)cleanup;

- (void)stopAnimations;

@end

@interface Shoot : NSObject
{
@public
	vector c;
	//CCNode *emitter;
	Movable *emitter;
}
-(id)initWithCoord:(vector)acoord;
@end
