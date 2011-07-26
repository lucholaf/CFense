//
//  GameScene.h
//  Cellfense
//
//  Created by Luis Floreani on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Level.h"

@interface GameScene : CCScene {
	Level *level;
}

@property(retain) Level *level;

+ (id)nodeWithLevel:(Level *)level unlocked:(BOOL)unlocked;

@end
