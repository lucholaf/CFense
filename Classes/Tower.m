//
//  Tower.m
//  Cellfense
//
//  Created by Luis Floreani on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "SimpleAudioEngine.h"
#import "Tower.h"
#import "AudioEngine.h"
#import "math.h"

#define kCrazyTime 2000
#define kExplosionTime 700

@implementation Tower

@synthesize level;
@synthesize range;
@synthesize cost;
@synthesize shootingAt;
@synthesize origPosition;

- (id)init {
	if ((self = [super init])) {
		level = 1;
		lineWidth = 1;
		crazyTimer = kCrazyTime;
	}
	
	return self;
}

- (float)range {
	return range;
}

- (void)resetTimers {
	shootingAt = nil;
	
	shootTimer = 0.0;
	crazyTimer = kCrazyTime;
}

+ (id)spriteWithFile:(NSString*)filename range:(float)range rate:(float)rate cost:(int)cost shootSound:(NSString *)shootSound {
	Tower *tower = [self spriteWithFile:filename];
	tower->range = range;
	tower->rate = rate;
	tower->shootSound = shootSound;
	tower->cost = cost;
	
	return tower;
}

+ (id)towerWithFile:(NSString*)filename {
	Tower *tower;
	
	if ([filename isEqualToString:TURRET_TOWER]) {
		tower = [Tower spriteWithFile:filename range:TURRET_RANGE rate:TURRET_RATE cost:TURRET_COST shootSound:@"chain_gun.wav"];	
	} else if ([filename isEqualToString:TANK_TOWER]) {
		tower = [Tower spriteWithFile:filename range:TANK_RANGE rate:TANK_RATE cost:TANK_COST shootSound:@"canon.wav"];
		CCSprite *base = [CCSprite spriteWithFile:@"tank_base.png"];
		base.position = ccp(tower.contentSize.width/2, tower.contentSize.height/2);
		[tower addChild:base z:-1];
	} else if ([filename isEqualToString:LASER_TOWER]) {
		tower = [Tower spriteWithFile:filename range:LASER_RANGE rate:LASER_RATE cost:LASER_COST shootSound:@"canon.wav"];			
	} else if ([filename isEqualToString:BOMB_TOWER]) {
		tower = [Bomb spriteWithFile:filename range:BOMB_RANGE rate:0 cost:BOMB_COST shootSound:@"canon.wav"];			
	} else {
		tower = nil;
	}

	NSAssert(tower != nil, ([NSString stringWithFormat:@"Tower for %@ not found", filename]));

	return tower;
}

- (void)setRotation:(float)newRotation {
	[super setRotation:newRotation];

	for (CCNode *node in [self children]) {
		node.rotation = -newRotation;
	}
}

- (float)damage:(Enemy *)enemy {
	if ([self.filename isEqualToString:TURRET_TOWER] && [enemy.filename isEqualToString:SPIDER_FILE])
		return TURRET_DAMAGE_TO_SPIDER;
	else if ([self.filename isEqualToString:TANK_TOWER] && [enemy.filename isEqualToString:SPIDER_FILE])
		return TANK_DAMAGE_TO_SPIDER;
	else if ([self.filename isEqualToString:LASER_TOWER] && [enemy.filename isEqualToString:SPIDER_FILE])
		return LASER_DAMAGE_TO_SPIDER;
	else if ([self.filename isEqualToString:TURRET_TOWER] && [enemy.filename isEqualToString:CATERPILLAR_FILE])
		return TURRET_DAMAGE_TO_CATERPILLAR;
	else if ([self.filename isEqualToString:TANK_TOWER] && [enemy.filename isEqualToString:CATERPILLAR_FILE])
		return TANK_DAMAGE_TO_CATERPILLAR;
	else if ([self.filename isEqualToString:LASER_TOWER] && [enemy.filename isEqualToString:CATERPILLAR_FILE])
		return LASER_DAMAGE_TO_CATERPILLAR;
	else if ([self.filename isEqualToString:TURRET_TOWER] && [enemy.filename isEqualToString:CHIP_FILE])
		return TURRET_DAMAGE_TO_CHIP;
	else if ([self.filename isEqualToString:TANK_TOWER] && [enemy.filename isEqualToString:CHIP_FILE])
		return TANK_DAMAGE_TO_CHIP;
	else if ([self.filename isEqualToString:LASER_TOWER] && [enemy.filename isEqualToString:CHIP_FILE])
		return LASER_DAMAGE_TO_CHIP;
	else
		return 1.0;
}

- (void)savePosition {
	origPosition.x = self.position.x;
	origPosition.y = self.position.y;	
}

- (void)tick:(ccTime)dt {
	int intTime = (int)(dt*1000);
	shootTimer += intTime;
	crazyTimer += intTime;
	
	if (crazyTimer >= kCrazyTime) {
		self.position = origPosition;
	} else {
		self.position = ccp(origPosition.x + ((rand() % 3) - 1), origPosition.y + ((rand() % 3) - 1));
	}
}

- (BOOL)isCrazy {
	return crazyTimer < kCrazyTime;
}

- (float)realRate {
	if (crazyTimer < kCrazyTime)
		return rate/3.0;
	else
		return rate;
}

- (void)goCrazy {
	crazyTimer = 0;
}

-(void)draw {
	if (lineWidth > 0) {
		if (![self isCrazy]) {
			glLineWidth(lineWidth);
			glColor4ub(0, 60, 0, 0);			
		} else {
			glLineWidth(2);
			glColor4ub(120, 0, 0, 0);			
		}
		ccDrawCircle(ccp(self.contentSize.width/2, self.contentSize.height/2), self.range * self.contentSize.width, 0, 30, 0);		
	}
	
	[super draw];
}

- (BOOL)tryShoot:(Enemy *)enemy {
	if (shootTimer >= (int)([self realRate] * 1000)) {
		shootTimer = 0;
		
		//NSLog(@"ENEMY x:%f y:%f SHOOT AT %f", enemy.position.x, enemy.position.y, shootTimer);
		
		float damage = [self damage:enemy];
		
		[enemy shoot:damage];
	
		if ([self numberOfRunningActions] == 0)
			[self runAction:self.animation];

		[AudioEngine playSound:shootSound];	

		return YES;
	} else {
		return NO;
	}
}

- (CCAnimate *)getAnimation:(NSString *)name {
	return [super getAnimation:name];
}

@end

@implementation Bomb

@synthesize exploded;

- (void)resetTimers {
	exploded = NO;
	lineWidth = 1;
	explosionTimer = kExplosionTime;
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"bomb_button.png"];
	if (texture) {
		[self setTexture:texture];
		[self setTextureRect:CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height)];
	}
}

- (void)explode {
	if (exploded)
		return;
	
	exploded = YES;
	explosionTimer = 0;
	lineWidth = 0;
	
	[self stopAllActions];

	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"bomb_exploded.png"];
	if (texture) {
		[self setTexture:texture];
		[self setTextureRect:CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height)];
	}
}

- (void)tick:(ccTime)dt {
	int intTime = (int)(dt*1000);
	explosionTimer += intTime;
	explosionTimer = MIN(kExplosionTime, explosionTimer);
	
	[super tick:dt];
}

- (void)draw {
	if (exploded && explosionTimer < kExplosionTime) {
		glLineWidth(15);
		glColor4ub(0, 0, 120, 0.5);
		
		float factor = (kExplosionTime - explosionTimer) / (float)kExplosionTime;
		ccDrawCircle(ccp(self.contentSize.width/2, self.contentSize.height/2), self.range * self.contentSize.width * factor, 0, 30, 0);			
	}
	
	[super draw];
}

@end