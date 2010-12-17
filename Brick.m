// 
//  Brick.m
//  bible-memory-ipad
//
//  Created by Geoffrey Hom on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Brick.h"
#import "Passage.h"

@implementation Brick 

@dynamic passage, startingIndex;

// Return the ending index for this brick.
- (NSUInteger)endingIndex {
	return [self.passage endingIndexOfBrick:self];
}

// Return the length of the brick's text.
- (NSUInteger)length {
	return [self.passage lengthOfBrick:self];
}

@end