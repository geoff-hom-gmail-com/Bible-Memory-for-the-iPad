//
//  Brick.h
//  bible-memory-ipad
//
//	A brick is part of a passage. A passage is divided into non-overlapping bricks. A brick does not contain actual text but instead includes the starting index of the passage associated with the brick. (The passage knows the end of the brick by looking at the start of the next brick.)
//
//  Created by Geoffrey Hom on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Passage;

@interface Brick : NSManagedObject {
}

@property (nonatomic, retain) Passage *passage;

// Note that the starting index is an NSNumber (forced by Core Data), but the endingIndex method returns an NSUInteger.
@property (nonatomic, retain) NSNumber *startingIndex;

- (NSUInteger)endingIndex;
- (NSUInteger)length;

@end