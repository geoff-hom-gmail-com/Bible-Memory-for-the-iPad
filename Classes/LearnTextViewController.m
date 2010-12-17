/*
  Project: bible-memory-ipad
	 File: LearnTextViewController.m
 Abstract:
 
 Created by Geoffrey Hom on 11/24/10.
 */

#import "Brick.h"
#import "LearnTextViewController.h"
#import "Passage.h"
#import <QuartzCore/QuartzCore.h>

@implementation LearnTextViewController

@synthesize currentPassage, currentTextShowing, doneButton, editSectionsButton, hideClauseButton, hideSectionButton, hideWordButton, instructions1TextView, instructions2TextView, instructions3TextView, managedObjectContext, passageControls, passageTextView, showClauseButton, showSectionButton, showWordButton;

// If a different passage was selected, then update the view.
- (void)passageSelected:(Passage *)thePassage {

	if (thePassage != self.currentPassage) {
		self.currentPassage = thePassage;
		[self updateView];
		
	}
}

// Change the section/word controls so they look distinct from the standard round-rectangle button. These controls are used by the user differently than a standard UIButton.
- (void)changeAppearanceOfControls {
	
	//is this light grey too light? Check on actual iPad.
	UIColor *backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
	
	// Make a 1-point rectangle filled with the desired color.
	UIGraphicsBeginImageContext(CGSizeMake(1.0, 1.0));
	//testing; currently a dark purple
	[[UIColor colorWithRed:0.5 green:0.2 blue:0.5 alpha:1.0] setFill];
	UIRectFill(CGRectMake(0.0, 0.0, 1.0, 1.0));
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	for (UIButton *aButton in self.passageControls) {
	
		// Background color for default and disabled states.
		aButton.backgroundColor = backgroundColor;
		
		// Background color for buttons' highlighted state.
		[aButton setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
		
		aButton.layer.cornerRadius = 5.0f;
		
		// Make rounded corners appear for background images.
		aButton.layer.masksToBounds = YES;
		
		aButton.titleLabel.textAlignment = UITextAlignmentCenter;
	}
}

// The user's finished with the current set of bricks, so change them.
- (IBAction)changeCurrentBrickRange:(id)sender {

	// The pattern is brick1, brick2, bricks1-2, brick3, brick4, bricks3-4, bricks1-4, etc. So if the range is a single odd-numbered brick, then the new range is the next brick. If the range is an even-numbered brick, then the new range is the previous brick and that brick.
	// What about edge cases? Like the last brick in the entire passage is odd, or even?
	
	// Well, for the first brick: store/add the brick, then show what's after.
	// so this is still "under construction"
	Brick *aBrick = (Brick *)[NSEntityDescription insertNewObjectForEntityForName:@"Brick" inManagedObjectContext:self.managedObjectContext];
	
	// End index + 1 = length.
	aBrick.startingIndex = [NSNumber numberWithUnsignedInteger:self.currentTextShowing.length];
	[self.currentPassage addBricksObject:aBrick];
	
	// show next brick
	NSUInteger rankOfNextBrick = [self.currentPassage.rankOfCurrentStartingBrick unsignedIntegerValue] + 1;
	self.currentPassage.rankOfCurrentStartingBrick = [NSNumber numberWithUnsignedInteger:rankOfNextBrick];
	self.currentPassage.rankOfCurrentEndingBrick = self.currentPassage.rankOfCurrentStartingBrick;
	
	self.currentTextShowing = [NSMutableString stringWithString:[self.currentPassage stringFromStartOfCurrentBricks]];
	self.passageTextView.text = self.currentTextShowing;	
	[self enableOrDisableControls];
	
	// Save changes.
	NSError *error; 
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
	}
}

// Enable or disable the section/word controls, depending on what's available.
- (void)enableOrDisableControls {
	
	for (UIButton *aButton in self.passageControls) {
		aButton.enabled = YES;
	}
	
	// If nothing's showing, disable "hide section" and "hide word."
	if (self.currentTextShowing.length == 0) {
		self.hideClauseButton.enabled = NO;
		self.hideSectionButton.enabled = NO;
		self.hideWordButton.enabled = NO;
	} 
	// If everything's showing, disable "show section" and "show word."
	else if ([self.currentTextShowing isEqualToString:self.currentPassage.text]) {
		self.showClauseButton.enabled = NO;
		self.showSectionButton.enabled = NO;
		self.showWordButton.enabled = NO;
	}
	
	//testing
	self.hideSectionButton.enabled = NO;
	self.showSectionButton.enabled = NO;
}

// Hide the last clause. By "clause" we arbitrarily mean a sequence of at least three words ending with a punctuation mark. If just part of a clause is showing, then hide that clause. (So less than 3 words may be hidden.)
- (IBAction)hideClause:(id)sender {

	// Find the end of the current clause. Including the current index, scan forward to the next punctuation mark.
	NSCharacterSet *punctuationCharacterSet = [NSCharacterSet punctuationCharacterSet];
	NSUInteger startingIndex = self.currentTextShowing.length - 1;
	NSUInteger endingIndex = self.currentPassage.text.length - 1;
	NSRange searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
	
	NSRange targetRange = [self.currentPassage.text rangeOfCharacterFromSet:punctuationCharacterSet options:0 range:searchRange];
	
	// If not found, then the clause goes to the end of the passage.
	if (targetRange.location == NSNotFound) {
		targetRange = NSMakeRange(self.currentPassage.text.length - 1, 1);
	}
	
	// From the end of the clause, scan backward three words. Note the index for the end of the fourth word.
	
	NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSCharacterSet *nonWhiteSpaceCharacterSet = [whitespaceAndNewlineCharacterSet invertedSet];
	startingIndex = 0;
	for (int i = 0; i < 3; i++) {
	
		// Go backward to whitespace. Then go backward to non-whitespace. (So, end of word.)
		
		endingIndex = targetRange.location;
		searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
		targetRange = [self.currentPassage.text rangeOfCharacterFromSet:whitespaceAndNewlineCharacterSet options:NSBackwardsSearch range:searchRange];
		
		// If not found, then we know to go to the start of the passage.
		if (targetRange.location == NSNotFound) {
			break;
		}
		
		endingIndex = targetRange.location;
		searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
		targetRange = [self.currentPassage.text rangeOfCharacterFromSet:nonWhiteSpaceCharacterSet options:NSBackwardsSearch range:searchRange];
		
		// If not found, then we know to go to the start of the passage.
		if (targetRange.location == NSNotFound) {
			break;
		}
	}
	
	// If there's still room to search, then scan backward from the end of the fourth word, until the next punctuation mark, which is the end of the previous clause.
	if (targetRange.location != NSNotFound) {
		endingIndex = targetRange.location;
		searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
		targetRange = [self.currentPassage.text rangeOfCharacterFromSet:punctuationCharacterSet options:NSBackwardsSearch range:searchRange];
	}
	
	// Hide everything after the end of the previous clause.
	
	// If we found the end of the clause, we start one character later.
	if (targetRange.location != NSNotFound) {
		startingIndex = targetRange.location + 1;
	} else {
		startingIndex = 0;
	}
	
	endingIndex = self.currentTextShowing.length - 1;
	NSRange deletionRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
	[self.currentTextShowing deleteCharactersInRange:deletionRange];
	[self enableOrDisableControls];
	self.passageTextView.text = self.currentTextShowing;
}

/**
// Hide the last section/brick.
- (IBAction)hideSection:(id)sender {

	// Find the last character showing. Whichever brick that belows to, hide that brick's text.
	NSUInteger endingIndex = self.currentTextShowing.length - 1;
	NSArray *array = [self.currentPassage sortedBricks];
	Brick *lastBrickShowing;
	for (int i = 0; i < [array count]; i++) {
		if (endingIndex <= [self.currentPassage endingIndexForBrickAtBrickIndex:i]) {
			lastBrickShowing = (Brick *)[array objectAtIndex:i];
			break;
		}
	}
	NSUInteger location = [lastBrickShowing.startingIndex integerValue];
	
	// Ending index - location + 1 = ending index + 1 - location = length - location.
	NSUInteger length = self.currentTextShowing.length - location;
	
	NSRange deletionRange = NSMakeRange(location, length);
	[self.currentTextShowing deleteCharactersInRange:deletionRange];
	[self enableOrDisableControls];
	self.passageTextView.text = self.currentTextShowing;
}
*/

// Hide the last word, plus any whitespace before it.
- (IBAction)hideWord:(id)sender {
	
	// Find index of last whitespace.
	NSRange lastWhiteSpaceRange = [self.currentTextShowing rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch];
	
	// From that index (assuming whitespace found), search backward and find the index of the next non-whitespace. 
	NSRange endOfSecondToLastWordRange;
	if (lastWhiteSpaceRange.location != NSNotFound) {
		NSCharacterSet *nonWhiteSpaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
		endOfSecondToLastWordRange = [self.currentTextShowing rangeOfCharacterFromSet:nonWhiteSpaceCharacterSet options:NSBackwardsSearch range:NSMakeRange(0, lastWhiteSpaceRange.location + 1)];
	}
		
	// Delete everything past the end of the word. (Since the end is just non-whitespace, punctuation should be kept.)
	
	// If it's the first word, there may be no whitespace, and there is no second-to-last word.
	NSUInteger index;
	if ((lastWhiteSpaceRange.location == NSNotFound) || (endOfSecondToLastWordRange.location == NSNotFound)) {
		index = 0;
	} else {
		index = endOfSecondToLastWordRange.location + 1;
	}

	NSUInteger length = self.currentTextShowing.length - index;
	NSRange deletionRange = NSMakeRange(index, length);
	[self.currentTextShowing deleteCharactersInRange:deletionRange];
	[self enableOrDisableControls];
	self.passageTextView.text = self.currentTextShowing;
}

// The designated initializer.
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
	if (self = [super initWithNibName:nil bundle:nil]) {
	
        // Custom initialization.
		self.managedObjectContext = theManagedObjectContext;
    }
    return self;
}

// Show the next clause. By "clause" we mean the next set of words ending in a punctuation mark, with a minimum of 3 words. However, if part of a clause is already showing, show that entire clause (so less than 3 words may be added).
- (IBAction)showClause:(id)sender {
	
	// Find the end of the previous clause. Then, count forward 3 words. From the start of the third word, search for the next punctuation mark. That's the end of the clause to show.
	
	// End of previous clause.
	NSCharacterSet *punctuationCharacterSet = [NSCharacterSet punctuationCharacterSet];
	NSUInteger startingIndex = 0;
	NSUInteger endingIndex = self.currentTextShowing.length - 1;
	NSRange searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
	NSRange targetRange = [self.currentTextShowing rangeOfCharacterFromSet:punctuationCharacterSet options:NSBackwardsSearch range:searchRange];
	
	// From the end of the clause, go forward three words. Note the index for the start of the third word.
	
	// Start right after the end of the previous clause. If the end of previous clause was not found, then start at the beginning.
	if (targetRange.location != NSNotFound) {
		startingIndex = targetRange.location + 1;
	} else {
		startingIndex = 0;
	}
	
	NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSCharacterSet *nonWhiteSpaceCharacterSet = [whitespaceAndNewlineCharacterSet invertedSet];
	endingIndex = self.currentPassage.text.length - 1;
	
	// Search for non-whitespace for the start of the first word.
	searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
	targetRange = [self.currentPassage.text rangeOfCharacterFromSet:nonWhiteSpaceCharacterSet options:0 range:searchRange];
	
	if (targetRange.location != NSNotFound) {
		for (int i = 0; i < 2; i++) {
			
			// Search for whitespace.
			startingIndex = targetRange.location;
			searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
			targetRange = [self.currentPassage.text rangeOfCharacterFromSet:whitespaceAndNewlineCharacterSet options:0 range:searchRange];
			
			// If not found, then we know to go to the end of the passage.
			if (targetRange.location == NSNotFound) {
				break;
			}
			
			// Search for non-whitespace for the start of a word.
			startingIndex = targetRange.location;
			searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
			targetRange = [self.currentPassage.text rangeOfCharacterFromSet:nonWhiteSpaceCharacterSet options:0 range:searchRange];
			
			// If not found, then we know to go to the end of the passage.
			if (targetRange.location == NSNotFound) {
				break;
			}
		}
	}
	
	// If there's still more to search, then search for the next punctuation mark, starting from the start of the third word.
	if (targetRange.location != NSNotFound) {
		startingIndex = targetRange.location;
		searchRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
		targetRange = [self.currentPassage.text rangeOfCharacterFromSet:punctuationCharacterSet options:0 range:searchRange];
	}
	
	// If no punctuation found, then go to the end of the passage.
	if (targetRange.location == NSNotFound) {
		endingIndex = self.currentPassage.text.length - 1;
	} else {
		endingIndex = targetRange.location;
	}

	startingIndex = self.currentTextShowing.length;
	targetRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
	NSString *showClauseString = [self.currentPassage.text substringWithRange:targetRange];
	[self.currentTextShowing appendString:showClauseString];
	[self enableOrDisableControls];
	self.passageTextView.text = self.currentTextShowing;
}

- (IBAction)show3Words:(id)sender {
	[self showWord:(id)sender];
	if (self.showWordButton.enabled) {
		[self showWord:(id)sender];
	}
	if (self.showWordButton.enabled) {
		[self showWord:(id)sender];
	}
}

/**
// Show the next section/brick in the text. This could be the next entire brick, or the rest of the last brick (if only some of the words of that brick are showing).
- (IBAction)showSection:(id)sender {
	
	// Find the index of last character showing. If there's nothing showing, then show the first brick of the current bricks. Else, find the index's brick. If the index is at the end of its brick, then show the next brick. Otherwise, show the rest of its brick.
	
	Brick *desiredBrick;
	NSInteger endingIndex = self.currentTextShowing.length - 1;
	
	// If nothing showing, get first brick.
	if (endingIndex == -1) {
		desiredBrick = [[self.currentPassage sortedBricks] objectAtIndex:0];
	} else {
	
		// Find the first brick whose last character isn't shown.
		for (Brick *aBrick in [self.currentPassage sortedBricks]) {
			if (endingIndex < [aBrick endingIndex]) {
				desiredBrick = aBrick;
				break;
			}
		}
	}
	
	// Get the correct section of the brick.
	
	// Current ending index + 1 = length.
	NSUInteger startingIndex = self.currentTextShowing.length;

	NSUInteger length = [desiredBrick endingIndex] - startingIndex + 1;
	NSRange range = NSMakeRange(startingIndex, length);
	NSString *stringFromCurrentBricks = self.currentPassage.text;
	NSString *nextBrickString = [stringFromCurrentBricks substringWithRange:range];
	
	[self.currentTextShowing appendString:nextBrickString];
	[self enableOrDisableControls];
	self.passageTextView.text = self.currentTextShowing;
}
*/

// Show the next word in the text, plus punctuation.
- (IBAction)showWord:(id)sender {
	
	NSString *stringFromCurrentBricks = self.currentPassage.text;
	
	// Start scanning at last index + 1 = length - 1 + 1 = length.
	NSUInteger startingIndex = self.currentTextShowing.length;
	
	// We should be starting on whitespace, so find the next non-whitespace, which should be the start of the next word. From there, find the next whitespace, which should be one space after the end of the desired word. (Punctuation should be shown with the word.)
	NSUInteger length = stringFromCurrentBricks.length - startingIndex;
	NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
	NSRange startOfNextWordRange = [stringFromCurrentBricks rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:0 range:NSMakeRange(startingIndex, length)];
	startingIndex = startOfNextWordRange.location;
	length = stringFromCurrentBricks.length - startingIndex;
	NSRange startOfNextNextWhitespaceRange = [stringFromCurrentBricks rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(startingIndex, length)];
	
	// Get the substring for the next word (plus whitespace before it).
	
	// Index of text showing + 1 = length - 1 + 1 = length.
	startingIndex = self.currentTextShowing.length;
	
	// If we're looking for the last word, then there shouldn't be any white space after it.
	NSUInteger endingIndex;
	if (startOfNextNextWhitespaceRange.location == NSNotFound) {
		endingIndex = stringFromCurrentBricks.length - 1;
	} else {
		endingIndex = startOfNextNextWhitespaceRange.location - 1;
	}
	NSRange nextWordRange = NSMakeRange(startingIndex, endingIndex - startingIndex + 1);
	NSString *nextWordString = [stringFromCurrentBricks substringWithRange:nextWordRange];

	[self.currentTextShowing appendString:nextWordString];
	[self enableOrDisableControls];
	self.passageTextView.text = self.currentTextShowing;
}

// Update the instructions and the section shown.
- (void)updateView {
	self.instructions1TextView.text = @"Recite the given text, until you can do it from memory.";
	
	// Resize textview to fit instructions. Maintain the "Done" button's relative position.
	CGFloat oldHeight = self.instructions1TextView.frame.size.height;
	CGFloat newHeight = self.instructions1TextView.contentSize.height;
	CGRect frame = self.instructions1TextView.frame;
	frame.size.height = newHeight;
	self.instructions1TextView.frame = frame;
	//self.doneButton.frame = CGRectOffset(self.doneButton.frame, 0, newHeight - oldHeight);
	
	self.instructions2TextView.text = @"You can memorize more (or less) by using these controls. The controls can also be used to  use these controls for help, but keep practicing until you can recite the text from memory.";
	//self.instructions2TextView.text = @"You can use these controls for help, but keep practicing until you can recite the text from memory.";
	
	// Resize textview to fit content. Maintain buttons' relative position.
	oldHeight = self.instructions2TextView.frame.size.height;
	newHeight = self.instructions2TextView.contentSize.height;
	frame = self.instructions2TextView.frame;
	frame.size.height = newHeight;
	self.instructions2TextView.frame = frame;
	CGFloat yShift = newHeight - oldHeight;
	for (UIButton *aButton in self.passageControls) {
		aButton.frame = CGRectOffset(aButton.frame, 0, yShift);
	}
	
	self.instructions3TextView.text = @"When you've memorized a certain amount, make sure that text is showing, then tap this button...";
	
	// Resize textview to fit content. Maintain "Edit sections" button's relative position.
	oldHeight = self.instructions3TextView.frame.size.height;
	newHeight = self.instructions3TextView.contentSize.height;
	frame = self.instructions3TextView.frame;
	frame.size.height = newHeight;
	self.instructions3TextView.frame = frame;
	self.doneButton.frame = CGRectOffset(self.doneButton.frame, 0, newHeight - oldHeight);
	
	self.currentTextShowing = [NSMutableString stringWithString:[self.currentPassage stringFromStartOfCurrentBricks]];
	self.passageTextView.text = self.currentTextShowing;
	
	[self enableOrDisableControls];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.passageControls = [NSArray arrayWithObjects:self.hideClauseButton, self.hideSectionButton, self.hideWordButton, self.showClauseButton, self.showSectionButton, self.showWordButton, nil];
	
	[self changeAppearanceOfControls];

	// Show current passage.
	if (self.currentPassage != nil) {
		[self updateView];
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
	self.doneButton = nil;
	self.editSectionsButton = nil;
	self.hideClauseButton = nil;
	self.hideSectionButton = nil;
	self.hideWordButton = nil;
	self.instructions1TextView = nil;
	self.instructions2TextView = nil;
	self.instructions3TextView = nil;
	self.passageTextView = nil;
	self.showClauseButton = nil;
	self.showSectionButton = nil;
	self.showWordButton = nil;
}

- (void)dealloc {
	for (UIButton *aButton in self.passageControls) {
		[aButton release];
	}
	[currentPassage release];
	[currentTextShowing release];
	[doneButton release];
	[editSectionsButton release];
	[instructions1TextView release];
	[instructions2TextView release];
	[instructions3TextView release];
	[managedObjectContext release];
	[passageTextView release];
	[super dealloc];
}

@end
