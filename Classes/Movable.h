//
//  Movable.h
//  Cellfense
//
//  Created by Luis Floreani on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Movable : CCSprite {
	CCAnimate *animation;
	NSString *filename;
}

- (int)startFrame;
- (CCAnimate *)getAnimation:(NSString *)name;

@property(retain, nonatomic) CCAnimate *animation;
@property(copy) NSString *filename;

@end
