/*
 File: Passage.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: A passage consists of text and a corresponding title. When a user memorizes part of a passage, that part is made into a memory unit.
 */

#import <CoreData/CoreData.h>

//@class MemoryUnit;

@interface Passage : NSManagedObject {
//	BOOL memoryUnitsAreSorted;
//	NSArray *sortedMemoryUnits;
}

//@property (assign) BOOL memoryUnitsAreSorted;

// Core Data.
//@property (nonatomic, retain) NSSet* memoryUnits;
//@property (nonatomic, retain) NSNumber *rankOfCurrentEndingMemoryUnit_;
//@property (nonatomic, retain) NSNumber *rankOfCurrentStartingMemoryUnit_;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *title;
//- (NSUInteger)endingIndexOfClause:(NSUInteger)theStartingIndex;


//
//// Watch for changes in each memory unit. 
//- (void)addObservers;
//
//// Return the first memory unit of the ones currently being learned.
//- (MemoryUnit *)currentStartingMemoryUnit;
//
//// Return the last memory unit of the ones currently being learned.
//- (MemoryUnit *)currentEndingMemoryUnit;
//
//- (NSUInteger)endingIndexOfMemoryUnit:(MemoryUnit *)theBrick;


//
//- (NSUInteger)lengthOfMemoryUnit:(MemoryUnit *)theBrick;
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
//
//- (NSUInteger)rankOfCurrentEndingMemoryUnit;
//
//- (NSUInteger)rankOfCurrentStartingMemoryUnit;
//
//- (NSUInteger)rankOfMemoryUnit:(MemoryUnit *)theBrick;
//
//- (void)removeObservers;
//
//- (NSArray *)sortedBricks;
//
//- (NSString *)stringFromBrick:(MemoryUnit *)theBrick;
//
//- (NSString *)stringFromCurrentBricks;
//
//- (NSString *)stringFromStartOfCurrentBricks;

@end

//@interface Passage (CoreDataGeneratedAccessors)
//- (void)addMemoryUnitsObject:(MemoryUnit *)value;
//- (void)removeMemoryUnitsObject:(MemoryUnit *)value;
//- (void)addMemoryUnits:(NSSet *)value;
//- (void)removeMemoryUnits:(NSSet *)value;
//@end
