//
//  Save.m
//  Cellfense
//
//  Created by Luis Floreani on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Save.h"

static Save *sharedInstance = nil;

@implementation Save

+ (Save *)sharedInstance {
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [[Save alloc] init];
		}
	}
	
	return sharedInstance;
}

@end
