//
//  MenuScene.h
//  Cellfense
//
//  Created by Luis Floreani on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelsController.h"
#import "AboutViewController.h"
#import "OptionsViewController.h"

@interface MenuScene : CCScene {
}

+ (MenuScene *)sharedInstance;

- (void)showLevels;
- (void)showMenu;

@end

@interface MenuLayer : CCLayer {
	int cheatCounter;
	int resetCounter;

	CCMenu *menu;
	LevelsController *levelController;	
	AboutViewController *aboutController;	
	OptionsViewController *optionsController;	
}

@end
