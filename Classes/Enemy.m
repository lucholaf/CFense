//
//  Enemy.m
//  Cellfense
//
//  Created by Luis Floreani on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"
#import "Constants.h"

#define LIFE_BAR_OFFSET 3

ccColor3B restoredColor = {255, 255, 255};
ccColor3B blueColor = {100, 100, 255};

@implementation Enemy

@synthesize speed;
@synthesize life;
@synthesize speedFactor;
@synthesize row;
@synthesize col;
@synthesize dirX;
@synthesize dirY;
@synthesize pathIndex;
@synthesize path;

+ (id)spriteWithFile:(NSString*)filename speed:(float)speed {
	Enemy *enemy = [Enemy spriteWithFile:filename];
	enemy->startLife = 100;
	enemy->life = enemy->startLife;
	enemy->speed = speed;
	
	return enemy;
}

- (void)calcLifeWidth {
	lifeWidth = ((float)life/startLife) * self.contentSize.width;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		speed = 0;
		speedFactor = 1.0;
	}
	return self;
}

- (void)resurrect {
	life = startLife;
	speedFactor = 1.0;
	self.color = restoredColor;
	
	[self calcLifeWidth];
}

- (int)startFrame {
	return rand();
}

- (void)startAnimating {
	[self runAction:[CCRepeatForever actionWithAction:self.animation]];	
}

- (void)draw {
	if (life != 0 && lifeWidth == 0) { // first-time drawing
		[self calcLifeWidth];
	}
	
	if (life > 25)
		glColor4ub(43, 180, 9, 0);
	else
		glColor4ub(214, 0, 48, 0);
		
	glLineWidth(2);
	ccDrawLine(ccp(0, self.contentSize.height + LIFE_BAR_OFFSET), ccp(MAX(lifeWidth, 2), self.contentSize.height + LIFE_BAR_OFFSET));
	
	[super draw];
}

- (void)restoreSpeed {
	speedFactor = 1.0;
	self.color = restoredColor;
	
	[self unschedule:@selector(restoreSpeed)];
}

- (id)copyWithZone:(NSZone *)zone {
	Enemy *copy = [Enemy spriteWithFile:filename speed:speed];
	copy.position = self.position;
	return copy;
}

- (void)slow {
	speedFactor = SLOW_FACTOR;
	
	[self unschedule:@selector(restoreSpeed)];
	[self schedule:@selector(restoreSpeed) interval:SLOW_TIME];
	
	self.color = blueColor;
}

- (void)shoot:(float)damage {
	if (life != 0) {
		life -= damage;
		//NSLog(@"Enemy at x:%f y:%f with life:%f", self.position.x, self.position.y, life);		
	}

	if (life <= 0) {
		life = 0;
		
		[self.parent performSelector:@selector(enemyDestroyed)];
		
		[self stopAllActions];		
	}
	
	[self calcLifeWidth];	
}

- (float)life {
	return life;
}

@end
