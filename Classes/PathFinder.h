//
//  PathFinder.h
//  Cellfense
//
//  Created by Lucho on 7/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TILE_OPEN 0
#define TILE_WALL 1

/**
 * A* Artificial Intelligence Path Finder
 */
@interface PathFinder : NSObject {
	NSArray *walls;
	
	int rows;
	int cols;
}

/**
 * Initializer that configures the grid as well as receiving and array of wall coordinates
 */
- (id)initWithRows:(int)nRows columns:(int)nCols walls:(NSArray *)walls;

/**
 * Returns an array of PathFindNode or nil if no path was found
 */
- (NSArray *)findPathRow:(int)startY Col:(int)startX toRow:(int)endY toCol:(int)endX;

@end

@interface PathFindNode : NSObject {
@public
	int nodeX,nodeY;
	int cost;
	PathFindNode *parentNode;
}
+(id)node;
@end