//
//  LevelView.m
//  FanCard
//
//  Created by Lucho on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LevelView.h"


@implementation LevelView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touched view");
}

- (void)dealloc {
    [super dealloc];
}


@end
