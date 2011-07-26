//
//  HUDLayer.h
//  Cellfense
//
//  Created by Luis Floreani on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "button.h"

#define BUTTON_OPACITY_LIGHT 90
#define BUTTON_OPACITY_MEDIUM 180

@interface HUDLayer : CCLayer {
	id delegate;
	
	CCSprite *background;
	
	BOOL wasOpaque;
}

/**
 * initializer that receives and array of weapon filenames
 */
- (id)initWithTowers:(NSDictionary *)weapons;

/**
 * Returns the filename of the button being touch or nil if no button is touched
 */
- (NSString *)tryTouch:(CGPoint)atLocation;

- (void)setOpaque;
- (void)setNormal;

@end
