//
//  Passage.h
//  bible-memory-ipad
//
//  A passage is some text and its title. A passage's text is divided into one or more non-overlapping bricks; each brick represents a minimal learning unit.
//
//  Created by Geoffrey Hom on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Brick;

@interface Passage : NSManagedObject {
	BOOL sortedBricksIsCurrent;

@private
	NSArray *sortedBricks_;
}

@property (assign) BOOL sortedBricksIsCurrent;

@property (nonatomic, retain) NSSet* bricks;

// Note that these ranks are NSNumbers, because Core Data forces that, but rankOfBrick: returns an NSUInteger.
@property (nonatomic, retain) NSNumber *rankOfCurrentEndingBrick;
@property (nonatomic, retain) NSNumber *rankOfCurrentStartingBrick;

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *title;

- (void)addObservers;
- (Brick *)currentStartingBrick;
- (Brick *)currentEndingBrick;
- (NSUInteger)endingIndexOfBrick:(Brick *)theBrick;
- (NSUInteger)endingIndexOfClause:(NSUInteger)theStartingIndex;
- (NSUInteger)lengthOfBrick:(Brick *)theBrick;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
- (NSUInteger)rankOfBrick:(Brick *)theBrick;
- (void)removeObservers;
- (NSArray *)sortedBricks;
- (NSString *)stringFromBrick:(Brick *)theBrick;
- (NSString *)stringFromCurrentBricks;
- (NSString *)stringFromStartOfCurrentBricks;

@end

@interface Passage (CoreDataGeneratedAccessors)
- (void)addBricksObject:(Brick *)value;
- (void)removeBricksObject:(Brick *)value;
- (void)addBricks:(NSSet *)value;
- (void)removeBricks:(NSSet *)value;

@end
