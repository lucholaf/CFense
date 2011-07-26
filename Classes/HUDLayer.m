//
//  HUDLayer.m
//  Cellfense
//
//  Created by Luis Floreani on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"
#import "button.h"

@implementation HUDLayer

- (id)initWithTowers:(NSDictionary *)someTowers {
	if ((self = [super init])) {
		background = [CCSprite spriteWithFile:@"hud.png"];
		[background setPosition:ccp([background contentSize].width/2, [background contentSize].height/2)];				
		background.opacity = 90;		
		[self addChild:background];		

		int widthCounter = 0;
		for (NSString *filename in someTowers) {
			Button *button = [Button spriteWithFile:filename opacityOn:BUTTON_OPACITY_LIGHT opacityOff:BUTTON_OPACITY_MEDIUM];
			[button setPosition:ccp([self contentSize].width - widthCounter - [button contentSize].width/2, [button contentSize].height)];
			[self addChild:button];
			
			//CCLabelTTF *cost = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [[someTowers objectForKey:filename] intValue]] fontName:@"Trebuchet MS" fontSize:12];
			//[cost setPosition:ccp([self contentSize].width - widthCounter - [button contentSize].width/2, [cost contentSize].height)];
			//[self addChild:cost];

			widthCounter += [button contentSize].width;
			
			CCSprite *separator = [CCSprite spriteWithFile:@"separator.png"];
			separator.opacity = BUTTON_OPACITY_LIGHT;
			[separator setPosition:ccp([self contentSize].width - widthCounter - [separator contentSize].width/2, background.position.y)];		
			[self addChild:separator];		
			
			widthCounter += [separator contentSize].width;			
		}
	}
	
	return self;
}

- (NSString *)tryTouch:(CGPoint)atLocation {
	for (id object in [self children]) {
		if ([object isKindOfClass:[Button class]] && [((Button *)object) tryTouch:atLocation])
			return ((Button *)object).name;
	}
	
	return nil;
}

- (void)setOpaque {
	if (!wasOpaque) {
		for (CCSprite *child in [self children]) {
			if ([child isKindOfClass:[Button class]])
				child.opacity = 90;
		}
	}
	wasOpaque = YES;
}

- (void)setNormal {
	if (wasOpaque) {
		for (CCSprite *child in [self children]) {
			if ([child isKindOfClass:[Button class]])
				child.opacity = 255;
		}
	}
	wasOpaque = NO;
}

- (void)dealloc {
	[super dealloc];
}

@end