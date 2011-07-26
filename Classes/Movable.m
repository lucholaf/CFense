//
//  Movable.m
//  Cellfense
//
//  Created by Luis Floreani on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Movable.h"


@implementation Movable

@synthesize animation;
@synthesize filename;

- (CCAnimate *)getAnimation:(NSString *)name {
	NSArray *parts = [name componentsSeparatedByString:@"_"];
	
	NSString *part;
	if ([parts count] == 1) {
		part = [[[parts objectAtIndex:0] componentsSeparatedByString:@"."] objectAtIndex:0];
	} else {
		part = [parts objectAtIndex:0];		
	}
	
	NSString *file = [NSString stringWithFormat:@"%@%@", part, @".anim.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:file];
	
	NSString *path = [CCFileUtils fullPathFromRelativePath:file];
	NSDictionary *fileContent = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSMutableArray *animFrames = [NSMutableArray array];
	int frames = [[fileContent objectForKey:@"frames"] count];
	int startFrame = ([self startFrame] % frames) + 1;
	for(int i = startFrame; i < startFrame + frames; i++) {		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:[NSString stringWithFormat:@"%@%@", part, @"_frame%01d.png"], (i % frames) + 1]];
		[animFrames addObject:frame];
	}
	
	CCAnimation *anim;
	if ([name rangeOfString:@"chip"].location != NSNotFound)
		anim = [CCAnimation animationWithFrames:animFrames delay:0.035f];
	else
		anim = [CCAnimation animationWithFrames:animFrames delay:0.05f];
	
	return [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
}

- (int)startFrame {
	return 1;
}

+ (id)spriteWithFile:(NSString*)filename {
	Movable *obj = [super spriteWithFile:filename];
	
	if (obj) {
		obj.filename = filename;
		obj.animation = [obj getAnimation:filename];
	}
	
	return obj;
}


@end
