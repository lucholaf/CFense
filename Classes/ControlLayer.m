//
//  ControlLayer.m
//  Cellfense
//
//  Created by Luis Floreani on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ControlLayer.h"
#import "HUDLayer.h"
#import "Tower.h"
#import "WorldLayer.h"
#import "AudioEngine.h"
#import "Config.h"
#import "Enemy.h"
#import "Constants.h"
#import "MenuScene.h"
#import "Scores.h"
#import "SHK.h"
#import "SHKItem.h"
#import "SHKActionSheet.h"

#define PAN_TOUCHES 2
#define SLIDE_VELOCITY 250
#define MAX_SLIDE_VELOCITY 1000
#define ADDING_TOWER_OPACITY 150
#define SHOOT_OFFSET 41
#define HUD_HEIGHT 105

#define MAX_LTA_SPEED 350
#define MIN_LTA_SPEED 50
#define MAX_LTA_AMOUNT 6

#define POINTS_PER_SCORE 10
#define COMBO_SHOW_TIME 0.5
#define COMBO_MULTIPLIER 2.0

#define FIXED_TIMESTEP 0.02

#define kStageTag 32131
#define kEquivTag 32132
#define kFingerTag 32133

#define kConsumingEnergyTime 0.40

#define kTutStage1 0
#define kTutStage2 100
#define kTutStage3 200
#define kTutStage4 300

ccColor3B redColor = {150, 0, 0};
ccColor3B yellowColor = {255, 255, 0};
ccColor3B realColor = {255, 255, 255};
ccColor3B violetColor = {102, 102, 255};
ccColor3B violetRedColor = {255, 51, 128};

enum states {
	PLANNING,
	DEFENDING,
	ENDED,
	RESTARTING,
	PAUSED
};

@implementation ControlLayer

+ (id)nodeWithLevel:(Level *)level unlocked:(BOOL)unlocked  {
	ControlLayer *control = [ControlLayer alloc];
	
	control->stage = level.number;
	control->unlocked = unlocked;
	control->towersString = level.towersString;
	
	[[control init] autorelease];
	
	control->world = [WorldLayer nodeWithLevel:level andEnergy:level.resource];
	[control addChild:control->world z:0];	
	
	return control;
}

- (void)addHud:(NSString *)towersAsString {
	NSSet *towerSet = [NSSet setWithArray:[towersAsString componentsSeparatedByString:@","]];
	costsByTower = [[NSMutableDictionary dictionary] retain];
	if ([towerSet containsObject:@"tt"])
		[costsByTower setObject:[NSNumber numberWithInt:TANK_COST] forKey:TANK_TOWER];
	if ([towerSet containsObject:@"tc"])
		[costsByTower setObject:[NSNumber numberWithInt:TURRET_COST] forKey:TURRET_TOWER];
	if ([towerSet containsObject:@"tb"])
		[costsByTower setObject:[NSNumber numberWithInt:BOMB_COST] forKey:BOMB_TOWER];
	
	if (hud)
		[self removeChild:hud cleanup:YES];
	
	hud = [[HUDLayer alloc] initWithTowers:costsByTower]; 
	hud.visible = NO;
	[self addChild:hud z:1];
}

- (id)init {
	if ((self = [super init])) {
		self.isTouchEnabled = YES;
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		energyColor = violetColor;

		bg = [CCSprite spriteWithFile:@"background.png"];
        [bg setPosition:ccp(size.width/2, 0)];		
		[self addChild:bg z:-1];
		
		pauseButton = [Button spriteWithFile:@"pause.png" opacityOn:BUTTON_OPACITY_LIGHT opacityOff:BUTTON_OPACITY_MEDIUM];
		pauseButton.position = ccp(pauseButton.contentSize.width/2 - 8, self.contentSize.height - 16);
		pauseButton.visible = YES;
		[self addChild:pauseButton z:100];
		
		topHud = [CCSprite spriteWithFile:@"top_hud.png"];
		[topHud setPosition:ccp(self.contentSize.width/2, self.contentSize.height - topHud.contentSize.height/2)];
		topHud.visible = NO;
		[self addChild:topHud z:1];

		stageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"L%d", stage] dimensions:CGSizeMake(50, 16) alignment:UITextAlignmentCenter fontName:@"Trebuchet MS" fontSize:14];
		stageLabel.position = ccp(self.contentSize.width/2 - 37, self.contentSize.height - 16);
		stageLabel.visible = NO;
		[self addChild:stageLabel z:2 tag:kStageTag];
		
		energyLabel = [CCLabelTTF labelWithString:@"-" dimensions:CGSizeMake(50, 16) alignment:UITextAlignmentRight fontName:@"Trebuchet MS" fontSize:14];
		energyLabel.visible = NO;
		[energyLabel setPosition:ccp(self.contentSize.width - topHud.contentSize.width - 3 - energyLabel.contentSize.width/2, self.contentSize.height - 16)];
		[self addChild:energyLabel z:2];		

		[self addHud:towersString];	
		
//		emitter = [[[CCParticleGalaxy alloc] initWithTotalParticles:EMITTER_PARTICLES] autorelease];
//		emitter.life = EMITTER_LIFE;
//		emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
//		emitter.position = ccp(size.width/2 - 3, SHOOT_OFFSET);
//		emitter.visible = NO;
		
		emitter = [[Movable spriteWithFile:@"fireballbase.png"] retain];
		emitter.visible = NO;
		emitter.position = ccp(size.width/2 - 3, SHOOT_OFFSET);
		[emitter runAction:[CCRepeatForever actionWithAction:emitter.animation]];

		[self addChild:emitter];		
		
		downButton = [Button spriteWithFile:@"down_button.png" opacityOn:BUTTON_OPACITY_LIGHT opacityOff:BUTTON_OPACITY_MEDIUM];
		downButton.position = ccp(downButton.contentSize.width/2, downButton.contentSize.height/2);
		downButton.visible = NO;
		[self addChild:downButton z:3];

		upButton = [Button spriteWithFile:@"up_button.png" opacityOn:BUTTON_OPACITY_LIGHT opacityOff:BUTTON_OPACITY_MEDIUM];
		upButton.position = ccp(upButton.contentSize.width/2, upButton.contentSize.height/2);
		upButton.visible = NO;
		[self addChild:upButton z:3];
		
		comboLabel = [CCLabelTTF labelWithString:@"x0" fontName:@"Arial" fontSize:120];
		[comboLabel setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
		comboLabel.visible = NO;
		[self addChild:comboLabel z:3];
		
		messageLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:34];
		[messageLabel setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
		messageLabel.visible = NO;
		[self addChild:messageLabel z:3];
		
#ifdef CF_DEBUG
		configButton = [Button spriteWithFile:@"config.png" opacityOn:BUTTON_OPACITY_LIGHT opacityOff:BUTTON_OPACITY_MEDIUM];
		configButton.position = ccp(5 + configButton.contentSize.width/2, 100);
		[self addChild:configButton];
#endif		
		rushButton = [Button spriteWithFile:@"rush_button.png" opacityOn:BUTTON_OPACITY_LIGHT opacityOff:BUTTON_OPACITY_MEDIUM];
		rushButton.visible = NO;
		rushButton.position = ccp(downButton.contentSize.width + rushButton.contentSize.width/2, rushButton.contentSize.height/2);
		[self addChild:rushButton z:2];

		rushButtonOff = [Button spriteWithFile:@"rush_button_off.png" opacityOn:BUTTON_OPACITY_MEDIUM opacityOff:BUTTON_OPACITY_MEDIUM];
		rushButtonOff.visible = YES;
		rushButtonOff.position = ccp(downButton.contentSize.width + rushButtonOff.contentSize.width/2, rushButtonOff.contentSize.height/2);
		[self addChild:rushButtonOff z:2];
		
		tutMsg = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(320, 100) alignment:UITextAlignmentCenter fontName:@"Arial"  fontSize:16];
		tutMsg.visible = NO;
		[self addChild:tutMsg];

		tutMsg2 = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(320, 20) alignment:UITextAlignmentCenter fontName:@"Arial"  fontSize:16];
		tutMsg2.visible = NO;
		[self addChild:tutMsg2 z:11];
		
		CCSprite *battery = [CCSprite spriteWithFile:@"battery.png"];
		battery.position = ccp(self.contentSize.width - battery.contentSize.width/2, self.contentSize.height - battery.contentSize.height/2);
		[battery.texture setAliasTexParameters];
		[self addChild:battery z:2];
		
		slidingTouchTime = [[TouchTime alloc] init];
		shootingTouchTime = [[TouchTime alloc] init];

		config = [[Config alloc] init];

		state = PLANNING;
		
		[AudioEngine playPrepareMusic];
		
		combo = 1;
		
		[self schedule: @selector(tick:)];		
	}
	
	return self;
}

- (void)showButtons {
	[rushButton runAction:rushButtonReverse];
	[rushButtonReverse release];
	rushButtonReverse = nil;

	[rushButtonOff runAction:rushButtonOffReverse];
	[rushButtonOffReverse release];
	rushButtonOffReverse = nil;
	
	[downButton runAction:downButtonReverse];
	[downButtonReverse release];
	downButtonReverse = nil;

	[upButton runAction:upButtonReverse];
	[upButtonReverse release];
	upButtonReverse = nil;
	
	[topHud runAction:topHudReverse];
	[topHudReverse release];
	topHudReverse = nil;

	[stageLabel runAction:stageLabelReverse];
	[stageLabelReverse release];
	stageLabelReverse = nil;

	[energyLabel runAction:energyLabelReverse];
	[energyLabelReverse release];
	energyLabelReverse = nil;
}

- (void)hideButtons {
	CCMoveBy *rushButtonMove = [CCMoveBy actionWithDuration:1.5 position:ccp(-rushButton.contentSize.width - rushButton.position.x, 0)];
	if (rushButtonReverse) [rushButtonReverse release];
	rushButtonReverse = [[rushButtonMove reverse] retain];
	[rushButton runAction:rushButtonMove];

	CCMoveBy *rushButtonOffMove = [CCMoveBy actionWithDuration:1.5 position:ccp(-rushButtonOff.contentSize.width - rushButtonOff.position.x, 0)];
	if (rushButtonOffReverse) [rushButtonOffReverse release];
	rushButtonOffReverse = [[rushButtonOffMove reverse] retain];
	[rushButtonOff runAction:rushButtonOffMove];
	
	CCMoveBy *downButtonMove = [CCMoveBy actionWithDuration:1.0 position:ccp(-downButton.contentSize.width - downButton.position.x, 0)];
	if (downButtonReverse)  [downButtonReverse release];
	downButtonReverse = [[downButtonMove reverse] retain];
	[downButton runAction:downButtonMove];
	
	CCMoveBy *upButtonMove = [CCMoveBy actionWithDuration:1.0 position:ccp(-upButton.contentSize.width - upButton.position.x, 0)];
	if (upButtonReverse) [upButtonReverse release];
	upButtonReverse = [[upButtonMove reverse] retain];
	[upButton runAction:upButtonMove];
	
	CCMoveBy *topHudMove = [CCMoveBy actionWithDuration:1.0 position:ccp(0, topHud.contentSize.height)];
	if (topHudReverse)  [topHudReverse release];
	topHudReverse = [[topHudMove reverse] retain];
	[topHud runAction:topHudMove];
	
	CCMoveBy *stageLabelMove = [CCMoveBy actionWithDuration:1.0 position:ccp(0, stageLabel.contentSize.height + (self.contentSize.height - stageLabel.position.y))];
	if (stageLabelReverse)  [stageLabelReverse release];
	stageLabelReverse = [[stageLabelMove reverse] retain];
	[stageLabel runAction:stageLabelMove];
	
	CCMoveBy *energyLabelMove = [CCMoveBy actionWithDuration:1.0 position:ccp(0, energyLabel.contentSize.height + (self.contentSize.height - stageLabel.position.y))];
	if (energyLabelReverse) [energyLabelReverse release];
	energyLabelReverse = [[energyLabelMove reverse] retain];
	[energyLabel runAction:energyLabelMove];
}

- (CGPoint)getTouchLocation:(NSSet *)touches {
	UITouch *touch = nil;
	if (! panning) {
		touch = [touches anyObject];
		savedTouch = touch;
	} else {
		for (UITouch *t in touches) {
			if (t == savedTouch) {
				touch = t;
				break;
			}
		}
	}
	if (touch != nil) {
		CGPoint location = [touch locationInView: [touch view]];
		return [[CCDirector sharedDirector] convertToGL:location];		
	} else {
		return ccp(0, 0);
	}
}

- (void)processDelta:(ccTime)dt {
	CGSize size = [[CCDirector sharedDirector] winSize];

	if (offset + dt < 0) {
		dt = -offset;
	} else if (offset + dt > size.height) {
		dt = size.height - offset;
	}
	
	offset += dt;
	
	[bg setPosition:ccp(bg.position.x, bg.position.y + dt)];
	[world setPosition:ccp(world.position.x, bg.position.y + dt)];
}

- (BOOL)isCompletelyInFirstArea {
	return offset == 0;
}

- (BOOL)isCompletelyInSecondArea {
	return offset == WORLD_HEIGHT/2;
}

- (void)restart {
	[self showButtons];
	
	state = PLANNING;
	
	sliding = YES;
	slidingVelocityY = -MAX_SLIDE_VELOCITY/2;
	
	[AudioEngine playPrepareMusic];
	
	[world restart];
	
	[[CCDirector sharedDirector] resume];
}

- (void)gameCompleted:(ccTime)elapsed {
	if (stage == 1 && tutorialStage < kTutStage4) {
		if (tutorialStage < kTutStage2) {
			tutorialStage = kTutStage2;
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"") message:NSLocalizedString(@"TutorialText7", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];			
			
			state = RESTARTING;
			
			return;
		} else if (tutorialStage < kTutStage3) {
			tutorialStage = kTutStage3;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"") message:NSLocalizedString(@"TutorialText11", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];			
			
			state = RESTARTING;
			
			return;			
		} else if (tutorialStage < kTutStage4) {
			tutorialStage = kTutStage4;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"") message:NSLocalizedString(@"TutorialText16", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];			
			
			state = RESTARTING;
			
			return;			
		}

		[self restart];
		
		return;
	}
	
	[[CCDirector sharedDirector] pause];
	
	int intElapsed = (int)elapsed;
	
	lastScore = (int)((1.0/(intElapsed*intElapsed)) * 100000.0) + energy * 30;
	
	NSLog(@"ELAPSED:.......%f", elapsed);

	newArt = [[Scores sharedInstance] setScore:lastScore forLevel:world.levelData];
	isLastLevel = [[Scores sharedInstance] isLastLevel:world.levelData];
	
	NSString *msg;
	UIAlertView* alertView;
	if (stage == 1) {
		msg = NSLocalizedString(@"TutorialFinished", @"");		
		alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LevelCompleted", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"TryAgain", @"") otherButtonTitles:NSLocalizedString(@"Continue", @""), nil];
	} else {
		msg = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"YourScoreIs", @""), lastScore];
		alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LevelCompleted", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"TryAgain", @"") otherButtonTitles:NSLocalizedString(@"Continue", @""), NSLocalizedString(@"ShareScore", @""), nil];
	}

	[alertView show];
	[alertView release];
	
	[self unschedule:@selector(gameCompleted)];
	
	[AudioEngine stopMusic];
	
	state = ENDED;
}

- (void)updateLives:(int)someLives {
	lives = someLives;
	if (lives == 0) {
		[[CCDirector sharedDirector] pause];
		
		if (stage == 1 && tutorialStage > kTutStage2 && tutorialStage < kTutStage3) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameOver", @"") message:NSLocalizedString(@"TutorialText10", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];			
		} else if (stage == 1 && tutorialStage > kTutStage3) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameOver", @"") message:NSLocalizedString(@"TutorialText15", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];			
		} else {
			UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameOver", @"") message:NSLocalizedString(@"Defeated", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"") otherButtonTitles:NSLocalizedString(@"TryAgain", @""), nil];
			[alertView show];
			[alertView release];
		}
		
		[world stopAnimations];

		state = ENDED;
	}
}

- (void)hideCombo {
	comboLabel.visible = NO;
	[self unschedule:@selector(hideCombo)];
}

- (void)hideMessage {
	messageLabel.visible = NO;
	[self unschedule:@selector(hideMessage)];
}

- (void)showMessage:(NSString *)text {
	[messageLabel setString:text];
	messageLabel.visible = YES;
	lastMessage = text;
	
	[self unschedule:@selector(hideMessage)];
	[self schedule:@selector(hideMessage) interval:1.5];
}

- (void)showCombo:(int)comboValue {
	[comboLabel stopAllActions];
	[comboLabel setString:[NSString stringWithFormat:@"x%d", comboValue]];
	comboLabel.scaleX = 1/3.0;
	comboLabel.scaleY = 1/3.0;
	[comboLabel runAction:[CCScaleTo actionWithDuration:COMBO_SHOW_TIME scale:1]];

	comboLabel.visible = YES;
}

//- (void)score {
//	if (elapsed - lastHit < COMBO_TIME) {
//		// e.g: if normal point is 10 and I kill 2 enemies in a row I get: (10+10) * COMBO_MULTIPLIER
//		
//		[self unschedule:@selector(hideCombo)];
//
//		if (combo == 1)
//			score -= POINTS_PER_SCORE;
//		else
//			score -= COMBO_MULTIPLIER * combo * POINTS_PER_SCORE;
//
//		combo++;
//		
//		score += COMBO_MULTIPLIER * combo * POINTS_PER_SCORE;
//		
//		[self showCombo:combo];
//		[self schedule:@selector(hideCombo) interval:COMBO_SHOW_TIME];
//	} else {
//		combo = 1;
//		score += POINTS_PER_SCORE;
//	}
//	
//	lastHit = elapsed;
//}

- (void)energyAsRed {
	energyColor = violetRedColor;
}

- (void)energyAsNormal {
	[self unschedule:@selector(energyAsNormal)];

	energyColor = violetColor;
}

- (void)updateEnergy:(int)someEnergy {
	[energyLabel setString:[NSString stringWithFormat:@"%d", someEnergy]];
	
	energy = someEnergy;
	
	if (lastEnergy != 0 && lastEnergy > someEnergy) {
		energyConsuming = kConsumingEnergyTime;

		[self unschedule:@selector(energyAsNormal)];
		[self schedule:@selector(energyAsNormal) interval:kConsumingEnergyTime];
		
		[self energyAsRed];	
		
		consumedEnergy = lastEnergy - someEnergy;
	}
	
	lastEnergy = someEnergy;
}

- (void)setString:(CCLabelTTF *)label text:(NSString *)text {
	if ([label numberOfRunningActions] == 0 && ![label.string isEqualToString:text]) {
		label.opacity = 0;
		[label setString:text];
		CCFiniteTimeAction *fadein = [CCFadeIn actionWithDuration:1.0];
		[label runAction:fadein];
	}
	label.visible = YES;
}

- (void)tick:(ccTime)dt {
	if (energyConsuming > 0.0) {
		energyConsuming -= dt;
		energyConsuming = MAX(0, energyConsuming);		
	}
	
	if (sliding) {
		slidingVelocityY = slidingVelocityY < MAX_SLIDE_VELOCITY ? slidingVelocityY : MAX_SLIDE_VELOCITY;
		[self processDelta: slidingVelocityY * dt];		
	}

	hud.visible = [self isCompletelyInSecondArea] && state == PLANNING ? YES : NO;
	emitter.visible = !ltaDisabled && [self isCompletelyInSecondArea] && energy > 0 && state != PLANNING ? YES : NO;
	downButton.visible = YES;
	upButton.visible = YES;
	rushButton.visible = YES;
	//rushButton.visible = state == PLANNING ? YES : NO;
	
	if ([world.towers count] == 0 || [self isCompletelyInFirstArea]) {
		rushButtonOff.visible = YES;		
		rushButton.visible = NO;
	} else {
		rushButtonOff.visible = NO;		
		rushButton.visible = YES;		
	}
	
	if (energy < TURRET_COST) {
		[hud setOpaque];
	} else {
		[hud setNormal];
	}
	
	// TUTORIAL
	if (stage == 1 && state != RESTARTING) {
		tutMsg.visible = NO;
		tutMsg2.visible = NO;

		if (tutorialStage == kTutStage1) {
			Enemy *spider = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
			spider.row = 7;
			spider.col = 5;
			
			[world.addedEnemies removeAllObjects];
			[world.addedTowers removeAllObjects];
			[world cleanup];
			[world spawnEnemy:spider];
			[world prepareLevel:25];
			
			[self addHud:@"tc"];
			
			ltaDisabled = YES;
			powerupDisabled = YES;
			
			tutMsg2.position = ccp(self.contentSize.width/2 - 20, self.contentSize.height - 10);
			
			tutorialStage++;
		} else if (tutorialStage == kTutStage1 + 1) {			
			if ([self isCompletelyInFirstArea]) {
				tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 130);
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText1", @"")];
			} else if ([self isCompletelyInSecondArea]) {
				tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 150);
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText2", @"")];
				[self setString:tutMsg2 text:NSLocalizedString(@"TutorialText3", @"")];
			}
		} else if (tutorialStage == kTutStage1 + 2) {
			if ([self isCompletelyInSecondArea]) {
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText5", @"")];
			}
		} else if (tutorialStage == kTutStage1 + 3) {
			[self setString:tutMsg text:NSLocalizedString(@"TutorialText6", @"")];
		} else if (tutorialStage == kTutStage2) {			
			Enemy *spider = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
			spider.row = 8;
			spider.col = 1;

			Enemy *cater = [Enemy spriteWithFile:CATERPILLAR_FILE speed:CATERPILLAR_SPEED];
			cater.row = 8;
			cater.col = 8;			
			
			[world.addedEnemies removeAllObjects];
			[world.addedTowers removeAllObjects];
			[world cleanup];
			[world spawnEnemy:spider];
			[world spawnEnemy:cater];
			[world prepareLevel:50];
			
			[self addHud:@"tc,tt"];
			
			ltaDisabled = YES;
			powerupDisabled = YES;
			
			CCSprite *equiv = [CCSprite spriteWithFile:@"towers_vs_enemies.png"];
			equiv.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
			[self addChild:equiv z:10 tag:kEquivTag];
			
			[tutMsg retain];
			[self removeChild:tutMsg cleanup:NO];
			[self addChild:tutMsg z:11];
			[tutMsg release];
			
			tutorialStage++;
		} else if (tutorialStage == kTutStage2 + 1) {
			tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 95);
			NSString *text1 = [NSString stringWithFormat:NSLocalizedString(@"TutorialText8", @""), NSLocalizedString(@"Capacitor", @""), NSLocalizedString(@"Spider", @"")];
			NSString *text2 = [NSString stringWithFormat:NSLocalizedString(@"TutorialText8", @""), NSLocalizedString(@"Tank", @""), NSLocalizedString(@"Caterpillar", @"")];
			NSString *text3 = NSLocalizedString(@"TouchToContinue", @"");
			[self setString:tutMsg text:[NSString stringWithFormat:@"%@.\n%@.\n(%@)", text1, text2, text3]];			
		} else if (tutorialStage == kTutStage2 + 3) {
			tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 130);
			if ([self isCompletelyInSecondArea]) {
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText9", @"")];
			}
		} else if (tutorialStage == kTutStage3) {
			Enemy *spider = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
			spider.row = 9;
			spider.col = 4;
			
			Enemy *spider2 = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
			spider2.row = 3;
			spider2.col = 5;			
			
			[world.addedEnemies removeAllObjects];
			[world.addedTowers removeAllObjects];
			[world cleanup];
			[world spawnEnemy:spider];
			[world spawnEnemy:spider2];
			[world prepareLevel:45];
			
			[self addHud:@"tc,tt"];
			
			ltaDisabled = NO;
			powerupDisabled = YES;
			
			tutorialStage++;			
		} else if (tutorialStage == kTutStage3 + 1) {
			tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 130);
			if ([self isCompletelyInSecondArea]) {
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText12", @"")];
			}
		} else if (tutorialStage == kTutStage3 + 2) {
			if ([self isCompletelyInSecondArea]) {
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText13", @"")];
			}
		} else if (tutorialStage == kTutStage3 + 3) {
			tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 80);
			if ([self isCompletelyInSecondArea]) {
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText14", @"")];
				
				if ([self getChildByTag:kFingerTag] == nil) {
					CCSprite *finger = [CCSprite spriteWithFile:@"finger.png"];
					finger.position = ccp(self.contentSize.width/2, 20);
					[self addChild:finger z:10 tag:kFingerTag];
					
					CCMoveTo *move = [CCMoveTo actionWithDuration:0.8 position:ccp(finger.position.x, finger.position.y + 50)];
					CCScaleTo *scale = [CCScaleTo actionWithDuration:0.4 scale:1.3];
					CCMoveTo *restore = [CCMoveTo actionWithDuration:0.0 position:ccp(finger.position.x, finger.position.y)];
					CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.0 scale:1.0];
					[finger runAction:[CCRepeatForever actionWithAction:[CCSequence actions:move, scale, restore, scaleBack, nil]]];
				}				
			}
		} else if (tutorialStage == kTutStage4) {
			Enemy *spider = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
			spider.row = 9;
			spider.col = 5;
			
			Enemy *cater = [Enemy spriteWithFile:CATERPILLAR_FILE speed:CATERPILLAR_SPEED];
			cater.row = 3;
			cater.col = 5;			
			
			[world.addedEnemies removeAllObjects];
			[world.addedTowers removeAllObjects];
			[world cleanup];
			[world spawnEnemy:spider];
			[world spawnEnemy:cater];
			[world prepareLevel:45];
			
			[self addHud:@"tt"];
			
			ltaDisabled = YES;
			powerupDisabled = NO;
			
			tutorialStage++;			
		} else if (tutorialStage == kTutStage4 + 2) {
			tutMsg.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - 130);
			if ([self isCompletelyInSecondArea]) {
				[self setString:tutMsg text:NSLocalizedString(@"TutorialText17", @"")];
				
				if ([self getChildByTag:kFingerTag] == nil) {
					CCSprite *finger = [CCSprite spriteWithFile:@"finger.png"];
					finger.position = towerBeingApproachedPosition;
					[self addChild:finger z:10 tag:kFingerTag];
					
					CCScaleTo *scale = [CCScaleTo actionWithDuration:1.0 scale:1.3];
					CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.0 scale:1.0];
					[finger runAction:[CCRepeatForever actionWithAction:[CCSequence actions:scale, scaleBack, nil]]];
				}				
			}
		} 
	}
	
	if (state == DEFENDING) {
		offset = WORLD_HEIGHT/2;
		rushButtonOff.visible = NO;		
		[world tick:dt];
	} else {
		[world stopAnimations];
	}
}

- (void)enemyApproaching:(CGPoint)towerPosition {
	towerBeingApproachedPosition = ccp(towerPosition.x, towerPosition.y + offset);
	if (tutorialStage == kTutStage3 + 2) {
		state = PAUSED;
		tutorialStage++;
	} else if (tutorialStage == kTutStage4 + 1) {
		state = PAUSED;
		tutorialStage++;
	}
}


- (void)draw {	
	[super draw];

	if (touchedTower) {
		glLineWidth(1);
		glColor4ub(0, 100, 0, 0);
		ccDrawCircle(touchedTower.position, touchedTower.range * touchedTower.contentSize.width, 0, 30, 0);
	}
	
	int lineWidth = 4;
	int lineHeight = 12;
	int packSize = 5;
	
	int separatorAccum = 0;
	int bars = energy / LTA_COST;
	float lineStartY = self.contentSize.height - lineWidth/2;
	float lineEndY = lineStartY - lineHeight;

	int consumingBars = (int)((energyConsuming/kConsumingEnergyTime) * (consumedEnergy/LTA_COST));
	
	for (int i = 0; i < bars + consumingBars; i++) {
		glPointSize(lineWidth);
		glColor4f(energyColor.r/255.0, energyColor.g/255.0, energyColor.b/255.0, 1.0f);

		CGPoint origin;
		origin.x = self.contentSize.width - lineWidth - lineWidth*i - i - separatorAccum - 20;
		origin.y = lineStartY;
		CGPoint destination;
		destination.x = origin.x;
		destination.y = lineEndY;
		ccDrawPoint(ccp(origin.x, origin.y - lineWidth));
		ccDrawPoint(ccp(origin.x, origin.y - lineWidth*2));
		ccDrawPoint(ccp(origin.x, origin.y - lineWidth*3));
		
		if ((i+1) % packSize == 0 && i != 0) {
			glPointSize(1.0);
			glColor4f(0.5f, 0.5f, 0.5f, 1.0f);
			for (int j = 0; j < lineHeight; j++)
				ccDrawPoint(ccp(origin.x - 6, origin.y - 3 - j));
			separatorAccum += 6;
		}
	}
	
	allowedArea = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
	if (stage == 1 && state == PLANNING){
		if ([self isCompletelyInSecondArea] && tutorialStage == kTutStage1 + 1) {
			allowedArea = CGRectMake([world cellSize].width * 4, [world cellSize].height * 6, [world cellSize].width, [world cellSize].height);
			CGPoint vertices[4]={
				ccp(allowedArea.origin.x,allowedArea.origin.y),
				ccp(allowedArea.origin.x+allowedArea.size.width,allowedArea.origin.y),
				ccp(allowedArea.origin.x+allowedArea.size.width,allowedArea.origin.y+allowedArea.size.height),
				ccp(allowedArea.origin.x,allowedArea.origin.y+allowedArea.size.height),
			};
			glLineWidth(2.0);
			glColor4ub(150, 150, 0, 0);
			ccDrawPoly(vertices, 4, YES);
				
			glLineWidth(2.0);
			ccDrawLine(ccp(allowedArea.origin.x + allowedArea.size.width/2, allowedArea.origin.y), ccp(300, 65));
			
			//ccDrawLine(ccp(200, 436), ccp(265, 470));
			ccDrawLine(ccp(235, 470), ccp(265, 470));
			ccDrawLine(ccp(258, 465), ccp(265, 470));
			ccDrawLine(ccp(258, 475), ccp(265, 470));
		}
	}
}

- (void)processTouch:(NSSet *)touches  {	
	CGPoint touchLocation = [self getTouchLocation: touches];
	
	if ([touches count] == PAN_TOUCHES) {
//		if (panning) {
//			float delta = touchLocation.y - slidingLastTouchPositionY;
//			[self processDelta: delta];
//		}
//		
//		float deltaTouchTime = [slidingTouchTime calculateDeltaTouchTime];
//		slidingVelocityY = (touchLocation.y - slidingLastTouchPositionY)/deltaTouchTime;
//		slidingVelocityY /= 1.5;
//		
//		slidingLastTouchPositionY = touchLocation.y;
//		
//		panning = YES;
//		sliding = NO;
	}
	
	float deltaTouchTime = [shootingTouchTime calculateDeltaTouchTime];
	shootingVelocityY = (touchLocation.y - shootingLastTouchPositionY)/deltaTouchTime;
	shootingVelocityX = (touchLocation.x - shootingLastTouchPositionX)/deltaTouchTime;
	shootingVelocityY /= 1.5;
	shootingVelocityX /= 1.5;
	shootingVelocityY = MIN(MAX_LTA_SPEED, shootingVelocityY);
	shootingVelocityY = MAX(MIN_LTA_SPEED, shootingVelocityY);
	shootingVelocityX = MIN(MAX_LTA_SPEED, shootingVelocityX);
	shootingLastTouchPositionY = touchLocation.y;
	shootingLastTouchPositionX = touchLocation.x;	
}

- (BOOL)towerInRecyclePosition:(Tower *)tower {
	return tower.position.y < [world cellSize].height * 2;
}

- (void)colorTouchedTower {
	Tower *tower = [world towerAtLocation:ccp(touchedTower.position.x, touchedTower.position.y - offset)];
	if (tower == nil) {
		if ([self towerInRecyclePosition:touchedTower]) {
			if (movingTower)
				[self showMessage:NSLocalizedString(@"Sell", @"")];
			touchedTower.color = redColor;			
		} else {
			if ([lastMessage isEqualToString:NSLocalizedString(@"Sell", @"")])
				[self hideMessage];
			touchedTower.color = realColor;
		}
	} else {
		touchedTower.color = redColor;
	}
}

- (void)shoot:(CGPoint)location {
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter.position = ccp(size.width/2 - 3, SHOOT_OFFSET);

	readyToShoot = NO;
	
	if (tutorialStage == kTutStage3 + 2) // waiting for pause to explain how to shoot the lta
		return;
	
	if (!ltaDisabled && [world.bullets count] < MAX_LTA_AMOUNT && [world consumeEnergy:LTA_COST]) {
		vector shootDir;
		shootDir.x = location.x;
		shootDir.y = location.y - offset;
		shootDir.vx = shootingVelocityX;
		shootDir.vy = shootingVelocityY;
		shootDir.ttl = 0;
		[world addShoot:shootDir];
		
		if (tutorialStage == kTutStage3 + 3) {
			state = DEFENDING;
			[self removeChildByTag:kFingerTag cleanup:YES];
			tutorialStage++;
		}
	}
	
	[shootingTouchTime reset];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchLocation = [self getTouchLocation: touches];

	NSString *buttonName = nil;
	if (energy >= TURRET_COST) {
		buttonName = [hud tryTouch:touchLocation];
	}
	
#ifdef CF_DEBUG
	[configButton tryTouch:touchLocation];
#endif

	[pauseButton tryTouch:touchLocation];

	if ([self isCompletelyInFirstArea]) {
		BOOL rushStatus = state == PLANNING && rushButton.visible ? [rushButton tryTouch:touchLocation] : NO;
		BOOL downStatus = [downButton tryTouch:touchLocation];
		if (!rushStatus && !downStatus) {
			if (unlocked) {
				Enemy *worldEnemy = [world enemyAtLocation:ccp(touchLocation.x, touchLocation.y - offset)];
				if (worldEnemy != nil) {
					addingEnemy = worldEnemy;
					[addingEnemy retain];
					
					addingEnemy.opacity = ADDING_TOWER_OPACITY;
					addingEnemy.position = ccp(addingEnemy.position.x, addingEnemy.position.y + offset);
					[world removeEnemy:addingEnemy];
					
					[self addChild:addingEnemy];			
					[addingEnemy release];
				} else {
					if (touchLocation.x < self.contentSize.width * 0.33)
						addingEnemy = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
					else if (touchLocation.x < self.contentSize.width * 0.66)
						addingEnemy = [Enemy spriteWithFile:CHIP_FILE speed:CHIP_SPEED];
					else
						addingEnemy = [Enemy spriteWithFile:CATERPILLAR_FILE speed:CATERPILLAR_SPEED];					
					addingEnemy.opacity = ADDING_TOWER_OPACITY;
					addingEnemy.position = [world worldToGrid:touchLocation];
					
					[self addChild:addingEnemy];				
				}
			}		
		}
	} else if ([self isCompletelyInSecondArea]) {
		if (state == PLANNING)
			[rushButton tryTouch:touchLocation];
		
		[upButton tryTouch:touchLocation];
		if (state == PLANNING) {
			if (buttonName != nil) {
				touchedTower = [Tower towerWithFile:buttonName];
				touchedTower.opacity = ADDING_TOWER_OPACITY;
				touchedTower.position = [world worldToGrid:touchLocation];
				[self colorTouchedTower];
				
				[self addChild:touchedTower];				
			} else if (touchedTower == nil && [touches count] == 1 && (stage > 1 || tutorialStage >= kTutStage2)) {
				Tower *worldTower = [world towerAtLocation:ccp(touchLocation.x, touchLocation.y - offset)];
				if (worldTower != nil) {
					touchedTower = worldTower;
					[touchedTower retain];
					
					touchedTowerOriginalPosition = touchedTower.position;
					touchedTower.opacity = ADDING_TOWER_OPACITY;
					touchedTower.position = [world worldToGrid:ccp(touchedTower.position.x, touchedTower.position.y + offset)];
					[world removeTower:touchedTower];
					
					[self addChild:touchedTower];			
					[touchedTower release];
					
					movingTower = YES;
				}		
			}			
		} else if (state == DEFENDING || state == PAUSED) {
			CGRect emitterArea;
			CGSize emitterSize;
			emitterSize.width = emitter.contentSize.width + 70;
			emitterSize.height = emitter.contentSize.height + 70;
			emitterArea.size = emitterSize;
			emitterArea.origin = ccp(emitter.position.x - emitterSize.width/2, emitter.position.y - emitterSize.height/2);
			
			if (CGRectContainsPoint(emitterArea, touchLocation)) {
				readyToShoot = YES;
			} else {
				readyToShoot = NO;
			}
			
			touchedTower = [world towerAtLocation:ccp(touchLocation.x, touchLocation.y - offset)];
			if (touchedTower && [touchedTower.filename isEqualToString:BOMB_TOWER])
				bombTower = touchedTower;
			else
				bombTower = nil;
		}
	}	
	
	[self processTouch:touches];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self processTouch:touches];
	
	if (readyToShoot) {
		CGPoint touchLocation = [self getTouchLocation: touches];
		if (touchLocation.y < [world cellSize].height * 4) {
			//emitter.position = touchLocation;
		} else {
			CGPoint location = [self getTouchLocation: touches];
			[self shoot:location];
		}
	}
	
	if (state == DEFENDING || state == PAUSED)
		return;
	
	if ([touches count] == 2 && touchedTower) {
		[self removeChild:touchedTower cleanup:NO];
		touchedTower = nil;
	}
	
	if (touchedTower) {
		CGPoint touchLocation = [self getTouchLocation: touches];
		touchedTower.position = [world worldToGrid:touchLocation];
		[self colorTouchedTower];
	}
	
	if (addingEnemy) {
		CGPoint touchLocation = [self getTouchLocation: touches];
		addingEnemy.position = [world worldToGrid:touchLocation];
	}
}

- (void)moveTouchedTowerToWorld:(CGPoint)at {
	[touchedTower retain];
	[self removeChild:touchedTower cleanup:NO];
	
	touchedTower.opacity = 255;
	touchedTower.color = realColor;
	touchedTower.position = at;
	
	[world addTower:touchedTower];
	
	[touchedTower release];
	
	if (stage == 1 && tutorialStage == kTutStage1 + 1) {
		tutorialStage++;
	}
}

- (void)removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
	[super removeChild:node cleanup:cleanup];
	
	touchedTowerOriginalPosition.x = 0;
	touchedTowerOriginalPosition.y = 0;
}

- (void)restoreTouchedTower {
	[self moveTouchedTowerToWorld:touchedTowerOriginalPosition];
	touchedTowerOriginalPosition.x = 0;
	touchedTowerOriginalPosition.y = 0;	
}

- (void)startDefending {
	[self hideButtons];
	
	[world startDefending];

	state = DEFENDING;
	
	if (touchedTower && touchedTowerOriginalPosition.x != 0 && touchedTowerOriginalPosition.y != 0) { // moving
		[self restoreTouchedTower];
	} else { // adding
		[self removeChild:touchedTower cleanup:NO];
	}
	
	touchedTower = nil;
	
	[self unschedule:@selector(startDefending)];
	
	[AudioEngine playAttackMusic];
	
	if (stage == 1 && (tutorialStage == kTutStage1 + 2 || tutorialStage == kTutStage3 + 1)) {
		tutorialStage++;
	}
}

- (void)performSharing {
	[self unschedule:@selector(performSharing)];
	
	SHKItem *item = [SHKItem text:[NSString stringWithFormat:NSLocalizedString(@"ShareMsg", @""), lastScore, stage - 1]];
	
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	UIViewController *tempVC=[[UIViewController alloc] init];
	
	[[[CCDirector sharedDirector] openGLView] addSubview:tempVC.view];
	
	[[SHK currentHelper] setRootViewController:tempVC];
	
	[actionSheet showInView:[CCDirector sharedDirector].openGLView];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (state == RESTARTING) {
		[self restart];
	} else if (state == ENDED) {
		if (lives > 0) { // LEVEL PASSED
			if (buttonIndex == 0) {
				[self restart];
			} else if (buttonIndex == 1){
				[world cleanup];
				[[CCDirector sharedDirector] popScene];
				[[MenuScene sharedInstance] showLevels];
			} else {
				[self restart];

				[self schedule:@selector(performSharing) interval:1.0];
			}
			
			if (isLastLevel) {
				NSString *endMessage;
#ifdef LITE_VER
				endMessage = NSLocalizedString(@"LiteMsg", @"");
#else
				endMessage = NSLocalizedString(@"EndMsg", @"");
#endif
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"") message:endMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				isLastLevel = NO;				
				newArt = NO;
			} else if (newArt) {
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"") message:NSLocalizedString(@"NewArt", @"") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				isLastLevel = NO;				
				newArt = NO;
			}
		} else { // DEFEATED
			if (buttonIndex == 0 && stage != 1) {
				[world cleanup];
				[[CCDirector sharedDirector] popScene];
				[[MenuScene sharedInstance] showLevels];
			} else {
				[self restart];
			}			
		}
	} else {
		if (buttonIndex == 0) {
			[world cleanup];
			[[CCDirector sharedDirector] popScene];
			[[MenuScene sharedInstance] showLevels];
		} else {		
			[[CCDirector sharedDirector] resume];
		}		
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchLocation = [self getTouchLocation:touches];

	if (stage == 1 && tutorialStage == kTutStage2 + 1) {
		[self removeChildByTag:kEquivTag cleanup:YES];
		tutorialStage++;
	}
	
#ifdef CF_DEBUG
	if ([configButton touchEnded:touchLocation]) {
		[[CCDirector sharedDirector] pause];
		[[[CCDirector sharedDirector] openGLView] addSubview:config.view];		
	}
#endif

	if ([rushButton touchEnded:touchLocation] && [rushButton numberOfRunningActions] == 0) {
		[self startDefending];
		sliding = YES;
		slidingVelocityY = MAX_SLIDE_VELOCITY;
		
		return;
	}	

	if ([pauseButton touchEnded:touchLocation]) {
		[[CCDirector sharedDirector] pause];
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Cellfense" message:NSLocalizedString(@"Paused", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"") otherButtonTitles:NSLocalizedString(@"Continue", @""), nil];
		[alertView show];
		[alertView release];		
		return;
	}
	
	BOOL downButtonResult = downButton.visible && [downButton touchEnded:touchLocation];
	BOOL upButtonResult = upButton.visible && [upButton touchEnded:touchLocation];
	
	if (energy >= TURRET_COST) {
		[hud tryTouch:touchLocation];
	}
	
	if (!powerupDisabled && (state == DEFENDING || state == PAUSED) && touchedTower) {
		Tower *candTower = [world towerAtLocation:ccp(touchLocation.x, touchLocation.y - offset)];
		if (candTower == touchedTower) {
			if (candTower == bombTower) {
				[world explode:candTower];				
			} else if (![candTower isCrazy] && [world consumeEnergy:POWERUP_COST]) {
				[candTower goCrazy];

				if (stage == 1 && tutorialStage == kTutStage4 + 2) {
					state = DEFENDING;
					[self removeChildByTag:kFingerTag cleanup:YES];
					tutorialStage++;
				}
			}
		}
	}
	
	if (downButtonResult) {
		sliding = YES;
		slidingVelocityY = MAX_SLIDE_VELOCITY;
		[tutMsg stopAllActions];
		[tutMsg2 stopAllActions];
	} else if (upButtonResult) {
		sliding = YES;
		slidingVelocityY = -MAX_SLIDE_VELOCITY;		
		[tutMsg stopAllActions];
		[tutMsg2 stopAllActions];
	} else {		
		if (panning) {	
			panning = NO;
			sliding = YES;
			
			[slidingTouchTime reset];
		} else if(touchedTower) {
			if ([self towerInRecyclePosition:touchedTower]) {
				if (movingTower) {
					[world consumeEnergy:-touchedTower.cost]; // recycle it

					if ([lastMessage isEqualToString:NSLocalizedString(@"Sell", @"")])
						[self hideMessage];
				}
				
				[self removeChild:touchedTower cleanup:NO];
			} else {
				CGPoint touchedTowerPosition = ccp(touchedTower.position.x, touchedTower.position.y - offset);
				Tower *existingTower = [world towerAtLocation:touchedTowerPosition];
				BOOL touchedTowerInSecondScreen = touchedTower.position.y - offset < 0;
				BOOL blocking = [world doesBlockPathIfAddedTo:touchedTowerPosition];
				if (blocking) {
					[self showMessage:NSLocalizedString(@"Blocking", @"")];
				}
				
				BOOL inAllowedArea = CGRectContainsPoint(allowedArea, touchedTower.position);
				if (!inAllowedArea) {
					UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"TutorialText4", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alertView show];
					[alertView release];					
				}
				
				if (existingTower == nil && touchedTowerInSecondScreen && !blocking && inAllowedArea) {
					if (movingTower || [world consumeEnergy:touchedTower.cost]) {
						[self moveTouchedTowerToWorld:ccp(touchedTower.position.x, touchedTower.position.y - offset)];
						if (!movingTower && tutorialStage == kTutStage2 + 2) {
							tutorialStage++;
						}
					} else {
						[self removeChild:touchedTower cleanup:NO];
					}
				} else if (touchedTowerOriginalPosition.x != 0 && touchedTowerOriginalPosition.y != 0) {
					[self restoreTouchedTower];
				} else { // adding
					[self removeChild:touchedTower cleanup:NO];
				}				
			}
			
			touchedTower = nil;
		} else if (addingEnemy) {
			if (addingEnemy.position.x != 0) {
				addingEnemy.opacity = 255;
				
				[addingEnemy retain];
				[self removeChild:addingEnemy cleanup:NO];
				
				if (addingEnemy.position.y < self.contentSize.height)
					[world addEnemy:addingEnemy];
				
				[addingEnemy release];
			} else {
				[self removeChild:addingEnemy cleanup:NO];				
			}
			addingEnemy = nil;				
		}
		
		if (readyToShoot) {
			CGPoint location = [self getTouchLocation: touches];
			[self shoot:location];
		}	
	}
	
	movingTower = NO;
}

- (void)dealloc {
	[hud release];
	[costsByTower release];
	[config release];
	
	[slidingTouchTime release];
	[shootingTouchTime release];
	
	[super dealloc];
}
	
@end