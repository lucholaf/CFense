//
//  LevelsController.m
//  FanCard
//
//  Created by Lucho on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LevelsController.h"
#import "LevelView.h"
#import "Level.h"
#import "GameScene.h"
#import "GDataXMLNode.h"
#import "Constants.h"
#import "Scores.h"
#import "AudioEngine.h"

#define kUnlockedLevels 2
#define kScoreLabelTag 1000

@interface UIImageView(copy)<NSCopying>
@end

@implementation UIImageView(copy)

- (id)copyWithZone:(NSZone *) zone {
	return self;
}

@end

@implementation LevelsScrollView

@synthesize listener;

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	if (!self.dragging) {
		if (listener) {
			[listener performSelector:@selector(imageSelected:) withObject:(UIImageView *)view];
		}
	}
	
	return NO;
}

@end


@implementation LevelsController

@synthesize unlocked;

- (NSString *)dataFilePath:(BOOL)forSave {
    return [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"xml"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil unlocked:(BOOL)isUnlocked target:(id)aTarget {
	unlocked = isUnlocked;
	target = aTarget;
	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		levelByImage = [[NSMutableDictionary dictionary] retain];
		levels = [[NSMutableArray array] retain];
		
		NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:[self dataFilePath:FALSE]];
		NSError *error;
		GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
															   options:0 error:&error];
		if (doc == nil) { 
			NSLog(@"Cellfense: could not read XML");
		}
		
		NSArray *levelElements = [doc.rootElement elementsForName:@"string-array"];
		for (GDataXMLElement *levelElement in levelElements) {
			NSArray *itemElements = [levelElement elementsForName:@"item"];
			
			GDataXMLNode *resourceAttrib = [levelElement attributeForName:@"resource"];
			GDataXMLNode *nameAttrib = [levelElement attributeForName:@"name"];
			GDataXMLNode *towersAttrib = [levelElement attributeForName:@"towers"];

			Level *level = [Level levelFromFilename:@"button1.png"];
			level.resource = [resourceAttrib.stringValue intValue];
			level.towersString = towersAttrib.stringValue;
			level.name = nameAttrib.stringValue;
			level.number = [levels count] + 1;

			int i = 0;
			for (GDataXMLElement *itemElement in itemElements) {
				int index = i % 3;
				
				Enemy *enemy;
				if (index == 0) {
					if ([itemElement.stringValue isEqualToString:@"spider"]) 
						enemy = [Enemy spriteWithFile:SPIDER_FILE speed:SPIDER_SPEED];
					else if ([itemElement.stringValue isEqualToString:@"caterpillar"]) 
						enemy = [Enemy spriteWithFile:CATERPILLAR_FILE speed:CATERPILLAR_SPEED];
					else if ([itemElement.stringValue isEqualToString:@"chip"]) 
						enemy = [Enemy spriteWithFile:CHIP_FILE speed:CHIP_SPEED];
					else
						NSLog(@"ENEMY NOT FOUND: %@", itemElement.stringValue);
				}

				switch (index) {
					case 1:
						enemy.col = [itemElement.stringValue intValue];
						break;
					case 2:
						enemy.row = [itemElement.stringValue intValue];
						break;
					default:
						break;
				}
				
				if (index == 2) {
					[level addEnemy:enemy];
				}
				
				i++;
			}
			
			[levels addObject:level];
		}
		
		[[Scores sharedInstance] setLevels:levels];
		
		[doc release];
		[xmlData release];		
    }
    return self;
}

- (void)backButtonClick {
	[self.view removeFromSuperview];	
	[target performSelector:@selector(showMenu)];
}

- (void)addScore:(LevelView *)imageView index:(int)index {
	int score = [[Scores sharedInstance] scoreAtIndex:index];
	NSString *scoreStr;
	if (score == 0) {
		scoreStr = @"-";
	} else {
		scoreStr = [NSString stringWithFormat:@"%d", score];
	}
	
	if (index == 0) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16]; // TSERIES
		label.textAlignment = UITextAlignmentCenter;
		label.text = NSLocalizedString(@"Tutorial", @"");
		
		[imageView addSubview:label];
	} else {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:46]; // TSERIES
		label.textAlignment = UITextAlignmentCenter;
		label.text = [NSString stringWithFormat:@"%d", index];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, imageView.frame.size.width, 16)];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.font = [UIFont fontWithName:@"Arial" size:16];
		nameLabel.textAlignment = UITextAlignmentCenter;
		Level *level = [levels objectAtIndex:index];
		nameLabel.text = level.name;			
		
		UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, imageView.frame.size.width, 16)];
		scoreLabel.backgroundColor = [UIColor clearColor];
		scoreLabel.textColor = [UIColor whiteColor];
		scoreLabel.font = [UIFont fontWithName:@"Arial" size:14];
		scoreLabel.textAlignment = UITextAlignmentCenter;
		scoreLabel.tag = kScoreLabelTag;
		scoreLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Score", @""),scoreStr];
		
		[imageView addSubview:nameLabel];
		[imageView addSubview:label];
		[imageView addSubview:scoreLabel];
	}
	
	[imageView setUserInteractionEnabled:YES];	
}

- (void)viewWillAppear:(BOOL)animated {
	LevelsScrollView *scrollView = (LevelsScrollView *)[self.view viewWithTag:99];
	int i = 0;
	int lockCount = 0;
	for (UIView *view in [scrollView subviews]) {
		int value = [[Scores sharedInstance] scoreAtIndex:i];
		
		if (value == 0) {
			lockCount++;
		}
		
		if ([[view subviews] count] == 1) { // means it's locked
			BOOL tutorialDone = [[Scores sharedInstance] scoreAtIndex:0] > 0;
			
			if ((i == 1 && !tutorialDone)) {
				continue;
			}	
			
			if (value != 0 || lockCount <= kUnlockedLevels || unlocked) {
				[[[view subviews] objectAtIndex:0] removeFromSuperview]; // clean lock
				[self addScore:(LevelView *)view index:i];
			}
		} else if (value != 0) { // upgrade score
			UILabel *scoreLabel = (UILabel *)[view viewWithTag:kScoreLabelTag];
			scoreLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Score", @""), value];
		}
		i++;
	}
	
	[AudioEngine stopMusic];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIView *headerView = [self.view viewWithTag:100];
	[self.view bringSubviewToFront:headerView];

	UIImage *image = [UIImage imageNamed:@"back_button.png"];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
	backButton.frame = CGRectMake(0, 16, 40, 40);
	[backButton setBackgroundImage:image forState:UIControlStateNormal];
	[self.view addSubview:backButton];
	
	LevelsScrollView *scrollView = (LevelsScrollView *)[self.view viewWithTag:99];
	scrollView.listener = self;
	
	int imagesPerRow = 3;
	int itemWidth = 100;
	int itemHeight = 100;
	int startMargin = 5;
	int margin = 5;
	
	int lockCount = 0;
	int totalLevels;
	totalLevels = [levels count];
	for (int i = 0; i < totalLevels; i++) {
		int col = i % imagesPerRow;
		int row = i/imagesPerRow;
		
		Level *level = [levels objectAtIndex:i];
		LevelView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(startMargin + col*itemWidth + col*margin, startMargin + row*itemHeight + row*margin, itemWidth, itemHeight)] autorelease];
		imageView.image = level.image;
		
		int value = [[Scores sharedInstance] scoreAtIndex:i];
		if (value == 0) {
			lockCount++;
		}
		
		BOOL tutorialDone = [[Scores sharedInstance] scoreAtIndex:0] > 0;
		
		if ((i == 1 && !tutorialDone) || (lockCount > kUnlockedLevels && !unlocked)) {
			UIImage *lock = [UIImage imageNamed:@"lock.png"];
			UIImageView *lockView = [[[UIImageView alloc] initWithFrame:CGRectMake(imageView.frame.size.width/2 - lock.size.width/2, imageView.frame.size.height/2 - lock.size.height/2, lock.size.width, lock.size.height)] autorelease];
			lockView.image = lock;
			[imageView addSubview:lockView];
			[imageView setUserInteractionEnabled:NO];
		} else {
			[self addScore:imageView index:i];
		}
		
		[levelByImage setObject:level forKey:imageView];

		[scrollView addSubview:imageView];
	}
	
	int rows = ceil(totalLevels / (float)imagesPerRow);
	
	[scrollView setContentSize:CGSizeMake(self.view.frame.size.width, startMargin + rows*itemHeight + rows*margin)];
}

- (void)goGame:(UIImageView *)imageView {
	[self.view removeFromSuperview];	

	Level *level = [levelByImage objectForKey:imageView];
	GameScene *gs = [GameScene nodeWithLevel:level unlocked:unlocked];

	[[CCDirector sharedDirector] pushScene:gs];
    [[CCDirector sharedDirector] resume];
}

- (void)imageSelected:(UIImageView *)imageView {
	[self performSelector:@selector(goGame:) withObject:imageView afterDelay:0.15];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[levelByImage release];
	[levels release];
	
    [super dealloc];
}


@end
