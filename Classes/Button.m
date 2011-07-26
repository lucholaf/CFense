//
//  Button.m
//  Cellfense
//
//  Created by Luis Floreani on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Button.h"


@implementation Button
@synthesize on;
@synthesize name;
@synthesize opacityOn;
@synthesize opacityOff;

+ (id)spriteWithFile:(NSString *)filename opacityOn:(int)opacOn opacityOff:(int)opacOff {
	Button *button = [Button spriteWithFile:filename];
	button.opacityOn = opacOn;
	button.opacityOff = opacOff;
	button.opacity = opacOff;
	button.name = filename;
	
	return button;
}

- (BOOL)touched:(CGPoint)location
{
	if (!self.visible)
		return NO;
	
	CGRect area;
	area.origin = ccp(self.position.x - [self contentSize].width/2, self.position.y - [self contentSize].height/2);
	area.size = [self contentSize];
	
	if (CGRectContainsPoint(area, location))
		return YES;
	else
		return NO;
}

- (BOOL)tryTouch:(CGPoint)atLocation {	
	if ([self touched:atLocation]) {
		self.opacity = opacityOn;
		touching = YES;
	} else {
		self.opacity = opacityOff;
		touching = NO;
	}
	
	return touching;
}

- (BOOL)touchEnded:(CGPoint)atLocation {
	BOOL ret = NO;
	if (touching && [self touched:atLocation]) {
		ret = YES;
	}
	
	self.opacity = opacityOff;
	touching = NO;
	
	return ret;
}

@end

@implementation TouchTime
- (id)init {
	if ((self = [super init])) {
		nextDeltaTimeZero = YES;
	}
	return self;
}

-(void) reset
{
	nextDeltaTimeZero = YES;
}

-(float) calculateDeltaTouchTime
{
	struct timeval now;
	float deltaTouchTime;
	
	gettimeofday( &now, NULL);
	
	if (nextDeltaTimeZero) {
		deltaTouchTime = 0;
		nextDeltaTimeZero = NO;
	} else {
		deltaTouchTime = (now.tv_sec - lastTouchTime.tv_sec) + (now.tv_usec - lastTouchTime.tv_usec) / 1000000.0f;
		deltaTouchTime = MAX(0, deltaTouchTime);
	}
	
	lastTouchTime = now;
	
	return deltaTouchTime;
}

@end