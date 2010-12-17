/*
  Project: bible-memory-ipad
	 File: DefaultPassages.h
 Abstract: A class for making the default data for a persistant store. This includes the instructions, which, for convenience, are a passage. 
 Created by Geoffrey Hom on 10/25/10.
 */

#import <Foundation/Foundation.h>

@class Passage;

@interface DefaultPassages : NSObject {
}

+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext;
+ (Passage *)getInstructions:(NSManagedObjectContext *)theManagedObjectContext;

@end
