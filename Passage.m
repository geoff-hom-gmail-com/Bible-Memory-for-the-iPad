// 
//  Passage.m
//  bible-memory-ipad
//
//  Created by Geoffrey Hom on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import "MemoryUnit.h"
#import "Passage.h"

@implementation Passage 

@dynamic text, title;
//@dynamic bricks, rankOfCurrentEndingBrick, rankOfCurrentStartingBrick, text, title;
//@synthesize sortedBricksIsCurrent;

//- (void)addObservers {
//
//	// Watch for bricks being added or deleted.
//	[self addObserver:self forKeyPath:@"bricks" options:(NSKeyValueObservingOptionNew |
//NSKeyValueObservingOptionOld) context:nil];
//	
//	// Watch for changes to each brick's starting index. Note that this seems to be called also when a brick's starting index is fetched (even if it doesn't change).
//	for (MemoryUnit *aBrick in self.bricks) {
//		[aBrick addObserver:self forKeyPath:@"startingIndex" options:0 context:nil];
//	}
//}
//
//- (MemoryUnit *)currentStartingBrick {
//	return [[self sortedBricks] objectAtIndex:[self.rankOfCurrentStartingBrick integerValue]];
//}
//
//- (MemoryUnit *)currentEndingBrick {
//	return [[self sortedBricks] objectAtIndex:[self.rankOfCurrentEndingBrick integerValue]];
//}
//
////// Return the ending index of the given brick's text.
////- (NSUInteger)endingIndexOfBrick:(MemoryUnit *)theBrick {
////	
////	// Get brick's rank.
////	NSUInteger rank = [self rankOfBrick:theBrick];
////	
////	// If it's the last brick, use end of the string. Else, get the starting index of the next brick, then subtract 1. 
////	NSUInteger endingIndex;
////	NSArray *sortedBricksArray = [self sortedBricks];
////	if (rank == (sortedBricksArray.count - 1)) {
////		endingIndex = self.text.length - 1;
////	} else {
////		MemoryUnit *nextBrick = [sortedBricksArray objectAtIndex:(rank + 1)];
////		endingIndex = [nextBrick.startingIndex integerValue] - 1;
////	}
////	return endingIndex;
////}
//
//// For the clause that includes the starting index, return the ending index. By "clause" we mean the next set of words ending in a punctuation mark, with a minimum of 3 words. The starting index is not necessarily the start of the clause but simply must be part of the clause.
//- (NSUInteger)endingIndexOfClause:(NSUInteger)theStartingIndex {
//	
//	// Plan: Start right after the end of the previous clause. Then, count forward 3 words. From the start of the third word, search for the next punctuation mark. That's the end of the clause we want.
//	
//	// Start right after the end of the previous clause. 	
//	NSUInteger indexAfterPreviousClause;
//	NSCharacterSet *punctuationCharacterSet = [NSCharacterSet punctuationCharacterSet];
//	NSUInteger startingIndex, endingIndex;
//	NSRange searchRange, targetRange;
//	
//	// If the starting index is the beginning of the text, then we want the beginning.
//	if (theStartingIndex == 0) {
//		indexAfterPreviousClause = 0;
//	} else {
//		startingIndex = 0;
//		endingIndex = theStartingIndex - 1;
//		searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//		targetRange = [self.text rangeOfCharacterFromSet:punctuationCharacterSet options:NSBackwardsSearch range:searchRange];
//		
//		// If the end of the previous clause was not found, then we want the beginning of the text.
//		if (targetRange.location == NSNotFound) {
//			indexAfterPreviousClause = 0;
//		} else {
//			indexAfterPreviousClause = targetRange.location + 1;
//		}
//	}
//	
//	// Count forward 3 words. Note the index for the start of the third word.
//	NSUInteger endingIndexOfClause = NSUIntegerMax;
//	NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//	NSCharacterSet *nonWhiteSpaceCharacterSet = [whitespaceAndNewlineCharacterSet invertedSet];
//	endingIndex = self.text.length - 1;
//	
//	// We're starting either at the start of the text or on whitespace. So, search for non-whitespace for the start of the first word.
//	startingIndex = indexAfterPreviousClause;
//	searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//	targetRange = [self.text rangeOfCharacterFromSet:nonWhiteSpaceCharacterSet options:0 range:searchRange];
//	
//	// If forward target not found, then we want the end of the text.
//	if (targetRange.location == NSNotFound) {
//		endingIndexOfClause = self.text.length - 1;
//	} else {
//	
//		// Now search for the next whitespace, then the next non-whitespace. I.e., the start of the next word. Do this twice. (I.e., to find the 2nd and 3rd words.)
//		NSArray *array = [NSArray arrayWithObjects:whitespaceAndNewlineCharacterSet, nonWhiteSpaceCharacterSet, nil];
//		for (int i = 0; i < 2; i++) {
//			for (NSCharacterSet *characterSet in array) {
//				startingIndex = targetRange.location;
//				searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//				targetRange = [self.text rangeOfCharacterFromSet:characterSet options:0 range:searchRange];
//				
//				// If not found, then we know to go to the end of the passage.
//				if (targetRange.location == NSNotFound) {
//					endingIndexOfClause = self.text.length - 1;
//					break;
//				}
//			}
//			
//			// If we know the end already, then break.
//			if (endingIndexOfClause != NSUIntegerMax) {
//				break;
//			}
//		}
//	}
//	
//	// If there's still more to search, then search for the next punctuation mark, starting from the start of the third word.
//	if (endingIndexOfClause == NSUIntegerMax) {
//		startingIndex = targetRange.location;
//		searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//		targetRange = [self.text rangeOfCharacterFromSet:punctuationCharacterSet options:0 range:searchRange];
//		if (targetRange.location == NSNotFound) {
//			endingIndexOfClause = self.text.length - 1;
//		} else {
//			endingIndexOfClause = targetRange.location;
//		}
//	}
//	return endingIndexOfClause;
//}
//
//// Return length of the given brick's text.
//- (NSUInteger)lengthOfBrick:(MemoryUnit *)theBrick {
//	NSUInteger length = [self endingIndexOfBrick:theBrick] - [theBrick.startingIndex integerValue] + 1;
//	return length;
//}
//
//// One of the passage's observers was notified. Currently, the only observers are for brick changes. So, flag that the bricks need to be re-sorted. Also, if bricks were added or deleted, then add or remove observers.
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//
//	self.sortedBricksIsCurrent = NO;
//	
//	// If bricks were added or deleted, then start or stop watching those bricks' starting index.
//	if ([keyPath isEqualToString:@"bricks"]) {
//		NSInteger changeKindInteger = [(NSNumber *)[change objectForKey:NSKeyValueChangeKindKey] integerValue];
//		if (changeKindInteger == NSKeyValueChangeInsertion) {
//			NSArray *insertedBricksArray = [change objectForKey:NSKeyValueChangeNewKey];
//			for (MemoryUnit *aBrick in insertedBricksArray) {
//				[aBrick addObserver:self forKeyPath:@"startingIndex" options:0 context:nil];
//			}
//		} else if (changeKindInteger == NSKeyValueChangeRemoval) {
//			NSArray *removedBricksArray = [change objectForKey:NSKeyValueChangeOldKey];
//			for (MemoryUnit *aBrick in removedBricksArray) {
//				[aBrick removeObserver:self forKeyPath:@"startingIndex"];
//			}
//		}
//	}
//}
//
//// Return the given brick's order relative to the other bricks.
//- (NSUInteger)rankOfBrick:(MemoryUnit *)theBrick {
//	NSArray *sortedBricksArray = [self sortedBricks];
//	NSUInteger rank;
//	for (int i = 0; i < [sortedBricksArray count]; i++) {
//		if (((MemoryUnit *)[sortedBricksArray objectAtIndex:i]).startingIndex == theBrick.startingIndex) {
//			rank = i;
//			break;
//		}
//	}
//	return rank;
//}
//
//// Stop watching for changes in bricks.
//- (void)removeObservers {
//
//	// Stop watching for bricks being added or deleted.
//	[self removeObserver:self forKeyPath:@"bricks"];
//	
//	// Stop watching for changes to each brick's starting index.
//	for (MemoryUnit *aBrick in self.bricks) {
//		[aBrick removeObserver:self forKeyPath:@"startingIndex"];
//	}
//}
//
//// Return the bricks as an array, ordered by each brick's starting index. Do the actual sorting only when necessary.
//- (NSArray *)sortedBricks {
//	if (!self.sortedBricksIsCurrent) {
//		NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startingIndex" ascending:YES];
//		NSArray *sortDescriptors = [NSArray arrayWithObject:aSortDescriptor];
//		sortedBricks_ = [[self.bricks sortedArrayUsingDescriptors:sortDescriptors] retain];
//		self.sortedBricksIsCurrent = YES;
//	}
//	return sortedBricks_;
//}
//
//// Return the string represented by the given brick.
//- (NSString *)stringFromBrick:(MemoryUnit *)theBrick {
//	NSUInteger startingIndex = [theBrick.startingIndex integerValue];
//	NSUInteger endingIndex = [self endingIndexOfBrick:theBrick];
//	NSRange aRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//	NSString *string = [self.text substringWithRange:aRange];
//	return string;
//}
//
//// Return the string containing the current bricks to learn/recall. The bricks are in a row and depend on the user's progress in the passage.
//- (NSString *)stringFromCurrentBricks {
//
//	// Get the substring from the start of the starting brick to the end of the ending brick.
//	NSUInteger startingIndex = [[self currentStartingBrick].startingIndex integerValue];
//	NSUInteger endingIndex = [self endingIndexOfBrick:[self currentEndingBrick]];
//	NSRange range = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//	NSString *string = [self.text substringWithRange:range];
//	return string;
//}
//
//// Return the first clause from the current bricks.
//- (NSString *)stringFromStartOfCurrentBricks {
//	
//	// Start from the beginning of the current starting brick. Find the end of the first clause or the end of the current ending brick, whichever is first. 
//	NSUInteger startingIndex = [[self currentStartingBrick].startingIndex integerValue];
//	NSUInteger endingIndexOfClause = [self endingIndexOfClause:startingIndex];
//	NSUInteger endingIndexOfCurrentEndingBrick = [[self currentEndingBrick] endingIndex];
//	NSUInteger endingIndex = MIN(endingIndexOfClause, endingIndexOfCurrentEndingBrick);
//	NSRange aRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
//	NSString *string = [self.text substringWithRange:aRange];
//	return string;
//}
//
//// Register observer for brick changes.
//- (void)awakeFromFetch {
//	[super awakeFromFetch];
//	[self addObservers];
//	//NSLog(@"Passage awakeFromFetch; observer registered");
//	
//	// observe "bricks" and observe "startingindex" for each brick"
//	// if a brick is added observe its startingindex
//	// if a brick is removed, stop observing its startingindex
//	//[self addObserver:self forKeyPath:@"bricks" options:0 context:nil];
//}
//
//// Register observer for brick changes.
//- (void)awakeFromInsert {
//	[super awakeFromInsert];
//	[self addObservers];
//	//NSLog(@"Passage awakeFromInsert; observer registered");
//	//[self addObserver:self forKeyPath:@"bricks" options:0 context:nil];
//}
//
//// Remove observers. Note: This may not work with deletion-undo, since the observer would be removed upon deletion but then no added back. 
//- (void)didTurnIntoFault {
//	[super didTurnIntoFault];
//	[self removeObservers];
//	// remove observer for "bricks" and for each brick's "startingIndex"
//	//NSLog(@"Passage didTurnIntoFault; removing observer");
//	//[self removeObserver:self forKeyPath:@"bricks"];
//}

- (void)dealloc {
	//[sortedBricks_ release];
	[super dealloc];
}

@end
