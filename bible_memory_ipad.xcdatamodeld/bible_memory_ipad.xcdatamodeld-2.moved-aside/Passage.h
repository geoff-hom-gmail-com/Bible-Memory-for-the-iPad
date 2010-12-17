//
//  Passage.h
//  bible-memory-ipad
//
//  Created by Geoffrey Hom on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Brick;

@interface Passage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * startingBrickIndex;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * endingBrickIndex;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet* rocks;

@end


@interface Passage (CoreDataGeneratedAccessors)
- (void)addRocksObject:(Brick *)value;
- (void)removeRocksObject:(Brick *)value;
- (void)addRocks:(NSSet *)value;
- (void)removeRocks:(NSSet *)value;

@end

