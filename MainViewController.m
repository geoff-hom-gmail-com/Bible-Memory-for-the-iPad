/*
  Project: bible-memory-ipad
	 File: MainViewController.m
 
 Created by Geoffrey Hom on 10/19/10.
 */

#import "DefaultData.h"
#import "LearnTextViewController.h"
#import "MainViewController.h"
#import "Passage.h"
#import "PassagesTableViewController.h"
#import "SegmentedControlController.h"
#import "ShowTextViewController.h"

@implementation MainViewController

@synthesize managedObjectContext, passagesBarButtonItem, passagesPopoverController, segmentedControl, segmentedControlController;

// The user selected a passage. Dismiss the popover and show the text.
- (void)passageSelected:(Passage *)thePassage {
	[self.passagesPopoverController dismissPopoverAnimated:YES];
	self.passagesBarButtonItem.title = thePassage.title;
	
	// If the passage is the instructions, then disable the segment, "Learn text."
	if ([thePassage.title isEqualToString:@"Instructions"]) {
		self.segmentedControl.selectedSegmentIndex = 0;
		[self.segmentedControl setEnabled:NO forSegmentAtIndex:1];		
	} else {
		[self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
	
	[self.segmentedControlController passageSelected:thePassage];
}

// The designated initializer.
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
	if ((self = [super initWithNibName:nil bundle:nil])) {
	
        // Custom initialization.
		self.managedObjectContext = theManagedObjectContext;
    }
    return self;
}

// Present a popover of the passage titles, if not visible. If visible, dismiss the popover.
- (IBAction)showOrHidePassageTitles:(id)sender {
	
	// Create the popover, if necessary.
	if (self.passagesPopoverController == nil) {
		
		// Create the table view controller for the popover.
		PassagesTableViewController *aPassagesTableViewController = [[PassagesTableViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
		aPassagesTableViewController.delegate = self;
		
		// Create the popover controller.
		UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:aPassagesTableViewController];
		[aPassagesTableViewController release];
		self.passagesPopoverController = aPopoverController;
		[aPopoverController release];		
	}
	
	if (!self.passagesPopoverController.popoverVisible) {
		[self.passagesPopoverController presentPopoverFromBarButtonItem:sender
			permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self.passagesPopoverController dismissPopoverAnimated:YES];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	// Set up the view controllers for the segmented control.
	//ShowTextViewController *aShowTextViewController = [[ShowTextViewController alloc] init];
	ShowTextViewController *aShowTextViewController = [[ShowTextViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
	LearnTextViewController *aLearnTextViewController = [[LearnTextViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
	NSArray *tempViewControllers = [NSArray arrayWithObjects:aShowTextViewController, aLearnTextViewController, nil];
	[aShowTextViewController release];
	[aLearnTextViewController release];
	
	// Create and set up the segmented control controller.
	
	UINavigationController *aNavigationController = [[UINavigationController alloc] init];
	
	SegmentedControlController *aSegmentedControlController = [[SegmentedControlController alloc] initWithNavigationController:aNavigationController viewControllers:tempViewControllers];
	self.segmentedControlController = aSegmentedControlController;
	[aSegmentedControlController release];
	
	// Change views when the segmented control is changed.
	[self.segmentedControl addTarget:self.segmentedControlController action:@selector(changeViewsBasedOnSegmentedControl:) forControlEvents:UIControlEventValueChanged];
	
	[self.view addSubview:aNavigationController.view];
	
	// Add navigation controller beneath toolbar so taps aren't blocked.
	[self.view sendSubviewToBack:aNavigationController.view];
	
	// Move navigation controller's frame. The navigation controller will later move its frame down by the status bar's height (20 points), which is bad since the controller is not the root. We also need to shift down by the toolbar's height (44 points). So 44 - 20 = 24 points.
	CGRect rect = aNavigationController.view.frame;
	rect.origin.y = 24.0f;
	aNavigationController.view.frame = rect;
	
	[aNavigationController release];
	
	// Show instructions.
	Passage *instructionsPassage = [DefaultData getInstructions:self.managedObjectContext];
	[self passageSelected:instructionsPassage];
	
	// Show initial view based on segmented control.
	self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControlController changeViewsBasedOnSegmentedControl:self.segmentedControl];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.passagesBarButtonItem = nil;
	
	// Releasing here (vs. didReceiveMemoryWarning) in case a memory warning occurs while the popover is visible.
	self.passagesPopoverController = nil;
	
	self.segmentedControl = nil;
	self.segmentedControlController = nil;
}

- (void)dealloc {
	[managedObjectContext release];
	[passagesBarButtonItem release];
	[passagesPopoverController release];
	[segmentedControl release];
	[segmentedControlController release];
	[super dealloc];
}

@end
