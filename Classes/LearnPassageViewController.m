/*
 File: LearnPassageViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */
 
#import "LearnPassageViewController.h"
#import <QuartzCore/QuartzCore.h>

// Private category for private methods.
@interface LearnPassageViewController ()

@property (nonatomic, retain) NSArray *passageControls;
@property (nonatomic, retain) NSString *passageText;
@property (nonatomic, retain) NSTimer *repeatingTimer;
@property (nonatomic, assign) NSRange showableRange;

// Add the next word in the passage to the showable text. Include whitespace before the word and punctuation after.
- (void)addWord;

// Remove the last word from the showable text. Also remove any whitespace before the word. 
- (void)removeWord;

// Change the section/word controls so they look distinct from the standard round-rectangle button. These controls are used by the user differently than a standard UIButton.
- (void)stylizePassageControls;

// Enable/disable passage controls based on context. Change control labels based on context.
- (void)updateControlAppearance;

// Update what's seen. For example, in response to the showable text changing.
- (void)updateView;

@end

@implementation LearnPassageViewController

@synthesize addClauseButton, addWordButton, hideOrShowTextButton, removeClauseButton, removeWordButton, textView;
@synthesize passageControls, passageText, repeatingTimer, showableRange;

- (IBAction)addClause:(id)sender {
}

- (void)addWord {

	// Scan forward from the end of the showable text. Find the start of the next word by looking for non-whitespace. Then, find the end of the word by looking for whitespace and going back one.
	
	// Do this only if not at end of passage text yet.
	BOOL showableTextIsAtEndOfPassage = NO;
	if (self.showableRange.location + self.showableRange.length == self.passageText.length) {
		showableTextIsAtEndOfPassage = YES;
	}
	if (!showableTextIsAtEndOfPassage) {
		
		// Scan starts from end of showable text = location = (index of last showable char in passage text) + 1 = [(showableRange length) - (showableRange location) - 1] + 1 = length - location.
		NSUInteger location = self.showableRange.length - self.showableRange.location;
		
		// Scan ends at end of passage text. Length = (index of last char) - location + 1 = (index of last char) + 1 - location = (passage text length) - location.
		NSUInteger length = self.passageText.length - location;
		
		NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
		NSRange startOfNextWordRange = [self.passageText rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:0 range:NSMakeRange(location, length)];

		location = startOfNextWordRange.location;
		length = self.passageText.length - location;
		NSRange startOfNextNextWhitespaceRange = [self.passageText rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(location, length)];
		
		// Get new range for showable text. The end of the range is just before the whitespace found. However, if the added word is the last word, then no whitespace would have been found. In that case, the end of the range is the end of the passage text.
		NSUInteger endingLocation;
		if (startOfNextNextWhitespaceRange.location != NSNotFound) {
			endingLocation = startOfNextNextWhitespaceRange.location - 1;
		} else {
			endingLocation = self.passageText.length - 1;
		}
		NSUInteger lengthOfShowableText = endingLocation - self.showableRange.location + 1;
		self.showableRange = NSMakeRange(self.showableRange.location, lengthOfShowableText);
		[self updateView];
	} 
	
	// If there's nothing more to add, then stop the timer.
	else {
		[self stopARepeatingMethod:self];
	}

}

- (void)dealloc {
	[addClauseButton release];
	[addWordButton release];
	[hideOrShowTextButton release];
	[passageControls release];
	[passageText release];
	[removeClauseButton release];
	[removeWordButton release];
	[repeatingTimer release];
	[textView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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

- (IBAction)hideOrShowText:(id)sender {
}

- (IBAction)removeClause:(id)sender {
}

- (IBAction)removeWord {

	// Find the end of the previous word, and remove everything after that in the showable text. We assume the end of the showable text is a letter or punctuation, i.e., non-whitespace. So we'll scan backwards to the last whitespace, then backwards from there to the next non-whitespace.
	
	// Do this only if there is showable text.
	if (self.showableRange.length != 0) {
		NSUInteger lengthOfShowableText;
			
		// Find last whitespace.
		NSRange lastWhitespaceRange = [self.passageText rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:self.showableRange];
		
		// If whitespace was found, then find the next non-whitespace, scanning backwards. Else, only the first word was showable, so show nothing.
		if (lastWhitespaceRange.location != NSNotFound) {
			NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
			NSUInteger lengthOfShowableRangeToLastWhitespace = lastWhitespaceRange.location - self.showableRange.location + 1;
			NSRange showableRangeUpToLastWhitespace = NSMakeRange(self.showableRange.location, lengthOfShowableRangeToLastWhitespace);
			NSRange endOfSecondToLastWordRange = [self.passageText rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:NSBackwardsSearch range:showableRangeUpToLastWhitespace];
			
			// If the end of the previous word was found, show up to that. Else, only the first word was showable, so show nothing.
			if (endOfSecondToLastWordRange.location != NSNotFound) {
				lengthOfShowableText = endOfSecondToLastWordRange.location - self.showableRange.location + 1;
			} else {
				lengthOfShowableText = 0;
			}
		} else {
			lengthOfShowableText = 0;
		}

		self.showableRange = NSMakeRange(self.showableRange.location, lengthOfShowableText);
		[self updateView];
	}
	
	// If there's nothing to remove, then stop the timer.
	else {
		[self stopARepeatingMethod:self];
	}
}

- (IBAction)repeatAMethodBasedOnSender:(id)sender {
	
	// Determine the method to repeat.
	SEL aSelector;
	if (sender == self.addWordButton) {
		aSelector = @selector(addWord);
	} else if (sender == self.removeWordButton) {
		aSelector = @selector(removeWord);
	} else {
		NSLog(@"sender is unknown");
	}
		
	// Perform the method.
	[self performSelector:aSelector];

	// Repeat the method indefinitely, after an initial delay.
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0.6];
	NSTimer *aTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:0.1 target:self selector:aSelector userInfo:nil repeats:YES];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:aTimer forMode:NSDefaultRunLoopMode];
	[aTimer release];
	
	// Save a reference so the timer can be stopped later.
    self.repeatingTimer = aTimer;
	//NSLog(@"timer started");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (IBAction)stopARepeatingMethod:(id)sender {

	[self.repeatingTimer invalidate];
	self.repeatingTimer = nil;
	//NSLog(@"timer stopped");
}

- (void)stylizePassageControls {
	
	// Light grey.
	UIColor *backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
	
	// Make a 1-point rectangle filled with light purple.
	UIGraphicsBeginImageContext(CGSizeMake(1.0, 1.0));
	[[UIColor colorWithRed:0.9 green:0.7 blue:0.9 alpha:1.0] setFill];
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

- (void)updateControlAppearance {

	for (UIButton *aButton in self.passageControls) {
		aButton.enabled = YES;
	}
	
	// If nothing is showable, disable "subtract" controls.
	if (self.showableRange.length == 0) {
		self.removeClauseButton.enabled = NO;
		self.removeWordButton.enabled = NO;
		//NSLog(@"\"remove\" controls disabled");
	} 
	
	// Else, if everything is showable, disable "add" controls.
	else if (self.passageText.length == self.showableRange.location + self.showableRange.length) {
		self.addClauseButton.enabled = NO;
		self.addWordButton.enabled = NO;
		//NSLog(@"\"add\" controls disabled");
	}
	
	// change label for "show/hide text"?
}

- (void)updateView {
	
	// Make sure the text is showing correctly. Make sure the controls are enabled/disabled appropriately.
	// add "if show-boolean"...
	self.textView.text = [self.passageText substringWithRange:self.showableRange];
	[self updateControlAppearance];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	self.passageControls = [NSArray arrayWithObjects:self.addClauseButton, self.addWordButton, self.hideOrShowTextButton, self.removeClauseButton, self.removeWordButton, nil];
	[self stylizePassageControls];
	self.passageText = @"This is a test. Later, this should be the selected passage.";
	//testing; later showableRange should start with enough clauses to be 10 words.
	self.showableRange = NSMakeRange(0, 0);
	
	[self updateView];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.addClauseButton = nil;
	self.addWordButton = nil;
	self.hideOrShowTextButton = nil;
	self.removeClauseButton = nil;
	self.removeWordButton = nil;
	self.textView = nil;
	
	// Release any data that is recreated in viewDidLoad.
	self.passageControls = nil;
	// passageText and showableRange are still in dev
}

@end
