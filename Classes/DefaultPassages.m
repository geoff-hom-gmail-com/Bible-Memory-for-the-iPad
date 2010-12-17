/*
  Project: bible-memory-ipad
	 File: DefaultPassages.m
 Abstract:
 
 Created by Geoffrey Hom on 10/25/10.
 */

#import "Brick.h"
#import "DefaultPassages.h"
#import "Passage.h"

@implementation DefaultPassages

/**
 Add the default data to the given context.
 */
+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext {
	
	// Get the default data from the default-data property list.
	NSString *defaultDataPath = [[NSBundle mainBundle] pathForResource:@"default-data" ofType:@"plist"];
	NSData *defaultDataXML = [[NSFileManager defaultManager] contentsAtPath:defaultDataPath];
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
			Brick *aBrick = (Brick *)[NSEntityDescription insertNewObjectForEntityForName:@"Brick" inManagedObjectContext:theManagedObjectContext];
			[aPassage addBricksObject:aBrick];
		}
	}
		
	NSError *error; 
	if (![theManagedObjectContext save:&error]) {
		// Handle the error.
	}
}

/**
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
		
@end
