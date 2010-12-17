/*
  Project: bible-memory-ipad
	 File: SegmentedControlController.h
 Abstract: When the user selects segments of a segmented control, this controller can show different views accordingly. Adapted from http://redartisan.com/2010/6/27/uisegmented-control-view-switching-revisited.
 
 Created by Geoffrey Hom on 11/24/10.
 */

#import <Foundation/Foundation.h>
#import "PassagesTableViewController.h"

@class Passage;

@interface SegmentedControlController : NSObject <PassagesTableViewDelegate> {
	Passage *currentPassage;
	UINavigationController *navigationController;
	NSArray *viewControllers;
}

@property (nonatomic, retain) Passage *currentPassage;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSArray *viewControllers;

- (void)changeViewsBasedOnSegmentedControl:(UISegmentedControl *)theSegmentedControl;
- (id)initWithNavigationController:(UINavigationController *)theNavigationController viewControllers:(NSArray *)theViewControllers;

@end
