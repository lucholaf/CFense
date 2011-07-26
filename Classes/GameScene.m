//
//  GameScene.m
//  Cellfense
//
//  Created by Luis Floreani on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "ControlLayer.h"
#import "Constants.h"
#import "AudioEngine.h"

@implementation GameScene

@synthesize level;

+ (id)nodeWithLevel:(Level *)level unlocked:(BOOL)unlocked {
	GameScene *scene = [GameScene node];
	
	scene.level = level;
	
	[scene addChild:[ControlLayer nodeWithLevel:level unlocked:unlocked] z:1];
	
	return scene;
}

- (id)init  {
	if ((self = [super init])) {
		//[CCScheduler sharedScheduler].timeScale = 3.0;
	}
	return self;
}

@end
