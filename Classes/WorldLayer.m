//
//  WorldLayer.m
//  Cellfense
//
//  Created by Luis Floreani on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorldLayer.h"
#import "ControlLayer.h"
#import "PathFinder.h"
#import "Constants.h"
#import "AudioEngine.h"

#define PARTICLE_GROUPS 7
#define PARTICLES_PER_GROUP 25

#define CELL_SIZE_WALK_TIME 0.5
#define BIG_NUMBER 1000000

#define LEVEL_PRESENTATION_HEIGHT 50

@interface CCActionInterval(Variable)
@end

@implementation CCActionInterval(Variable)

-(void) step: (ccTime) dt
{
	if( firstTick_ ) {
		firstTick_ = NO;
		elapsed_ = 0;
	} else {
		if ([target_ isKindOfClass:[Enemy class]]) {
			elapsed_ += dt * ((Enemy *)target_).speedFactor;
		} else {
			elapsed_ += dt;			
		}
	}
	
	[self update: MIN(1, elapsed_/duration_)];	
}

@end


@implementation WorldLayer

@synthesize towers;
@synthesize enemies;
@synthesize bullets;
@synthesize levelData;
@synthesize addedEnemies;
@synthesize addedTowers;

+ (id)nodeWithLevel:(Level *)level andEnergy:(int)someEnergy {
	WorldLayer *world = [WorldLayer node];
	
	world.levelData = level;
	
	world->startEnergy = someEnergy;
	
	for (Enemy *enemy in level.enemies) {
		[world spawnEnemy:enemy];
	}
	
	[world prepareLevel];
	
	return world;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		self.isTouchEnabled = NO;
		
		self.towers = [NSMutableArray array];
		self.enemies = [NSMutableArray array];
		self.bullets = [NSMutableSet set];
		self.addedEnemies = [NSMutableArray array];
		self.addedTowers = [NSMutableArray array];
		
		particles = malloc(PARTICLE_GROUPS * PARTICLES_PER_GROUP * sizeof(vector));
		memset(particles, 0, PARTICLE_GROUPS * PARTICLES_PER_GROUP * sizeof(vector));
		
		drawingParticles = malloc(PARTICLES_PER_GROUP * sizeof(CGPoint));
		
		lives = 1;
	}
	return self;
}

- (void)setParent:(CCNode *)parent {
	control = (ControlLayer *)parent;
	
	[control updateLives:lives];
	[control updateEnergy:energy];
}

- (void)addShoot:(vector)shoot {
	[AudioEngine playSound:@"fireball.wav"];	
	
	Shoot *aShoot = [[Shoot alloc] initWithCoord:shoot];
	[bullets addObject:aShoot];
	[self addChild:aShoot->emitter z:1];
	[aShoot release];
}

- (CGSize)cellSize {
	if (sampleCellSize.width == 0)
		sampleCellSize = [[CCSprite spriteWithFile:SPIDER_FILE] contentSize];
	
	int size = MIN(sampleCellSize.width, sampleCellSize.height);
	
	return CGSizeMake(size, size);
}

- (CGPoint)worldToGrid:(CGPoint)location {
	CGSize cellSize = [self cellSize];
	
	float tiledX = ((int)(location.x / cellSize.width) * cellSize.width);
	float tiledY = ((int)(location.y / cellSize.height) * cellSize.height);
    return ccp(tiledX + cellSize.width/2, tiledY + cellSize.height * 1.5);
}

- (CGPoint)gridToWorld:(CGPoint)location {
	CGSize cellSize = [self cellSize];

    return ccp(cellSize.width/2 + location.x * cellSize.width, location.y * cellSize.height + cellSize.height/2);
}

// index 0 is the row above the first line of towers
- (CGPoint)worldToGridIndexes:(CGPoint)location {
	CGSize cellSize = [self cellSize];

	float tiledX = ((int)(location.x / cellSize.width) * cellSize.width);
	float tiledY = ((int)(location.y / cellSize.height) * cellSize.height);
    CGPoint toGrid = ccp(tiledX + cellSize.width/2, tiledY - cellSize.height/2);
	
	return ccp(toGrid.x/cellSize.width, -(toGrid.y/cellSize.height - 1));
}

- (CGPoint)indexesToWorld:(CGPoint)indexes {
	CGSize cellSize = [self cellSize];

	return ccp(indexes.x * cellSize.width + cellSize.width/2, -(indexes.y * cellSize.height - cellSize.height/2));
}

- (void)stopAnimations {
	memset(particles, 0, PARTICLE_GROUPS * PARTICLES_PER_GROUP * sizeof(vector));

	for (Enemy *enemy in enemies) {
		[enemy stopAllActions];
	}
}

- (void)draw {
	vector *particle = particles;
	for (int i = 0; i < PARTICLE_GROUPS; i++) {
		if (particle->ttl <= 0) {
			particle += PARTICLES_PER_GROUP;
			continue;
		}
		
		for (int j = 0; j < PARTICLES_PER_GROUP; j++) {
			glColor4f(particle->red/255.0, 0.0f, 0.f, 1.0f);
			glPointSize(particle->size);
			ccDrawPoint(ccp(particle->x, particle->y));				
			
			*(drawingParticles + j) = ccp(particle->x, particle->y);
			particle++;
		}
	}
	
//	int pointSize = 4.0;
//	int maxPoints = 7;
//	
//	glPointSize(pointSize);
//	glColor4f(0.4f, 0.4f, 1.0f, 1.0f);
//	if (energy >= POWERUP_COST) {
//		for (Tower *tower in towers) {
//			if (![tower isKindOfClass:[Bomb class]]) {
//				for (int i = 0; i < MIN(energy/POWERUP_COST, maxPoints); i++) {
//					ccDrawPoint(ccp(tower.position.x + tower.contentSize.width/2, tower.position.y - tower.contentSize.height/2 + i + pointSize*i + pointSize));
//				}
//			}				
//		}
//	}		
//
//	if (energy >= LTA_COST) {
//		int ltas = MIN(energy/LTA_COST, maxPoints);
//		for (int i = 0; i < ltas; i++) {
//			ccDrawPoint(ccp(self.contentSize.width/2 - (ltas/2.0)*pointSize - pointSize/2 + pointSize*i + i, -self.contentSize.height + pointSize));
//		}		
//	}
}

- (void)spawnParticleGroupAtX:(int)x Y:(int)y dX:(float)dX dY:(float)dY {
	vector *particle = particles;
	for (int i = 0; i < PARTICLE_GROUPS; i++) {
		if (particle->ttl > 0) {
			particle += PARTICLES_PER_GROUP;
			continue;
		}

		particle->ttl = 2.0;

		for (int j = 0; j < PARTICLES_PER_GROUP; j++) {
			particle->x = x;
			particle->y = y;
			particle->vx = -100 + rand() % 200 + dX*30;
			particle->vy = -100 + rand() % 200 + dY*30;
			particle->size = (rand() % 5) + 1;
			particle->red = rand() % 255;
			particle++;
		}
		
		break;
	}	
}

- (void)processParticles:(ccTime)dt {
	vector *particle = particles;
	for (int i = 0; i < PARTICLE_GROUPS; i++) {
		if (particle->ttl <= 0) {
			particle += PARTICLES_PER_GROUP;
			continue;
		} else {
			particle->ttl -= dt;
		}

		for (int j = 0; j < PARTICLES_PER_GROUP; j++) {
			particle->x += particle->vx * dt;
			particle->y += particle->vy * dt;
			particle++;
		}
	}	
}

- (BOOL)touchingOtherEnemy:(Enemy *)theEnemy {
	for (Enemy *enemy in enemies) {
		if (CGRectIntersectsRect([enemy boundingBox], [theEnemy boundingBox])) {
			NSLog(@"Finding a place for enemy failed!");
			return YES;			
		}
	}
	
	return NO;
}

- (int)rows {
	return self.contentSize.height/[self cellSize].width;
}

- (int)cols {
	return self.contentSize.width/[self cellSize].width;
}

- (void)spawnEnemy:(Enemy *)enemy {
	enemy.position = [self gridToWorld:ccp(enemy.col - 1, [self rows] - enemy.row)];
	
	[enemy resurrect];
	
	[addedEnemies addObject:enemy];
}

- (void)prepareLevel:(int)someEnergy {
	startEnergy = someEnergy;
	[self prepareLevel];
}

- (void)prepareLevel {
	energy = startEnergy;
	
	for (Tower *tower in towers) {
		[self consumeEnergy:tower.cost];
		[tower resetTimers];
		if ([tower isKindOfClass:[Bomb class]]) {
			[tower stopAllActions];
		}
	}
	
	for (Tower *tower in addedTowers) {
		if (![towers containsObject:tower]) {
			[towers addObject:tower];
			[self addChild:tower];		
			[self consumeEnergy:tower.cost];
			[tower resetTimers];
			[tower savePosition];
		}
		tower.rotation = 0;
	}
	
	for (Enemy *enemy in addedEnemies) {
		[enemies addObject:enemy];
		[self addChild:enemy];
	}		
	
	[control updateEnergy:energy];
}

- (void)removeObjectsFromSet:(NSMutableSet *)set objects:(NSArray *)objects {
	for (id obj in objects) {
		[set removeObject:obj];
	}
}

//- (void)spawnExplotionAtX:(int)x Y:(int)y {
//	CCParticleSun* explosion = [[[CCParticleSun alloc] initWithTotalParticles:250] autorelease];
//	explosion.autoRemoveOnFinish = YES;
//	explosion.startSize = 1.0f;
//	explosion.speed = 300.0f;
//	explosion.anchorPoint = ccp(0.5f,0.5f);
//	explosion.position = ccp(x, y);
//	explosion.duration = 0.15f;
//	[self addChild:explosion z:self.zOrder+1];	
//}

- (void)enemyKilled:(Enemy *)enemy {
	enemy.rotation = 0;

	[self spawnParticleGroupAtX:enemy.position.x Y:enemy.position.y dX:0 dY:0];

	[self removeEnemy:enemy];
}

- (void)checkBoundaries {
    NSMutableArray *toDiscard = [NSMutableArray array];
	
	for (Enemy *enemy in enemies) {
		if (enemy.position.y < -WORLD_HEIGHT/2) {
			if (enemiesLog) {
				NSString *toRelease = enemiesLog;
				enemiesLog = [[NSString stringWithFormat:@"%@ - %f", toRelease, [enemy life]] retain];				
				[toRelease release];
			} else {
				enemiesLog = [[NSString stringWithFormat:@"%f", [enemy life]] retain];				
			}
			
			[toDiscard addObject:enemy];
			lives--;
		}
	}

	for (Enemy *enemy in toDiscard) {
		[self removeEnemy:enemy];
	}

	if (lives == 0) {
		for (Enemy *enemy in enemies) {
			if (enemiesLog) {
				NSString *toRelease = enemiesLog;
				enemiesLog = [[NSString stringWithFormat:@"%@ | %f", toRelease, [enemy life]] retain];				
				[toRelease release];
			} else {
				enemiesLog = [[NSString stringWithFormat:@"%f", [enemy life]] retain];				
			}
		}
		
		NSLog(@"ENEMY LOG: %@", enemiesLog);
		[enemiesLog release];
		enemiesLog = nil;		
	}
	
	[control updateLives:MAX(0, lives)];
	
	[toDiscard removeAllObjects];
	
	for (Shoot *shoot in bullets) {
		if (shoot->c.y < -WORLD_HEIGHT/2 || shoot->c.y > 0 || shoot->c.x < 0 || shoot->c.x > WORLD_WIDTH) {			
			[toDiscard addObject:shoot];
			[self removeChild: shoot->emitter cleanup:YES];
		}
	}
	
	[self removeObjectsFromSet:bullets objects:toDiscard];	
	
	[toDiscard removeAllObjects];
}

- (void)processShoots:(ccTime)dt {
	for (Enemy *enemy in self.enemies) {
		if ([enemy life] == 0 || enemy.position.y > 0) {
			continue;
		}
		
		CGRect enemyRect;
		CGSize enemySize;
		enemySize.width = [enemy contentSize].width;
		enemySize.height = [enemy contentSize].height;
		enemyRect.size = enemySize;
		enemyRect.origin = ccp(enemy.position.x - enemySize.width/2, enemy.position.y - enemySize.width/2);
		
		NSMutableArray *bulletsToDiscard = [NSMutableArray array];
		for (Shoot *shoot in bullets) {
			CGRect emitterArea;
			CGSize emitterSize;
			emitterSize.width = [self cellSize].width;
			emitterSize.height = [self cellSize].height;
			emitterArea.size = emitterSize;
			emitterArea.origin = ccp(shoot->emitter.position.x - emitterSize.width/2, shoot->emitter.position.y - emitterSize.height/2);
			
			if (CGRectIntersectsRect(emitterArea, enemyRect)) {
				[bulletsToDiscard addObject:shoot];
				[self removeChild:shoot->emitter cleanup:YES];
				
				[enemy slow];
			}
		}		
		[self removeObjectsFromSet:bullets objects:bulletsToDiscard];
	}
	
	for (Shoot *shoot in bullets) {
		shoot->c.x += shoot->c.vx * dt;
		shoot->c.y += shoot->c.vy * dt;
		shoot->emitter.position = ccp(shoot->c.x, shoot->c.y);
		shoot->emitter.rotation = (shoot->c.vx / shoot->c.vy) * 45;
		shoot->emitter.rotation = MIN(90, shoot->emitter.rotation);
		shoot->emitter.rotation = MAX(-90, shoot->emitter.rotation);
		//if (shoot->c.vy < 0)
		//	shoot->emitter.rotation += 180;
	}
}

- (float)distance:(Tower *)tower enemy:(Enemy *)enemy {
	float dx = ABS(enemy.position.x - tower.origPosition.x);
	float dy = ABS(enemy.position.y - tower.origPosition.y);
	
	if (dy < [self cellSize].height * 3 && enemy.position.y < 0) {
		[control enemyApproaching:tower.position];
	}
	
	float ndy, ndx;
	if (dx < dy) {
		float prop = dx/dy;		
		ndy = [self cellSize].height/2;
		ndx = ndy * prop;
	} else {
		float prop = dy/dx;		
		ndx = [self cellSize].width/2;
		ndy = ndx * prop;
	}

	return sqrt(dx*dx + dy*dy) - sqrt(ndx*ndx + ndy*ndy);
}

- (BOOL)isInRange:(Tower *)tower enemy:(Enemy *)enemy {
	float dist = [self distance:tower enemy:enemy];
	float range = tower.range * [self cellSize].width;
	return dist <= range || fabs(dist - range) < 0.001;
}

- (void)explode:(Tower *)tower {
	if (![tower isKindOfClass:[Bomb class]])
		return;
		
	Bomb *bomb = (Bomb *)tower;
	
	if (bomb.exploded)
		return;
				  
	CGSize towerSize;
	towerSize.width = [bomb contentSize].width;
	towerSize.height = [bomb contentSize].height;
	CGRect towerRect;
	towerRect.origin = ccp(bomb.position.x - towerSize.width/2, bomb.position.y - towerSize.height/2);
	towerRect.size = towerSize;	

	NSMutableArray *toRemove = [NSMutableArray array];
	for (Enemy *enemy in enemies) {
		if ([self isInRange:bomb enemy:enemy]) {
			[toRemove addObject:enemy];
		}
	}
	
	[bomb explode];

	for (Enemy *enemy in toRemove) {
		[enemy shoot:1000];
		[self enemyKilled:enemy];
	}
	
	//[towers removeObject:tower];
	//[self removeChild:tower cleanup:NO];
}

- (void)processTowers:(ccTime)dt {
	NSMutableArray *toRemove = [NSMutableArray array];
	for (Tower *tower in towers) {
		CGSize towerSize;
		towerSize.width = [tower contentSize].width;
		towerSize.height = [tower contentSize].height;
		CGRect towerRect;
		towerRect.origin = ccp(tower.position.x - towerSize.width/2, tower.position.y - towerSize.height/2);
		towerRect.size = towerSize;	
		
		if (![tower.filename isEqualToString:BOMB_TOWER]) {
			if (tower.shootingAt == nil || [tower.shootingAt life] == 0 || ![self isInRange:tower enemy:tower.shootingAt]) {
				tower.shootingAt = nil;
				Enemy *nearest = nil;
				float nearestDist = BIG_NUMBER;
				for (Enemy *enemy in enemies) {				
					if ([self isInRange:tower enemy:enemy]) {
						if (nearest == nil) {
							nearest = enemy;
							nearestDist = [self distance:tower enemy:enemy];
						} else {
							float dist = [self distance:tower enemy:enemy];
							if (dist <= nearestDist) {
								nearest = enemy;
								nearestDist = dist;							
							}
						}
					}
				}
				
				tower.shootingAt = nearest;
			}
			
			if (tower.shootingAt) {
				float dx = tower.shootingAt.position.x - tower.position.x;
				float dy = tower.shootingAt.position.y - tower.position.y;
				float angle = atan(dy / (float)dx) * (180/3.1416);
				if (tower.shootingAt.position.x - tower.position.x  < 0)
					angle += 180;
				tower.rotation = 90 - angle;
				
				if ([tower tryShoot:tower.shootingAt]) {
					float v = sqrt([self distance:tower enemy:tower.shootingAt]);
					
					NSLog(@"energy:%f X:%f Y:%f ndist:%f accumDt:%f", [tower.shootingAt life], tower.shootingAt.position.x, tower.shootingAt.position.y, [self distance:tower enemy:tower.shootingAt] / (tower.range * [self cellSize].width), elapsed);
					
					if ([tower.shootingAt life] > 0) {
						[self spawnParticleGroupAtX:tower.shootingAt.position.x Y:tower.shootingAt.position.y dX:dx/v dY:dy/v];
					} else {
						[self enemyKilled:tower.shootingAt];
						
						tower.shootingAt = nil;
					}
				}
			}
		}
		[tower tick:dt];
	}
	
	for (Tower *tower in toRemove) {
		[self removeTower:tower];
	}
}

- (NSArray *)getShortestExitFrom:(CGPoint)index row:(int)row cols:(int)cols finder:(PathFinder *)finder {
	NSArray *path1 = [finder findPathRow:0 Col:(int)index.x toRow:row toCol:0];
	NSArray *path2 = [finder findPathRow:0 Col:(int)index.x toRow:row toCol:cols/2 - 1];
	NSArray *path3 = [finder findPathRow:0 Col:(int)index.x toRow:row toCol:(int)index.x];
	NSArray *path4 = [finder findPathRow:0 Col:(int)index.x toRow:row toCol:cols-1];
	
	int path1Length = path1 == nil ? BIG_NUMBER : [path1 count];
	int path2Length = path2 == nil ? BIG_NUMBER : [path2 count];
	int path3Length = path3 == nil ? BIG_NUMBER : [path3 count];
	int path4Length = path4 == nil ? BIG_NUMBER : [path4 count];
	
	int min = MIN(path1Length, path2Length);
	min = MIN(min, path3Length);
	min = MIN(min, path4Length);
	
	NSArray *shortestPath = nil;
	
	if (min == path1Length)
		shortestPath = path1;
	else if (min == path2Length)
		shortestPath = path2;
	else if (min == path3Length)
		shortestPath = path3;
	else
		shortestPath = path4;

	return shortestPath;
}

- (NSMutableArray *)towerNodesForPathFinding {
	NSMutableArray *towerNodes = [NSMutableArray array];
	for (Tower *tower in towers) {
		CGPoint indexes = [self worldToGridIndexes:tower.position];
		PathFindNode *n = [PathFindNode node];
		n->nodeX = indexes.x;
		n->nodeY = indexes.y;
		
		[towerNodes addObject:n];
	}
	
	return towerNodes;
}

- (void)planEnemiesPath {
	PathFinder *finder = [[[PathFinder alloc] initWithRows:[self rows] columns:[self cols] walls:[self towerNodesForPathFinding]] autorelease];	
	
	for (Enemy *enemy in enemies) {
		
		CGPoint index = [self worldToGridIndexes:enemy.position];
		enemy.path = [self getShortestExitFrom:index row:[self rows]-1 cols:[self cols] finder:finder];

		enemy.dirX = 0;
		enemy.dirY = -1;
		enemy.pathIndex = 0;
	}		
	
	enemiesAlreadyPlanned = YES;
}

- (BOOL)doesBlockPathIfAddedTo:(CGPoint)location {
	NSMutableArray *towerNodes = [self towerNodesForPathFinding];
	
	CGPoint indexes = [self worldToGridIndexes:location];
	PathFindNode *n = [PathFindNode node];
	n->nodeX = indexes.x;
	n->nodeY = indexes.y;
	
	[towerNodes addObject:n];	
	
	PathFinder *finder = [[[PathFinder alloc] initWithRows:[self rows] columns:[self cols] walls:towerNodes] autorelease];	
	
	NSArray *path1 = [finder findPathRow:0 Col:0 toRow:[self rows]-1 toCol:0];
	
	if (path1 == nil)
		return YES;
	else
		return NO;
}

- (void)restart {
	for (Shoot *shoot in bullets) {
		[self removeChild:shoot->emitter cleanup:YES];
	}
	[bullets removeAllObjects];
	
	for (Enemy *enemy in [[enemies copy] autorelease]) {
		[enemies removeObject:enemy];
		[self removeChild:enemy cleanup:NO];
	}

	enemiesAlreadyPlanned = NO;
	
	elapsed = 0;

	lives = 1;

	[self prepareLevel];
}

- (void)cleanTowers {
	for (Tower *tower in [[towers copy] autorelease]) {
		[self removeTower:tower];
	}	
}

- (void)cleanEnemies {
	for (Enemy *enemy in [[enemies copy] autorelease]) {
		[self removeEnemy:enemy];
	}	
}

- (void)cleanup {
	[self cleanEnemies];
	[self cleanTowers];
}

- (void)gameCompleted {
	[self cleanEnemies];
	
	[control gameCompleted:elapsed];
	
	levelDone = NO;

	[self stopAnimations];
	
	[self unschedule:@selector(gameCompleted)];
}

- (void)decideDirection:(Enemy *)enemy {
	if (enemy.pathIndex == [enemy.path count]) {
		enemy.dirX = 0;
		enemy.dirY = -1;
		enemy.rotation = 0;
		return;
	} 
	
	PathFindNode *previous = [enemy.path objectAtIndex:[enemy.path count] - 1 - enemy.pathIndex + 1];
	PathFindNode *actual = [enemy.path objectAtIndex:[enemy.path count] - 1 - enemy.pathIndex];
	
	if (previous->nodeY == actual->nodeY) {
		if (actual->nodeX < previous->nodeX) {
			enemy.dirX = -1;
			enemy.dirY = 0;
			enemy.rotation = 90;
		} else {
			enemy.dirX = 1;
			enemy.dirY = 0;
			enemy.rotation = -90;			
		}
	} else {
		if (actual->nodeY < previous->nodeY) {
			enemy.dirX = 0;
			enemy.dirY = 1;
			enemy.rotation = 180;			
		} else {
			enemy.dirX = 0;
			enemy.dirY = -1;
			enemy.rotation = 0;
		}		
	}
}

- (void)processEnemies:(ccTime)dt {
	float cellSize = [self cellSize].width;
	for (CCNode *child in [self children]) {
		if ([child isKindOfClass:[Enemy class]]) {
			Enemy *enemy = (Enemy *)child;
			enemy.position = ccp (enemy.position.x + cellSize * enemy.dirX * enemy.speed * dt * enemy.speedFactor, enemy.position.y + cellSize * enemy.dirY * enemy.speed * dt * enemy.speedFactor);

			if ([enemy numberOfRunningActions] == 0) {
				[enemy startAnimating];
			}

			if (enemy.pathIndex == [enemy.path count])
				continue;

			PathFindNode *node = [enemy.path objectAtIndex:[enemy.path count] - 1 - enemy.pathIndex];
			CGPoint worldLocation = [self indexesToWorld:ccp(node->nodeX, node->nodeY)];

			if (enemy.dirX == -1) {
				if (enemy.position.x <= worldLocation.x) {
					enemy.position = ccp(worldLocation.x, enemy.position.y);
					enemy.pathIndex++;
					[self decideDirection:enemy];
				}
			} else if (enemy.dirX == 1) {
				if (enemy.position.x >= worldLocation.x) {
					enemy.position = ccp(worldLocation.x, enemy.position.y);
					enemy.pathIndex++;
					[self decideDirection:enemy];
				}
			} else if (enemy.dirY == 1) {
				if (enemy.position.y >= worldLocation.y) {
					enemy.position = ccp(enemy.position.x, worldLocation.y);
					enemy.pathIndex++;
					[self decideDirection:enemy];
				}
			} else if (enemy.dirY == -1) {
				if (enemy.position.y <= worldLocation.y) {
					enemy.position = ccp(enemy.position.x, worldLocation.y);
					enemy.pathIndex++;
					[self decideDirection:enemy];
				}
			}
		}
	}
} 

- (void)tick:(ccTime)dt {
	if (!levelDone) {
		elapsed += dt;
	}
	
	if ([enemies count] == 0 && !levelDone) {
		[self schedule:@selector(gameCompleted) interval:1.0];
		levelDone = YES;
	}
	
	[self checkBoundaries];

	[self processEnemies:dt];

	[self processTowers:dt];

	[self processShoots:dt];
	
	[self processParticles:dt];
	
//	for (Enemy *enemy in enemies) {
//		NSLog(@"Enemy at %f with:%f", enemy.position.y, elapsed);
//	}	
}

- (void)enemyDestroyed {
	[control updateEnergy:energy];
}

- (BOOL)consumeEnergy:(int)someEnergy {
	if (energy >= someEnergy || someEnergy < 0) {
		energy -= someEnergy;
		[control updateEnergy:energy];

		return YES;
	} else {
		return NO;
	}
}

- (void)startDefending {
	for (Enemy *enemy in [[enemies copy] autorelease]) {
		[enemies removeObject:enemy];
		[self removeChild:enemy cleanup:NO];
	}

	for (Enemy *enemy in addedEnemies) {
		Enemy *copy = [enemy copy]; // TODO: leak
		[enemies addObject:copy];
		[self addChild:copy];
	}	
	
	if (!enemiesAlreadyPlanned) {
		[self planEnemiesPath];
	}
	
	for (Tower *tower in towers) {
		[tower savePosition];
		if ([tower isKindOfClass:[Bomb class]]) {
			[tower runAction:[CCRepeatForever actionWithAction:tower.animation]];
		}
	}
}

- (void)addTower:(Tower *)tower {
//	if ([towers count] < TOWERS_LIMIT) {
		[addedTowers addObject:tower];
		
		[towers addObject:tower];
		[self addChild:tower];
		[tower savePosition];
//	}
}

- (void)addEnemy:(Enemy *)enemy {
	[addedEnemies addObject:enemy];

	[enemies addObject:enemy];
	[self addChild:enemy];
}

- (void)removeEnemy:(Enemy *)enemy {
	[addedEnemies removeObject:enemy];
	
	[enemies removeObject:enemy];
	[self removeChild:enemy cleanup:NO];
}

- (void)removeTower:(Tower *)tower {
	[addedTowers removeObject:tower];
	
	[towers removeObject:tower];
	[self removeChild:tower cleanup:NO];
}

- (Enemy *)enemyAtLocation:(CGPoint)location {
	for (Enemy *enemy in self.enemies) {
		CGRect enemyRect;
		enemyRect.size = [enemy contentSize];
		enemyRect.origin = ccp(enemy.position.x - enemyRect.size.width/2, enemy.position.y - enemyRect.size.height/2);
		if (CGRectContainsPoint(enemyRect, location)) {
			return enemy;
		}
	}
	
	return nil;
}

- (Tower *)towerAtLocation:(CGPoint)location {
	if ([self.towers count] == 0)
		return nil;
	
	for (Tower *tower in self.towers) {
		CGRect towerRect;
		towerRect.size = [tower contentSize];
		towerRect.origin = ccp(tower.position.x - towerRect.size.width/2, tower.position.y - towerRect.size.height/2);
		if (CGRectContainsPoint(towerRect, location)) {
			return tower;
		}
	}
	
	return nil;
}

- (void)dealloc {
	free(particles);
	free(drawingParticles);
	
	[super dealloc];
}

@end

@implementation Shoot

- (id)initWithCoord:(vector)acoord {
	if ((self = [super init])) {
		c = acoord;
//		emitter = [[CCParticleGalaxy alloc] initWithTotalParticles:EMITTER_PARTICLES];
//		emitter.life = EMITTER_LIFE;
//		emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
		emitter = [[Movable spriteWithFile:@"fireball.png"] retain];
		emitter.position = ccp(c.x, c.y);
		[emitter runAction:[CCRepeatForever actionWithAction:emitter.animation]];

	}
	return self;
}

- (void)dealloc {
	[emitter release];
	
	[super dealloc];
}

@end