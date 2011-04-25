/*
 Program: Bible Memory
 Version: 0.09
 File: Bible_memory_ipadAppDelegate.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: The application delegate. 
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// Name of the file for the main Core Data store.
extern NSString *mainStoreName;

@interface BibleMemoryAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *navigationController;
	UIWindow *window;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// The URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory;

@end

