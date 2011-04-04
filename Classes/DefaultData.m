/*
 File: DefaultData.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import "BibleMemoryAppDelegate.h"
#import "DefaultData.h"
#import "Passage.h"

// Whether the default passages should be reset. (E.g., if they were changed.)
static BOOL shouldBeReset = NO;

NSString *defaultStoreName = @"defaultStore.sqlite";


// Private category for private methods.
@interface DefaultData ()

// Add the default data (from a property list) to the given context.
+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext;

@end

@implementation DefaultData

+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext {
	
	// Get the default data from the default-data property list.
	NSString *defaultDataPath = [[NSBundle mainBundle] pathForResource:@"default-data" ofType:@"plist"];
	NSFileManager *aFileManager = [[NSFileManager alloc] init];
	NSData *defaultDataXML = [aFileManager contentsAtPath:defaultDataPath];
	[aFileManager release];
	NSString *errorDesc = nil; 
	NSPropertyListFormat format;
	NSDictionary *rootDictionary = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:defaultDataXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	if (!rootDictionary) { 
		NSLog(@"Error reading default plist: %@, format: %d", errorDesc, format);
	} else {
		NSString *key1;
		Passage *aPassage;
		NSDictionary *intraPassageDictionary;
		NSString *key2;
		for (key1 in rootDictionary) {
		
			// Add the passage to the context.
			aPassage = (Passage *)[NSEntityDescription insertNewObjectForEntityForName:@"Passage" inManagedObjectContext:theManagedObjectContext];
			aPassage.title = key1;
			intraPassageDictionary = [rootDictionary objectForKey:key1];
			for (key2 in intraPassageDictionary) {
				if ([key2 isEqualToString:@"Text"]) {
					aPassage.text = [intraPassageDictionary objectForKey:key2];
				}
				// for adding multiple predefined bricks to a passage
				//else if ([key2 isEqualToString:@"Brick data"]) {
//					
//					// Convert the array of brick starting indices into a set of bricks.
//					NSArray *brickDataArray = (NSArray *)[intraPassageDictionary objectForKey:key2];
//					NSMutableSet *mutableSet = [NSMutableSet set];
//					for (int i = 0; i < brickDataArray.count; i++) {
//						Brick *aBrick = (Brick *)[NSEntityDescription insertNewObjectForEntityForName:@"Brick" inManagedObjectContext:theManagedObjectContext];
//						aBrick.startingIndex = [brickDataArray objectAtIndex:i];
//						[mutableSet addObject:aBrick];
//					}
//					aPassage.bricks = mutableSet;
//				}
			}
			// add starting brick
			//MemoryUnit *aBrick = (MemoryUnit *)[NSEntityDescription insertNewObjectForEntityForName:@"Brick" inManagedObjectContext:theManagedObjectContext];
//			[aPassage addBricksObject:aBrick];
		}
	}
		
	NSError *error; 
	if (![theManagedObjectContext save:&error]) {
		// Handle the error.
	}
	NSLog(@"Default data added to current context.");
}

+ (void)copyStoreToURL:(NSURL *)theURL {

	NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:defaultStoreName withExtension:nil];
	if (defaultStoreURL) {
		NSFileManager *aFileManager = [[NSFileManager alloc] init];
		[aFileManager copyItemAtURL:defaultStoreURL toURL:theURL error:NULL];
		[aFileManager release];
		NSLog(@"Default store copied to main store.");
	} else {
		NSLog(@"Warning: Default store not found in main bundle.");
	}
}

/*
 Return the instructions passage.
 really, this just gets a passage with the title "instructions," so it could be a more generic/useful method. and maybe a class method of Passage, not DefaultPassages.
 */
+ (Passage *)getInstructions:(NSManagedObjectContext *)theManagedObjectContext {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	
	// Set entity.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage" inManagedObjectContext:theManagedObjectContext]; 
	[request setEntity:entity];
	
	// Set predicate.
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == 'Instructions'"];
	[request setPredicate:predicate];
	
	// Fetch.
	NSError *error; 
	NSArray *fetchResults = [theManagedObjectContext executeFetchRequest:request error:&error];
	 
	[request release];
	
	Passage *instructionsPassage;
	if (fetchResults == nil) {
		
		// Handle the error.
		NSLog(@"Fetch result was nil.");
		instructionsPassage = nil;
		
	} else if (fetchResults.count == 0) {
		NSLog(@"Fetch result was empty.");
		instructionsPassage = nil;
	} else {
		instructionsPassage = [fetchResults objectAtIndex:0];
	}
	
	return instructionsPassage;
}

+ (void)makeStore {
	
	// Delete existing default-data store, if any.
	BibleMemoryAppDelegate *aBibleMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
	NSURL *applicationDocumentsDirectoryURL = [aBibleMemoryAppDelegate applicationDocumentsDirectory];
	NSURL *defaultStoreURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:defaultStoreName];
	NSFileManager *aFileManager = [[NSFileManager alloc] init];
	BOOL deletionResult = [aFileManager removeItemAtURL:defaultStoreURL error:nil];
	NSLog(@"Deleted previous default-data store from application's documents directory: %d", deletionResult);
	[aFileManager release];
	
	// Remove the main store from the persistent store coordinator.
	NSURL *mainStoreURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:mainStoreName];
	NSPersistentStoreCoordinator *aPersistentStoreCoordinator = aBibleMemoryAppDelegate.persistentStoreCoordinator;
	NSPersistentStore *mainPersistentStore = [aPersistentStoreCoordinator persistentStoreForURL:mainStoreURL];
	[aPersistentStoreCoordinator removePersistentStore:mainPersistentStore error:nil];
	
	// Add the default-data store to the persistent store coordinator.
	NSError *error = nil;
	NSPersistentStore *defaultPersistentStore = [aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:defaultStoreURL options:nil error:&error];
	if (!defaultPersistentStore) {
		NSLog(@"Unresolved error making default store: %@, %@", error, [error userInfo]);
	} else {
		NSLog(@"Default store added: %@", [defaultStoreURL path]);
	}

	// Populate the store.
	[DefaultData addDefaultData:aBibleMemoryAppDelegate.managedObjectContext];
	
	// Remove the default-data store and add back the main store.
	[aPersistentStoreCoordinator removePersistentStore:defaultPersistentStore error:nil];
	[aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:mainStoreURL options:nil error:nil];
}

// deprecated?
+ (void)reset {

	// Remove the main store from the persistent store coordinator.
	BibleMemoryAppDelegate *aBibleMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
	NSURL *mainStoreURL = [[aBibleMemoryAppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:mainStoreName];
	NSPersistentStoreCoordinator *aPersistentStoreCoordinator = aBibleMemoryAppDelegate.persistentStoreCoordinator;
	NSPersistentStore *mainPersistentStore = [aPersistentStoreCoordinator persistentStoreForURL:mainStoreURL];
	[aPersistentStoreCoordinator removePersistentStore:mainPersistentStore error:nil];
	
	// Replace the main store file with the default store file.
	[DefaultData copyStoreToURL:mainStoreURL];
	
	// Add back the main store.
	[aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:mainStoreURL options:nil error:nil];
}

+ (BOOL)shouldBeReset {
    return shouldBeReset;
}
		
@end
