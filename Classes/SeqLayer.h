//
//  SeqLayer.h
//  Cellfense
//
//  Created by Luis Floreani on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeqLayer.h"
#import "cocos2d.h"

@interface SeqLayer : CCLayer {
	NSArray *screens;
	
	int progress;
	
	CCLabelTTF *touchLabel;
}

- (id)initWithScreens:(NSArray *)screens;

@end
