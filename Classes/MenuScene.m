//
//  MenuScene.m
//  Cellfense
//
//  Created by Luis Floreani on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"
#import "Constants.h"
#import "LevelsController.h"
#import "AudioEngine.h"
#import "SeqLayer.h"
#import "Scores.h"

#define kSplashTag 2123
#define kMenuLayer 6576556

static MenuScene *sharedInstance = nil;

@implementation MenuScene

+ (MenuScene *)sharedInstance {
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [[MenuScene node] retain];
		}
	}
	
	return sharedInstance;
}

- (id)init {
	if ((self = [super init])) {
		srand(time(NULL));

        CCSprite *bg = [CCSprite spriteWithFile:@"Default.png"];
		CGSize size = [[CCDirector sharedDirector] winSize];
        [bg setPosition:ccp(size.width/2, size.height/2)];
		[self addChild:bg z:0 tag:kSplashTag];
		
		[self schedule:@selector(initGame) interval:0.5];
		
		[AudioEngine preload];
	}
	
	return self;
}

- (void)initGame {
	[self unschedule:@selector(initGame)];
	[self removeChildByTag:kSplashTag cleanup:YES];
	
	CCSprite *bg = [CCSprite spriteWithFile:@"menu.png"];
	[bg.texture setAliasTexParameters];
	CGSize size = [[CCDirector sharedDirector] winSize];
	[bg setPosition:ccp(size.width/2, size.height/2)];
	[self addChild:bg z:0];

	[self addChild:[MenuLayer node] z:1 tag:kMenuLayer];
}

- (void)showLevels {
	[[self getChildByTag:kMenuLayer] performSelector:@selector(showLevels)];
}

- (void)showMenu {
	[[self getChildByTag:kMenuLayer] performSelector:@selector(showMenu)];
}

@end

@implementation MenuLayer

- (void)loadMenu {
	[self removeChildByTag:100 cleanup:NO];
	[self removeChildByTag:101 cleanup:NO];
	[self removeChildByTag:102 cleanup:NO];
	
	[CCMenuItemFont setFontSize:FONT_SIZE];
	[CCMenuItemFont setFontName:@"ArialRoundedMTBold"];
	CCMenuItem *new = [CCMenuItemFont itemFromString:NSLocalizedString(@"NewGame", @"")];
	new.position = ccp(0, 70 - 1);
	CCMenuItemImage *newImage = [CCMenuItemImage itemFromNormalImage:@"menu_button.png" selectedImage:@"menu_button_selected.png" target:self selector:@selector(showLevels)];
	newImage.position = ccp(0, 70);
	
	BOOL thereIsArt = [[[Scores sharedInstance] unlockedArt] count] > 0;
	CCMenuItem *art = nil;
	CCMenuItemImage *artImage;
	int buttonOffsets = 46;
	if (thereIsArt) {
		art = [CCMenuItemFont itemFromString:NSLocalizedString(@"UnlockedArt", @"")];
		art.position = ccp(0, 24 - 1);
		artImage = [CCMenuItemImage itemFromNormalImage:@"menu_button.png" selectedImage:@"menu_button_selected.png" target:self selector:@selector(unlockedArt)];
		artImage.position = ccp(0, 24);
		buttonOffsets = 0;
	}
	
	CCMenuItem *options = [CCMenuItemFont itemFromString:NSLocalizedString(@"Options", @"")];
	options.position = ccp(0, -22 + buttonOffsets - 1);
	CCMenuItemImage *optionsImage = [CCMenuItemImage itemFromNormalImage:@"menu_button.png" selectedImage:@"menu_button_selected.png" target:self selector:@selector(options)];
	optionsImage.position = ccp(0, -22 + buttonOffsets);
	
	CCMenuItem *about = [CCMenuItemFont itemFromString:NSLocalizedString(@"About", @"")];
	about.position = ccp(0, -68 + buttonOffsets - 1);
	CCMenuItemImage *aboutImage = [CCMenuItemImage itemFromNormalImage:@"menu_button.png" selectedImage:@"menu_button_selected.png" target:self selector:@selector(about)];
	aboutImage.position = ccp(0, -68 + buttonOffsets);
	
	if (thereIsArt)
		menu = [CCMenu menuWithItems:newImage, new, artImage, art, optionsImage, options, aboutImage, about, nil];
	else
		menu = [CCMenu menuWithItems:newImage, new, optionsImage, options, aboutImage, about, nil];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp(size.width/2, 220)];
	[self addChild:menu z:1 tag:100];
	
	CCSprite *topMenu = [CCSprite spriteWithFile:@"menu_top.png"];
	topMenu.position = ccp(self.contentSize.width/2, 325);
	[self addChild:topMenu z:1 tag:101];
	
	CCSprite *downMenu = [CCSprite spriteWithFile:@"menu_bottom.png"];
	downMenu.position = ccp(self.contentSize.width/2, 100 + buttonOffsets);
	[self addChild:downMenu z:1 tag:102];	
}

- (id)init {
    if ((self = [super init])) {
		self.isTouchEnabled = YES;
		
		levelController = [[LevelsController alloc] initWithNibName:@"LevelsController" bundle:nil unlocked:NO target:self];
		aboutController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil target:self];
		optionsController = [[OptionsViewController alloc] initWithNibName:@"OptionsViewController" bundle:nil target:self];
		
		[self loadMenu];
			
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		if ([settings objectForKey:@"cfaudio"] == nil)
			[settings setObject:@"0.9" forKey:@"cfaudio"];
		if ([settings objectForKey:@"cfmusic"] == nil)
			[settings setObject:@"0.6" forKey:@"cfmusic"];
		
		[settings synchronize];

		[AudioEngine updateVolumes];
    }
    
    return self;
}

- (void)applyVisibleMaskToAll:(BOOL)mask {
	for (CCNode *node in [self children]) {
		node.visible = mask;
	}
}

- (void)unlockedArt {
	cheatCounter = 0;
	resetCounter = 0;

	[self applyVisibleMaskToAll:NO];
	
	NSArray *unlockedArt = [[Scores sharedInstance] unlockedArt];
	SeqLayer *tut = [[[SeqLayer alloc] initWithScreens:unlockedArt] autorelease];
	[self addChild:tut];
}

- (void)options {
	resetCounter = 0;
	cheatCounter++;
	
	[self applyVisibleMaskToAll:NO];
	
	[[CCDirector sharedDirector] pause];
	[[[CCDirector sharedDirector] openGLView] addSubview:optionsController.view];	
}

- (void)about {
	resetCounter++;
	cheatCounter = 0;
	
	if (resetCounter == 3) {
		[[Scores sharedInstance] resetScores];
	}
	
	[self applyVisibleMaskToAll:NO];
	
	[[CCDirector sharedDirector] pause];
	[[[CCDirector sharedDirector] openGLView] addSubview:aboutController.view];	
}

- (void)showMenu {
	[[CCDirector sharedDirector] purgeCachedData];

	[self loadMenu];
	[self applyVisibleMaskToAll:YES];
}

- (void)showLevels {
	if (cheatCounter == 3) {
		levelController.unlocked = YES;	
		[[Scores sharedInstance] fillScores];		
	}

	cheatCounter = 0;
	resetCounter = 0;

	[self applyVisibleMaskToAll:NO];
	
	[[CCDirector sharedDirector] pause];
	[[[CCDirector sharedDirector] openGLView] addSubview:levelController.view];
}

- (void)dealloc {
	[levelController release];
	[aboutController release];
	[optionsController release];
	
	[super dealloc];
}

@end
