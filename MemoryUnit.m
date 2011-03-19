/*
 File: MemoryUnit.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import "MemoryUnit.h"
#import "Passage.h"

@implementation MemoryUnit 

@dynamic passage, startingIndex_;

- (NSUInteger)endingIndex {
	//return [self.passage endingIndexOfMemoryUnit:self];


// Return the ending index of the given brick's text.
//- (NSUInteger)endingIndexOfBrick:(MemoryUnit *)theBrick {
	
	// Get memory unit's rank.
	NSUInteger rank = [self.passage rankOfMemoryUnit:self];
	
	// If it's the last memory unit, use end of the string. Else, get the starting index of the next brick, then subtract 1. 
	NSUInteger endingIndex;
	NSArray *sortedBricksArray = [self.passage sortedBricks];
	if (rank == (sortedBricksArray.count - 1)) {
		endingIndex = self.passage.text.length - 1;
	} else {
		MemoryUnit *nextBrick = [sortedBricksArray objectAtIndex:(rank + 1)];
		endingIndex = [nextBrick.startingIndex integerValue] - 1;
	}
	return endingIndex;
}


- (NSUInteger)length {
	return [self.passage lengthOfMemoryUnit:self];
}

- (NSUInteger)startingIndex {
	return [self.startingIndex_ intValue];
}

@end