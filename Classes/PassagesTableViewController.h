/*
  Project: bible-memory-ipad
	 File: PassagesTableViewController.h
 Abstract: A table view controller to manage and display a list of titles of Bible passages.
  
 Created by Geoffrey Hom on 10/22/10.
 */

#import <UIKit/UIKit.h>

@class Passage;

@protocol PassagesTableViewDelegate

// Sent after the user selected a row in the passages list.
- (void)passageSelected:(Passage *)thePassage;
@end

@interface PassagesTableViewController : UITableViewController {
	id <PassagesTableViewDelegate> delegate;
	NSManagedObjectContext *managedObjectContext;
	NSArray *passagesArray;
}

@property (nonatomic, assign) id <PassagesTableViewDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *passagesArray;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;

@end