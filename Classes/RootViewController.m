/*
 File: RootViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import "DefaultData.h"
#import "LearnPassageViewController.h"
#import "Passage.h"
#import "RootViewController.h"

@implementation RootViewController

@synthesize logTextView, managedObjectContext, passageTitlesTextView;

- (void)dealloc {
	[logTextView release];
	[managedObjectContext release];
	[passageTitlesTextView release];
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

- (IBAction)makeDefaultDataStore:(id)sender {
	[DefaultData makeStore];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

// for dev. show passage titles. currently from default data store.
- (void)showPassageTitles {

	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	
	// Set entity.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage" inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	// Set sorting: alphabetize by title.
	NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject:aSortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	
	// Fetch.
	NSError *error; 
	NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy]; 
	
	[request release];
	
	if (fetchResults == nil) {
	
		// Handle the error.
		NSLog(@"Fetch result was nil.");
	}
	
	NSArray *passageArray = fetchResults;
	//NSLog(@"testing rvc: %@", [passageArray componentsJoinedByString:@"\n"]);
	NSString *passageTitles = @"";
	for (Passage *aPassage in passageArray) {
		NSLog(@"passage title: %@", aPassage.title);
		passageTitles = [passageTitles stringByAppendingFormat:@"%@\n", aPassage.title];
	}
	self.passageTitlesTextView.text = passageTitles;

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	
	// temp; show passage titles from default data store
	[self showPassageTitles];
}


- (void)viewDidUnload {

    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.logTextView = nil;
	self.passageTitlesTextView = nil;
	
	// Release any data that is recreated in viewDidLoad.
}

@end
