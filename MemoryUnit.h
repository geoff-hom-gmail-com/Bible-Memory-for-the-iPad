/*
 File: MemoryUnit.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: A memory unit is a section of text that should be tested together.
 */

#import <CoreData/CoreData.h>

@class Passage;

@interface MemoryUnit : NSManagedObject {
}

@property (nonatomic, retain) Passage *passage;

// The starting index is in Core Data, so it must be an NSNumber.
@property (nonatomic, retain) NSNumber *startingIndex_;

// Return the index for the last character of this memory unit.
- (NSUInteger)endingIndex;

// Return the length of this memory unit's text.
- (NSUInteger)length;

// Return the index for the first character of this memory unit.
- (NSUInteger)startingIndex;

@end