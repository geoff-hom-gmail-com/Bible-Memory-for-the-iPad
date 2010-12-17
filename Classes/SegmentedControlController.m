/*
  Project: bible-memory-ipad
	 File: SegmentedControlController.m
 Abstract:
 
 Created by Geoffrey Hom on 11/24/10.
 */

#import "Passage.h"
#import "SegmentedControlController.h"

@implementation SegmentedControlController

@synthesize currentPassage, navigationController, viewControllers;

// A passage was selected. Notify the current view.
- (void)passageSelected:(Passage *)thePassage {

	// Notify current view.
	id currentViewController = self.navigationController.visibleViewController;
	if ([currentViewController conformsToProtocol:@protocol(PassagesTableViewDelegate)]) {
		[currentViewController passageSelected:thePassage];
	}
	
	// Store for later.
	self.currentPassage = thePassage;
}

- (void)changeViewsBasedOnSegmentedControl:(UISegmentedControl *)theSegmentedControl {
    NSUInteger index = theSegmentedControl.selectedSegmentIndex;
    id incomingViewController = [self.viewControllers objectAtIndex:index];
	if ([incomingViewController conformsToProtocol:@protocol(PassagesTableViewDelegate)]) {
		[incomingViewController passageSelected:self.currentPassage];
	}

    NSArray *tempViewControllers = [NSArray arrayWithObject:incomingViewController];
    [self.navigationController setViewControllers:tempViewControllers animated:NO];
}

- (id)initWithNavigationController:(UINavigationController *)theNavigationController viewControllers:(NSArray *)theViewControllers {
    if (self = [super init]) {
        self.navigationController = theNavigationController;
		self.navigationController.navigationBarHidden = YES;
        self.viewControllers = theViewControllers;
    }
    return self;
}

- (void)dealloc {
	[currentPassage release];
    [navigationController release];
	[viewControllers release];
	[super dealloc];
}

@end
