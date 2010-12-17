/*
  Project: bible-memory-ipad
	 File: Bible_memory_ipadAppDelegate.h
 Abstract:
 
 Created by Geoffrey Hom on 10/19/10.
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MainViewController;

@interface Bible_memory_ipadAppDelegate : NSObject <UIApplicationDelegate> {
	MainViewController *mainViewController;
    UIWindow *window;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

@end

