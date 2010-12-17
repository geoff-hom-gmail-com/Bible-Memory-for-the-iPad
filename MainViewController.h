/*
  Project: bible-memory-ipad
	 File: MainViewController.h
 Abstract:
 
 Created by Geoffrey Hom on 10/19/10.
 */

#import <UIKit/UIKit.h>
#import "PassagesTableViewController.h"

@class SegmentedControlController;

@interface MainViewController : UIViewController <PassagesTableViewDelegate> {
	NSManagedObjectContext *managedObjectContext;
	UIBarButtonItem *passagesBarButtonItem;
	UIPopoverController *passagesPopoverController;
	UISegmentedControl *segmentedControl;
	SegmentedControlController *segmentedControlController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *passagesBarButtonItem;
@property (nonatomic, retain) UIPopoverController *passagesPopoverController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) SegmentedControlController *segmentedControlController;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;
- (IBAction)showOrHidePassageTitles:(id)sender;

@end
