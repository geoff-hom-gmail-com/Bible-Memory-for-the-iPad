/*
 File: DefaultData.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: For working with the default data.
 */

#import <Foundation/Foundation.h>

// Name of the file for the default-data Core Data store.
extern NSString *defaultStoreName;

@interface DefaultData : NSObject {
}

// Copy the default-data Core Data store to the given URL. The store must be in the main bundle.
+ (void)copyStoreToURL:(NSURL *)theURL;

/* 
 Make the Core Data store for default data by parsing a property list. When the user first runs this app, it will initialize the main store with default data by copying that default-data Core Data store from the main bundle. It uses a Core Data store because that incurs less overhead than parsing a property list. 

 During development, if the default data ever changes, call this method. Then add the resulting store to the main bundle (check the console for the path). Note that the main store will be initialized with default data only if the main store doesn't exist yet. So, you may have to delete the main store to check.
 */
+ (void)makeStore;

// For dev. Currently: replace the entire Core Data store with the default one. Will have to adjust once the store has stuff we may want to keep, like username, other passages, etc.
//+ (void)reset;


//+ (Passage *)getInstructions:(NSManagedObjectContext *)theManagedObjectContext;
//deprecated?
+ (BOOL)shouldBeReset;

@end
