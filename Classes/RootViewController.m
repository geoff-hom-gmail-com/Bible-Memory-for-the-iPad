/*
 File: RootViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import "LearnPassageViewController.h"
#import "RootViewController.h"

@implementation RootViewController

@synthesize textField;

- (void)dealloc {
	[textField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (IBAction)goToPhilippians:(id)sender {
	
	UIViewController *aLearnPassageViewController = [[LearnPassageViewController alloc] init];
	[self.navigationController pushViewController:aLearnPassageViewController animated:YES];
	[aLearnPassageViewController release];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewDidUnload {

    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.textField = nil;
	
	// Release any data that is recreated in viewDidLoad.
}

@end
