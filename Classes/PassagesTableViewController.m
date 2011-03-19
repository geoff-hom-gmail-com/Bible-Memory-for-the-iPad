/*
  Project: bible-memory-ipad
	 File: PassagesTableViewController.m
 
 Created by Geoffrey Hom on 10/22/10.
 */

#import "Passage.h"
#import "PassagesTableViewController.h"

@implementation PassagesTableViewController

@synthesize delegate, managedObjectContext, passagesArray;

// The designated initializer.
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
	if ((self = [super initWithStyle:UITableViewStylePlain]) != nil) {
	
        // Custom initialization.
		self.managedObjectContext = theManagedObjectContext;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Currently, all of the passages are fetched from the persistent store each time this view loads. This may not be ideal. Think about this more when the user can add/delete passages (thus affecting which passages would appear in this table).
	
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
	
	// Move instructions to the top of the table.
	int instructionsIndex = -1;
	Passage *instructionsPassage;
	for (int i=0; i < fetchResults.count; i++) {
		Passage *aPassage = [fetchResults objectAtIndex:i];
		if ([aPassage.title isEqualToString:@"Instructions"]) {
			instructionsIndex = i;
			instructionsPassage = aPassage;
			break;
		}
	}
	if (instructionsIndex != -1) {
		[fetchResults removeObjectAtIndex:instructionsIndex];
		[fetchResults insertObject:instructionsPassage atIndex:0];
	}
	
	self.passagesArray = fetchResults;
	
	// Set size in popover to match the number of content rows.
	[self.tableView layoutIfNeeded];
	CGSize size = CGSizeMake(320.0, self.tableView.contentSize.height);
	self.contentSizeForViewInPopover = size;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Table view data source

/*
// Implement if table view has more than one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return ??;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
	return self.passagesArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	Passage *aPassage = (Passage *)[self.passagesArray objectAtIndex:indexPath.row];
	cell.textLabel.text = aPassage.title;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	 
	// Notify the delegate that a row was selected.
	[self.delegate passageSelected:[self.passagesArray objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.passagesArray = nil;
}

- (void)dealloc {
	[managedObjectContext release];
    [passagesArray release];
	[super dealloc];
}

@end