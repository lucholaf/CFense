//
//  ControlLayer.h
//  Cellfense
//
//  Created by Luis Floreani on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HUDLayer.h"
#import "Button.h"
#import "Tower.h"
#import "Level.h"

#define POWERUP_COST 10
#define LTA_COST 5

@class WorldLayer;

@interface ControlLayer : CCLayer {
	CCSprite *bg;
	HUDLayer *hud;
	WorldLayer *world;
	Button *downButton;
	Button *upButton;
	
	Button *configButton;
	Button *rushButton;
	Button *rushButtonOff;
	Button *pauseButton;
	
	CCSprite *topHud;
	CCLabelTTF *stageLabel;
	
	Movable *emitter;
	
	ccColor3B energyColor;
	
	Tower *touchedTower;
	Tower *bombTower;
	Enemy *addingEnemy;
	CGPoint touchedTowerOriginalPosition;
	
	BOOL readyToShoot;
	
	BOOL panning;
	BOOL sliding;
	
	BOOL movingTower;

	BOOL newArt;
	BOOL isLastLevel;
	
	int state;
	
	int stage;
	
	int lastScore;
	
	int lives;
	
	int lastEnergy;
	int consumedEnergy;
	ccTime energyConsuming;
	
	float slidingVelocityY;
	float slidingLastTouchPositionY;
	TouchTime *slidingTouchTime;	

	float offset;	
	
	UITouch *savedTouch;
	
	float shootingVelocityY;
	float shootingVelocityX;
	float shootingLastTouchPositionY;
	float shootingLastTouchPositionX;
	TouchTime *shootingTouchTime;
	
	CCLabelTTF *energyLabel;
	CCLabelTTF *scoreLabel;
	CCLabelTTF *comboLabel;
	CCLabelTTF *messageLabel;
	
	int combo;
	
	int tutorialStage;
	
	ccTime lastHit;
	
	NSMutableDictionary *costsByTower;
	
	UIViewController *config;
	
	int energy;
	
	NSString *towersString;
	NSString *lastMessage;
	
	CCMoveBy *rushButtonReverse;
	CCMoveBy *rushButtonOffReverse;
	CCMoveBy *downButtonReverse;
	CCMoveBy *upButtonReverse;
	CCMoveBy *topHudReverse;
	CCMoveBy *stageLabelReverse;
	CCMoveBy *energyLabelReverse;
	
	CGRect allowedArea;
	CGPoint towerBeingApproachedPosition;
	
	BOOL ltaDisabled;
	BOOL powerupDisabled;
	
	BOOL unlocked;
	
	CCLabelTTF *tutMsg;
	CCLabelTTF *tutMsg2;
}

+ (id)nodeWithLevel:(Level *)level unlocked:(BOOL)unlocked;

- (void)updateLives:(int)lives;
- (void)updateEnergy:(int)energy;

- (void)gameCompleted:(ccTime)elapsed;

- (void)enemyApproaching:(CGPoint)towerPosition;

@end
