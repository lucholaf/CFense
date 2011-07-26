//
//  LevelsController.h
//  FanCard
//
//  Created by Lucho on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelsScrollView : UIScrollView {
	id listener;
}

@property(assign) id listener;

@end

@interface LevelsController : UIViewController {
	NSMutableDictionary *levelByImage;
	NSMutableArray *levels;
	
	BOOL unlocked;
	
	id target;
}

@property BOOL unlocked;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil unlocked:(BOOL)unlocked target:(id)aTarget;

@end
