//
//  Button.h
//  Cellfense
//
//  Created by Luis Floreani on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TouchTime : NSObject
{
	struct timeval lastTouchTime;
	BOOL nextDeltaTimeZero;
}
-(float) calculateDeltaTouchTime;
-(void) reset;
@end


/**
 * In game button
 */
@interface Button : CCSprite {
	NSString *name;
	BOOL on;
	BOOL touching;
	int opacityOn;
	int opacityOff;
}

@property(retain) NSString *name;
@property(readonly) BOOL on;
@property int opacityOn;
@property int opacityOff;

/**
 * Opacity must be beetween 0 and 255
 */
+ (id)spriteWithFile:(NSString *)filename opacityOn:(int)opacOn opacityOff:(int)opacOff;

/**
 * Used normally when user touch began and returns YES if the button is touched 
 */
- (BOOL)tryTouch:(CGPoint)atLocation;


/**
 * Used normally when user touch ends and returns YES if the button is released upon its area
 */
- (BOOL)touchEnded:(CGPoint)atLocation;

@end