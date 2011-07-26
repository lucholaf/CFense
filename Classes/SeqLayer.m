//
//  SeqLayer.m
//  Cellfense
//
//  Created by Luis Floreani on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeqLayer.h"
#import "cocos2d.h"

@implementation SeqLayer : CCLayer

- (void)showNext {
	for (CCNode *child in [[[self children] copy] autorelease]) {
		if (child != touchLabel)
			[self removeChild:child cleanup:YES];
	}
	
	if (progress < [screens count]) {
		CCSprite *b = [CCSprite spriteWithFile:[screens objectAtIndex:progress]];
		b.position = ccp(b.contentSize.width/2, b.contentSize.height/2);
		[self addChild:b];
		
		[touchLabel setString:[NSString stringWithFormat:@"%@ (%d/%d)", NSLocalizedString(@"TouchToContinue", @""), progress+1, [screens count]]];
	} else {
		[self.parent performSelector:@selector(showMenu)];
		[self.parent removeChild:self cleanup:YES];
	}
}

- (id)initWithScreens:(NSArray *)someScreens {
	self = [super init];
	if (self != nil) {
		self.isTouchEnabled = YES;
		progress = 0;
		screens = [someScreens retain];
		
		touchLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:16];
		touchLabel.color = ccGRAY;
		touchLabel.position = ccp(self.contentSize.width/2, touchLabel.contentSize.height/2 + 15);
		[self addChild:touchLabel z:1];
		[touchLabel runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeOut actionWithDuration:3.0], [CCFadeIn actionWithDuration:1.0], nil]]];
		
		[self showNext];
	}
	return self;	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	progress++;
	[self showNext];
}

- (void)dealloc {
	[screens release];
	
	[super dealloc];
}

@end
