/*
 File: RootViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import "DefaultData.h"
#import "LearnPassageViewController.h"
#import "Passage.h"
#import "RecallPassageViewController.h"
#import "RootViewController.h"

// Private category for private methods.
@interface RootViewController ()

// For storing a reference to each passage.
@property (nonatomic, retain) NSArray *passageArray;

// Return all passages, sorted alphabetically by title, from the main Core Data store. 
- (NSArray *)fetchPassages;

@end

@implementation RootViewController

@synthesize logTextView, makeDefaultDataButton, managedObjectContext, passageTitlesTextView;
@synthesize passageArray;

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

- (NSArray *)fetchPassages {

	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	
	// Set entity.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passage" inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	// Set sorting: Alphabetize by title.
	NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObject:aSortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	
	// Fetch.
	NSError *error; 
	NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy]; 
	
	[request release];
	
	if (fetchResults == nil) {
	
		// Handle the error.
		NSLog(@"RootViewController: Fetch result was nil.");
	}
	
	return fetchResults;
}


- (IBAction)goToPhilippians:(id)sender {
	
	// Get passage for Philippians.
	Passage *desiredPassage;
	for (Passage *aPassage in self.passageArray) {
		if ([aPassage.title isEqualToString:@"Philippians (The Message)"]) {
			desiredPassage = aPassage;
			break;
		}
	}
	
	// Make controller.
	UIViewController *aLearnPassageViewController = [[LearnPassageViewController alloc] initWithPassage:desiredPassage];
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

	NSLog(@"RVC: makeDefaultDataStore called");
	[DefaultData makeStore];
}


- (IBAction)recallPassage:(id)sender {
	
	// Get passage for Philippians.
	Passage *desiredPassage;
	for (Passage *aPassage in self.passageArray) {
		if ([aPassage.title isEqualToString:@"Philippians (The Message)"]) {
			desiredPassage = aPassage;
			break;
		}
	}
	
	// Make controller.
	UIViewController *aRecallPassageViewController = [[RecallPassageViewController alloc] initWithPassage:desiredPassage];
	[self.navigationController pushViewController:aRecallPassageViewController animated:YES];
	[aRecallPassageViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

// for dev. show passage titles in UI.
- (void)showPassageTitles {

	NSString *passageTitles = @"";
	for (Passage *aPassage in self.passageArray) {
		NSLog(@"passage title: %@", aPassage.title);
		passageTitles = [passageTitles stringByAppendingFormat:@"%@\n", aPassage.title];
	}
	self.passageTitlesTextView.text = passageTitles;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	
	// For development. Disable button for making default data. Enable if needed for dev.
	self.makeDefaultDataButton.enabled = NO;
	
	// Get passages.
	self.passageArray = [self fetchPassages];
	
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
