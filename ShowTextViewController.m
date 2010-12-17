/*
  Project: bible-memory-ipad
	 File: ShowTextViewController.m
 Abstract:
 
 Created by Geoffrey Hom on 11/22/10.
 */

#import "Brick.h"
#import "Passage.h"
#import "ShowTextViewController.h"

@implementation ShowTextViewController

@synthesize currentPassage, managedObjectContext, textView, webView;

// If a different passage was selected, then update the view.
- (void)passageSelected:(Passage *)thePassage {

	if (thePassage != self.currentPassage) {
		self.currentPassage = thePassage;
		self.textView.text = self.currentPassage.text;
	}
}

// Color-code the phrases/bricks for the current passage. Enable brick editing.
- (IBAction)editPhrases:(id)sender {
	
	// Color-code the bricks by using alternating colors in an HTML string.
	
	NSString *headerString = @"<html><head>"
		"<style type=\"text/css\">"
		"p {font-family:helvetica; font-size:20; white-space:pre-wrap;}"
		".blue {color:blue;}"
		".red {color:red;}"
		"</style>"
		"</head><body>"
		"<p>";
	NSString *footerString = @"</p>"
		"</body></html>";
		
	// Color each brick alternately.
	NSString *blueClassString = @"blue";
	NSString *redClassString = @"red";
	NSString *styleClassString = blueClassString;
	NSString *aBrickString;
	NSString *aColoredBrickString;
	NSString *allColoredBricksString = @"";
	for (Brick *aBrick in [self.currentPassage sortedBricks]) {
		aBrickString = [self.currentPassage stringFromBrick:aBrick];
		
		// Add tag for CSS style around the brick.
		if ([styleClassString isEqualToString:blueClassString]) {
			styleClassString = redClassString;
		} else {
			styleClassString = blueClassString;
		}
		aColoredBrickString = [NSString stringWithFormat:@"<a class=\"%@\">%@</a>", styleClassString, aBrickString];
		
		allColoredBricksString = [allColoredBricksString stringByAppendingString:aColoredBrickString];
	}	
	NSString *htmlString = [NSString stringWithFormat:@"%@%@%@", headerString, allColoredBricksString, footerString];
	[self.webView loadHTMLString:htmlString baseURL:nil];
}

// The designated initializer.
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
	if (self = [super initWithNibName:nil bundle:nil]) {
	
        // Custom initialization.
		self.managedObjectContext = theManagedObjectContext;
    }
    return self;
}

//for testing. reset this passage to just one brick with a starting index of 0.
- (IBAction)resetBricks:(id)sender {
	
	// show first brick
	self.currentPassage.rankOfCurrentStartingBrick = [NSNumber numberWithInt:0];
	self.currentPassage.rankOfCurrentEndingBrick = self.currentPassage.rankOfCurrentStartingBrick;
	
	// delete bricks, except the first one
	NSArray *sortedBricksArray = [self.currentPassage sortedBricks];
	for (int i = 1; i < sortedBricksArray.count; i++) {
		[self.managedObjectContext deleteObject:[sortedBricksArray objectAtIndex:i]];
	}
	
	// should change the starting index of the remaining brick to 0 . . . but it should be that way already.
	
	// Save changes.
	NSError *error; 
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Show current passage.
	if (self.currentPassage != nil) {
		self.textView.text = self.currentPassage.text;
	}
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
	self.currentPassage = nil;
	self.textView = nil;
}

- (void)dealloc {
	[currentPassage release];
	[textView release];
    [super dealloc];
}

@end
