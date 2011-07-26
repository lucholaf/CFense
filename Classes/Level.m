//
//  UIImage+filename.m
//  FanCard
//
//  Created by Luis Floreani on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Level.h"

@implementation Level

@synthesize image;
@synthesize enemies;
@synthesize resource;
@synthesize number;
@synthesize name;
@synthesize towersString;

+ (Level *)levelFromFilename:(NSString *)name {
	Level *level = [[[Level alloc] init] autorelease];
	
	level.image = [UIImage imageNamed:name];
	
	return level;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		enemies = [[NSMutableArray array] retain];
	}
	return self;
}


- (void)addEnemy:(Enemy *)enemy {
	[enemies addObject:enemy];
}

- (void)dealloc {
	[enemies release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

@end
