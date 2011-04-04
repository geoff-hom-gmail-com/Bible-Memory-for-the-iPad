/*
 File: LearnPassageViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */
 
#import "LearnPassageViewController.h"
#import "Passage.h"
#import <QuartzCore/QuartzCore.h>

// Characters that mark the end of a clause.
NSString *clauseCharactersString = @",.;";

// Label for control when text is showing.
NSString *hideTextLabel = @"Hide Text";

// Label for control when text is hidden.
NSString *showTextLabel = @"Show Text";

// Private category for private methods.
@interface LearnPassageViewController ()

// For storing a reference to the passage being studied.
@property (nonatomic, retain) Passage *passage;

// For grouping the controls that manipulate visibility of the passage text.
@property (nonatomic, retain) NSArray *passageControls;

// For repeating the current control.
@property (nonatomic, retain) NSTimer *repeatingTimer;

// The range of the passage's text that should be shown, if the "Show Text" control is on.
@property (nonatomic, assign) NSRange showableRange;

// Whether the showable text is visible.
@property (nonatomic, assign) BOOL showShowableText;

// Add the next clause in the passage to the showable text. Include whitespace before the clause. By "clause" we mean the next set of 3+ words ending in a punctuation mark. However, if part of a clause is already showing, add that entire clause (so less than 3 words may be added).
// I suppose by clause I really mean the text (including whitespace) between two punctuation marks, plus the ending punctuation mark. Revise descriptions once I figure out if I really want a 3-word minimum.
- (void)addClause;

// Add the next word in the passage to the showable text. Include whitespace before the word and punctuation after.
- (void)addWord;

// Remove the last clause from the showable text. (See addClause for our definition of a clause.) If only part of a clause is showing, then hide that clause.
- (void)removeClause;

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
@synthesize passage, passageControls, repeatingTimer, showableRange, showShowableText;

- (void)addClause {

	// Find the end of the previous clause. Then, count forward 3 words. From the start of the third word, search for the next punctuation mark. That's the end of the clause to show.
	
	// Do this only if not at end of passage text yet.
	NSString *passageText = self.passage.text;
	BOOL showableTextIsAtEndOfPassage = NO;
	if (self.showableRange.location + self.showableRange.length == passageText.length) {
		showableTextIsAtEndOfPassage = YES;
	}
	if (!showableTextIsAtEndOfPassage) {
	
		// Find the end of the previous clause in the showable text. The end is a punctuation mark. If found, use that. Else, assume it's right before the showable text.
		NSCharacterSet *punctuationCharacterSet = [NSCharacterSet characterSetWithCharactersInString:clauseCharactersString];
		NSRange endOfPreviousClauseRange = [passageText rangeOfCharacterFromSet:punctuationCharacterSet options:NSBackwardsSearch range:self.showableRange];
		NSInteger endOfPreviousClause;
		if (endOfPreviousClauseRange.location != NSNotFound) {
			endOfPreviousClause = endOfPreviousClauseRange.location;
		} else {
			endOfPreviousClause = -1;
		}

		// From the end of the clause, go forward three words. Keep the index for the start of the third word.
		
		// Search for non-whitespace for the start of the first word.
		NSUInteger location = endOfPreviousClause + 1;
		NSUInteger length = passageText.length - location;
		NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSCharacterSet *nonWhitespaceCharacterSet = [whitespaceAndNewlineCharacterSet invertedSet];
		NSRange startOfWordRange = [passageText rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:0 range:NSMakeRange(location, length)];

		// Search alternately for whitespace and then non-whitespace to find the start of the second and third words.
		BOOL addToEndOfPassage = NO;
		if (startOfWordRange.location != NSNotFound) {
// skipping this for now, so clauses can be 1 word. 3-word minimum was weird when adding more than a sentence, at least. if I don't have a minimum, then I also don't have to search backward in the beginning? i won't even have to search for whitespace or non-whitespace; just punctuation. actually, I could search first for punctuation, and then if it's not a comma, that's it. if it's a comma, we could do the rest.
//			for (int i = 0; i < 2; i++) {
//				
//				// Search for whitespace.
//				location = startOfWordRange.location;
//				length = self.passageText.length - location;
//				NSRange startOfWhitespaceRange = [self.passageText rangeOfCharacterFromSet:whitespaceAndNewlineCharacterSet options:0 range:NSMakeRange(location, length)];
//				
//				// If not found, then we add up to the end of the passage.
//				if (startOfWhitespaceRange.location == NSNotFound) {
//					addToEndOfPassage = YES;
//					break;
//				}
//				
//				// Search for non-whitespace for the start of a word.
//				location = startOfWhitespaceRange.location;
//				length = self.passageText.length - location;
//				startOfWordRange = [self.passageText rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:0 range:NSMakeRange(location, length)];
//				
//				// If not found, then we add up to the end of the passage.
//				if (startOfWordRange.location == NSNotFound) {
//					addToEndOfPassage = YES;
//					break;
//				}
//			}
		} else {
			addToEndOfPassage = YES;
		}
		
		// If there's still more to search, then search for the next punctuation mark, starting from the start of the third word.
		NSUInteger endOfClause;
		if (!addToEndOfPassage) {
			location = startOfWordRange.location;
			length = passageText.length - location;
			NSRange nextPunctuationRange = [passageText rangeOfCharacterFromSet:punctuationCharacterSet options:0 range:NSMakeRange(location, length)];
			if (nextPunctuationRange.location != NSNotFound) {
				endOfClause = nextPunctuationRange.location;
			} else {
				addToEndOfPassage = YES;
			}
		}
		
		// If ultimately no punctuation was found, then add up to the end of the passage.
		if (addToEndOfPassage) {
			endOfClause = passageText.length - 1;
		}

		NSUInteger lengthOfShowableText = endOfClause - self.showableRange.location + 1;
		self.showableRange = NSMakeRange(self.showableRange.location, lengthOfShowableText);
		[self updateView];
	}
	
	// If there's nothing more to add, then stop the timer.
	else {
		[self stopARepeatingMethod:self];
	}
}

- (void)addWord {

	// Scan forward from the end of the showable text. Find the start of the next word by looking for non-whitespace. Then, find the end of the word by looking for whitespace and going back one.
	
	// Do this only if not at end of passage text yet.
	NSString *passageText = self.passage.text;
	BOOL showableTextIsAtEndOfPassage = NO;
	if (self.showableRange.location + self.showableRange.length == passageText.length) {
		showableTextIsAtEndOfPassage = YES;
	}
	if (!showableTextIsAtEndOfPassage) {
		
		// Scan starts from end of showable text = location = (index of last showable char in passage text) + 1 = [(showableRange length) - (showableRange location) - 1] + 1 = length - location.
		NSUInteger location = self.showableRange.length - self.showableRange.location;
		
		// Scan ends at end of passage text. Length = (index of last char) - location + 1 = (index of last char) + 1 - location = (passage text length) - location.
		NSUInteger length = passageText.length - location;
		
		NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
		NSRange startOfNextWordRange = [passageText rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:0 range:NSMakeRange(location, length)];

		location = startOfNextWordRange.location;
		length = passageText.length - location;
		NSRange startOfNextNextWhitespaceRange = [passageText rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(location, length)];
		
		// Get new range for showable text. The end of the range is just before the whitespace found. However, if the added word is the last word, then no whitespace would have been found. In that case, the end of the range is the end of the passage text.
		NSUInteger endingLocation;
		if (startOfNextNextWhitespaceRange.location != NSNotFound) {
			endingLocation = startOfNextNextWhitespaceRange.location - 1;
		} else {
			endingLocation = passageText.length - 1;
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

- (IBAction)hideOrShowText:(id)sender {
	
	if ([self.hideOrShowTextButton.titleLabel.text isEqualToString:hideTextLabel]) {
		self.showShowableText = NO;
	} else {
		self.showShowableText = YES;
	}
	[self updateView];
}

- (id)initWithPassage:(Passage *)thePassage {

	self = [super initWithNibName:nil bundle:nil];
	if (self) {
	
        // Custom initialization.
		self.passage = thePassage;
    }
    return self;
}

- (void)removeClause {

	// I'm going to do this first assuming there's no minimum for a clause, so it can be just one word. If I want the minimum later, I'll look again at LearnTextViewController.
	
	// Remove something only if there's something to remove. Else, stop any repeating timer.
	BOOL stopTimer = NO;
	if (self.showableRange.length != 0) {
	
		// Find the end of the previous clause. (Start at one character from the end and scan backwards.) 
		NSUInteger location = self.showableRange.location;
		NSUInteger length = self.showableRange.length - 1;
		NSCharacterSet *punctuationCharacterSet = [NSCharacterSet characterSetWithCharactersInString:clauseCharactersString];
		NSString *showableText = [self.passage.text substringWithRange:self.showableRange];
		NSRange endOfPreviousClauseRange = [showableText rangeOfCharacterFromSet:punctuationCharacterSet options:NSBackwardsSearch range:NSMakeRange(location, length)];
		
		// If the end of the previous clause was found, show up to that. Else, show up to the start (i.e., nothing).
		NSUInteger lengthOfShowableText;
		if (endOfPreviousClauseRange.location != NSNotFound) {
			lengthOfShowableText = endOfPreviousClauseRange.location - self.showableRange.location + 1;
		} else {
			lengthOfShowableText = 0;
			stopTimer = YES;
		}
		self.showableRange = NSMakeRange(self.showableRange.location, lengthOfShowableText);
		[self updateView];
	} else {
		stopTimer = YES;
	}
	
	if (stopTimer) {
		[self stopARepeatingMethod:self];
	}
}

- (void)removeWord {

	// Find the end of the previous word, and remove everything after that in the showable text. We assume the end of the showable text is a letter or punctuation, i.e., non-whitespace. So we'll scan backwards to the last whitespace, then backwards from there to the next non-whitespace.
	
	// Do this only if there is showable text.
	if (self.showableRange.length != 0) {
		NSUInteger lengthOfShowableText;
			
		// Find last whitespace.
		// WARNING: do I want to search the passage text or the showable text? can check once I have showable text that starts after the beginning of the passage text.
		NSString *passageText = self.passage.text;
		NSRange lastWhitespaceRange = [passageText rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:self.showableRange];
		
		// If whitespace was found, then find the next non-whitespace, scanning backwards. Else, only the first word was showable, so show nothing.
		if (lastWhitespaceRange.location != NSNotFound) {
			NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
			NSUInteger lengthOfShowableRangeToLastWhitespace = lastWhitespaceRange.location - self.showableRange.location + 1;
			NSRange showableRangeUpToLastWhitespace = NSMakeRange(self.showableRange.location, lengthOfShowableRangeToLastWhitespace);
			NSRange endOfSecondToLastWordRange = [passageText rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:NSBackwardsSearch range:showableRangeUpToLastWhitespace];
			
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
	if (sender == self.addClauseButton) {
		aSelector = @selector(addClause);
	} else if (sender == self.addWordButton) {
		aSelector = @selector(addWord);
	} else if (sender == self.removeClauseButton) {
		aSelector = @selector(removeClause);
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
	
	// Toggle hide/show text control label.
	if (showShowableText) {
		[self.hideOrShowTextButton setTitle:hideTextLabel forState:UIControlStateNormal];
	} else {
		[self.hideOrShowTextButton setTitle:showTextLabel forState:UIControlStateNormal];
	}
	
	// If nothing is showable, disable "subtract" controls.
	if (self.showableRange.length == 0) {
		self.removeClauseButton.enabled = NO;
		self.removeWordButton.enabled = NO;
	} 
	
	// Else, if everything is showable, disable "add" controls.
	else if (self.passage.text.length == self.showableRange.location + self.showableRange.length) {
		self.addClauseButton.enabled = NO;
		self.addWordButton.enabled = NO;
		//NSLog(@"\"add\" controls disabled");
	}
}

- (void)updateView {
	
	// Make sure the text is showing correctly. Make sure the controls are enabled/disabled appropriately.
	if (self.showShowableText) {
		self.textView.text = [self.passage.text substringWithRange:self.showableRange];
	} else {
		self.textView.text = @"";
	}
	[self updateControlAppearance];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	self.passageControls = [NSArray arrayWithObjects:self.addClauseButton, self.addWordButton, self.hideOrShowTextButton, self.removeClauseButton, self.removeWordButton, nil];
	[self stylizePassageControls];
	
	//testing; later showableRange should start with enough clauses to be 10 words. 3 words? 10 letters?
	self.showableRange = NSMakeRange(0, 0);
	[self addClause];
	
	self.showShowableText = YES;
	
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
	// showableRange still in dev
}

@end
