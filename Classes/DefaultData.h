/*
 File: DefaultData.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: For making default data for a persistant store.
 */

#import <Foundation/Foundation.h>

//@class Passage;

@interface DefaultData : NSObject {
}

+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext;
//+ (Passage *)getInstructions:(NSManagedObjectContext *)theManagedObjectContext;
+ (BOOL)shouldBeReset;

@end
