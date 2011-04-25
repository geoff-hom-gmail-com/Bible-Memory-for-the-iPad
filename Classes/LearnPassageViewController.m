/*
 File: LearnPassageViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */
 
#import "LearnPassageViewController.h"
#import "Passage.h"
#import <QuartzCore/QuartzCore.h>

// Characters that mark the end of a clause. The dash is an en-dash, not a hyphen.
NSString *clauseCharactersString = @".?!,;–";

// For specifying to add/remove a clause.
NSString *clauseUnitName = @"clause";

// For specifying to remove a first-letter word.
NSString *firstLetterUnitName = @"firstLetter";

// Label for reference-text control when text is visible.
NSString *hideReferenceTextLabel = @"Hide Reference Text";

// Label for control when text is showing.
NSString *hideTextLabel = @"Hide Text";

// Characters that mark the end of a sentence.
NSString *sentenceCharactersString = @".?!";

// For specifying to add/remove a sentence.
NSString *sentenceUnitName = @"sentence";

// Label for reference-text control when text is hidden.
NSString *showReferenceTextLabel = @"Show Reference Text";

// Label for control when text is hidden.
NSString *showTextLabel = @"Show Text";

// For specifying to add/remove a word.
NSString *wordUnitName = @"word";

// Private category for private methods.
@interface LearnPassageViewController ()

// The range of the passage's text that should be shown as first letters.
@property (nonatomic, assign) NSRange firstLetterRange;

// A portion of the passage's text reduced to first letters (including punctuation and whitespace).
@property (nonatomic, retain) NSString *firstLetterText;

// For storing a reference to the passage being studied.
@property (nonatomic, retain) Passage *passage;

// For grouping the controls that manipulate visibility of the passage text.
@property (nonatomic, retain) NSArray *passageControls;

// The previous first-letter range. (For undo.)
@property (nonatomic, assign) NSRange previousFirstLetterRange;

// The previous showable range. (For undo.)
@property (nonatomic, assign) NSRange previousShowableRange;

// For repeating the current control.
@property (nonatomic, retain) NSTimer *repeatingTimer;

// For starting the repeating timer after an initial delay.
@property (nonatomic, retain) NSTimer *scheduledTimer;

// The range of the passage's text that should be shown, if the "Show Text" control is on.
@property (nonatomic, assign) NSRange showableRange;

// Whether the reference text is visible.
@property (nonatomic, assign) BOOL showReferenceText;

// Add the next clause from the passage's text to the range. The new range is returned. By "next clause," we mean up to the next clause-ending punctuation mark. (E.g., a semi-colon, but not an apostraphe.) Note that a comma-delimited list will be several clauses (e.g., in "love, joy, peace, patience and kindness," the first clause is simply "love,".) I'm not sure how to easily distinguish between a list and a real clause. 
- (NSRange)addClause:(NSRange)range;

// Add the next sentence from the passage's text to the range. The new range is returned.
- (NSRange)addSentence:(NSRange)range;

// Add the next text unit from the passage text. If not in first-letter mode, add to the regular range. Else, add to the first-letter range.
- (void)addTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode;

// Add the next word from the passage's text to the range. The new range is returned.
- (NSRange)addWord:(NSRange)range;

// Return the working text by combining the showable range and the first-letter range.
- (NSString *)assembleWorkingText;

// Extend the given range by searching in the passage's text. Return the range extended to the next instance of any of the characters in the given string.
- (NSRange)extendRange:(NSRange)range bySearchingForCharactersInString:(NSString *)string;

// Remove all letters from the string, except for first letters. (So retain whitespace, punctuation, etc.)
- (NSString *)reduceStringToFirstLetters:(NSString *)string;

// Remove the last clause from the range. The new range is returned. See addClause: for our definition of a clause. If only part of a clause is showing, then that becomes the clause to remove. 
- (NSRange)removeClause:(NSRange)range;

// Remove the last sentence from the range. The new range is returned. If only part of a sentence is showing, then that becomes the sentence to remove.
- (NSRange)removeSentence:(NSRange)range;

// Remove the text unit from a range. For sentences and clauses, if the first-letter range is greater than the showable range, remove from the first-letter range. For words, remove from the showable range. For first letters, remove from the first-letter range. 
- (void)removeTextUnit:(NSString *)textUnit;

// Remove the last word from the range. The new range is returned.
- (NSRange)removeWord:(NSRange)range;

// Start the current repeating timer, if any. The repeating timer is not necessarily the timer passed in.
- (void)startRepeatingTimer:(NSTimer *)theTimer;

// Change the section/word controls so they look distinct from the standard round-rectangle button. These controls are used by the user differently than a standard UIButton.
- (void)stylizePassageControls;

// Enable/disable passage controls based on context. Change control labels based on context.
- (void)updateControlAppearance;

// Update the first-letter text to span the new range.
- (void)updateFirstLetterRangeAndText:(NSRange)newRange;

// Update what's seen. For example, in response to the showable text changing.
- (void)updateView;

@end

@implementation LearnPassageViewController

@synthesize addClauseButton, addFirstLetterClauseButton, addFirstLetterButton, addFirstLetterSentenceButton, addSentenceButton, addWordButton, hideOrShowReferenceTextButton, referenceTextView, removeAllButton, removeClauseButton, removeFirstLetterSentenceButton, removeFirstLetterButton, removeSentenceButton, removeWordButton, undoRemoveAllButton, workingTextView;
@synthesize firstLetterRange, firstLetterText, passage, passageControls, previousFirstLetterRange, previousShowableRange, repeatingTimer, scheduledTimer, showableRange, showReferenceText;

- (NSRange)addClause:(NSRange)range {

	range = [self extendRange:range bySearchingForCharactersInString:clauseCharactersString];
	return range;
}

- (NSRange)addSentence:(NSRange)range {

	range = [self extendRange:range bySearchingForCharactersInString:sentenceCharactersString];
	return range;
}

- (void)addTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode {
	
	NSRange aRange;
	if (!firstLetterMode) {
		aRange = self.showableRange;
	} else {
		aRange = self.firstLetterRange;
	}
	if ([textUnit isEqualToString:clauseUnitName]) {
		aRange = [self addClause:aRange];
	} else if ([textUnit isEqualToString:sentenceUnitName]) {
		aRange = [self addSentence:aRange];
	} else if ([textUnit isEqualToString:wordUnitName]) {
		aRange = [self addWord:aRange];
	} else {
		NSLog(@"Warning: Text unit not found: %@", textUnit);
	}
	
	if (!firstLetterMode) {
		self.showableRange = aRange;
		
		// If the first-letter range is less than the showable range, then increase the first-letter range.
		if (self.firstLetterRange.length < self.showableRange.length) {
			[self updateFirstLetterRangeAndText:self.showableRange];
		} 
	} else {
		[self updateFirstLetterRangeAndText:aRange];
	}
	
	[self updateView];
	
	// If there's nothing left to add, then stop any repeating timer. Words can be added until the end of the passage; ditto for first-letter words.
	if (NSMaxRange(aRange) == self.passage.text.length) {
		[self stopARepeatingMethod:self];
	} 
}

- (NSRange)addWord:(NSRange)range {

	// Scan forward from the end of the range. Find the start of the next word by scanning past whitespace. Then, find the end of the word/punctuation by scanning up to whitespace and going back one.
	
	// Scan past whitespace.
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *sourceText = [self.passage.text substringFromIndex:NSMaxRange(range)];
	NSScanner *scanner = [NSScanner scannerWithString:sourceText];
	[scanner setCharactersToBeSkipped:nil];
	[scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
	
	// Scan from non-whitespace until next whitespace.
	[scanner scanUpToCharactersFromSet:whitespaceCharacterSet intoString:NULL];
	
	// If we found whitespace, we want the location minus one. But if we're at the end of the string, we want the current location.
	NSUInteger endingLocation;
	if ([scanner isAtEnd] == NO) {
		endingLocation = [scanner scanLocation] - 1;
	} else {
		endingLocation = [scanner scanLocation];
	}

	NSUInteger newLength = endingLocation + NSMaxRange(range) + 1;
	range.length = newLength;
	return range;
}

- (NSString *)assembleWorkingText {

	// Start with text from the showable range.
	NSString *showableText = [self.passage.text substringWithRange:self.showableRange];
	
	// If there are first letters beyond the showable range, then add those.
	NSString *workingText;
	if (self.showableRange.length < self.firstLetterRange.length) {
	
		// We need to find the first-letter text that is not represented in the showable text. We'll scan through "words" in both texts simultaneously. When we're at the end of the showable text, we should also be at the location in the first-letter text that we want to start at.
		NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSScanner *showableTextScanner = [NSScanner scannerWithString:showableText];
		[showableTextScanner setCharactersToBeSkipped:nil];
		NSScanner *firstLetterTextScanner = [NSScanner scannerWithString:self.firstLetterText];
		[firstLetterTextScanner setCharactersToBeSkipped:nil];
				
		while ([showableTextScanner isAtEnd] == NO) {
		
			// Scan past whitespace.
			[showableTextScanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
			[firstLetterTextScanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
			
			// Scan from non-whitespace until next whitespace.
			[showableTextScanner scanUpToCharactersFromSet:whitespaceCharacterSet intoString:NULL];
			[firstLetterTextScanner scanUpToCharactersFromSet:whitespaceCharacterSet intoString:NULL];
		}
		
		NSUInteger location = [firstLetterTextScanner scanLocation];
		NSUInteger length = self.firstLetterText.length - location;
		NSRange remainingFirstLetterRange = NSMakeRange(location, length);
		NSString *remainingFirstLetterText = [self.firstLetterText substringWithRange:remainingFirstLetterRange];
		workingText = [showableText stringByAppendingString:remainingFirstLetterText];
	} else {
		workingText = showableText;
	}
	
	return workingText;
}

- (void)dealloc {
	
	NSArray *anArray = [NSArray arrayWithObjects: addClauseButton, addFirstLetterButton, addFirstLetterClauseButton, addFirstLetterSentenceButton, addSentenceButton, addWordButton, firstLetterText, hideOrShowReferenceTextButton, passage, passageControls, referenceTextView, removeAllButton, removeClauseButton, removeSentenceButton, removeWordButton, repeatingTimer, undoRemoveAllButton, workingTextView, nil];
	for (NSObject *anObject in anArray) {
		[anObject release];
	}
    [super dealloc];
}

- (void)didReceiveMemoryWarning {

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (NSRange)extendRange:(NSRange)range bySearchingForCharactersInString:(NSString *)string {
	
	// Find the next instance of a character in the string.
	NSString *text = self.passage.text;
	NSUInteger location = range.length;
	NSUInteger length = text.length - location;
	NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
	NSRange characterRange = [text rangeOfCharacterFromSet:characterSet options:0 range:NSMakeRange(location, length)];
	
	// If found, show up to (and including) that. Else, show up to the end.
	NSUInteger lengthOfShowableText;
	if (characterRange.location != NSNotFound) {
		lengthOfShowableText = characterRange.location - range.location + 1;
	} else {
		lengthOfShowableText = text.length - range.location;
	}
	range.length = lengthOfShowableText;
	return range;
}

- (IBAction)hideOrShowReferenceText:(id)sender {
	
	if ([self.hideOrShowReferenceTextButton.titleLabel.text isEqualToString:hideReferenceTextLabel]) {
		self.showReferenceText = NO;
	} else {
		self.showReferenceText = YES;
	}
	[self updateView];
}

- (id)initWithPassage:(Passage *)thePassage {

	self = [super initWithNibName:nil bundle:nil];
	if (self) {
	
        // Custom initialization.
		self.passage = thePassage;
		self.firstLetterText = @"";
    }
    return self;
}

- (NSString *)reduceStringToFirstLetters:(NSString *)string {

	// Scan forward to the first letter, storing up to that. Store the first letter. Skip until whitespace/clause-end. If clause-end, store that. Repeat until end of string.
	
	// If this function is too slow, we could make these once and store them.
	NSCharacterSet *letterCharacterSet = [NSCharacterSet letterCharacterSet];
	NSCharacterSet *clauseCharacterSet = [NSCharacterSet characterSetWithCharactersInString:clauseCharactersString];
	NSMutableCharacterSet *whitespaceAndClauseMutableCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
	[whitespaceAndClauseMutableCharacterSet formUnionWithCharacterSet:clauseCharacterSet];
	NSCharacterSet *whitespaceAndClauseCharacterSet = [whitespaceAndClauseMutableCharacterSet copy];
	
	NSScanner *scanner = [NSScanner scannerWithString:string];
	[scanner setCharactersToBeSkipped:nil];
	
	BOOL anyCharactersScanned;
	NSString *bufferString;
	NSString *firstLetter;
	NSMutableString *mutableString = [NSMutableString stringWithCapacity:50];
	while ([scanner isAtEnd] == NO) {
	
		anyCharactersScanned = [scanner scanUpToCharactersFromSet:letterCharacterSet intoString:&bufferString];
		if (anyCharactersScanned) {
			[mutableString appendString:bufferString];
		}
		
		firstLetter = [string substringWithRange:NSMakeRange(scanner.scanLocation, 1)];
		[mutableString appendString:firstLetter];
		
		[scanner scanUpToCharactersFromSet:whitespaceAndClauseCharacterSet intoString:NULL];
		anyCharactersScanned = [scanner scanCharactersFromSet:clauseCharacterSet intoString:&bufferString];
		if (anyCharactersScanned) {
			[mutableString appendString:bufferString];
		}
	}
	
	[whitespaceAndClauseCharacterSet release];
	return [[mutableString copy] autorelease];
}

- (IBAction)removeAllText:(id)sender {
	
	self.previousShowableRange = self.showableRange;
	self.showableRange = NSMakeRange(self.showableRange.location, 0);
	
	self.previousFirstLetterRange = self.firstLetterRange;
	[self updateFirstLetterRangeAndText:self.showableRange];
	
	[self updateView];
}

- (NSRange)removeClause:(NSRange)range {

	// Find the end of the previous clause. (Start at one character from the end and scan backwards.) 
	NSUInteger location = range.location;
	NSUInteger length = range.length - 1;
	NSCharacterSet *clauseCharacterSet = [NSCharacterSet characterSetWithCharactersInString:clauseCharactersString];
	NSString *showableText = [self.passage.text substringWithRange:range];
	NSRange endOfPreviousClauseRange = [showableText rangeOfCharacterFromSet:clauseCharacterSet options:NSBackwardsSearch range:NSMakeRange(location, length)];
	
	// If found, show up to that. Else, show up to the start (i.e., nothing).
	NSUInteger lengthOfShowableText;
	if (endOfPreviousClauseRange.location != NSNotFound) {
		lengthOfShowableText = endOfPreviousClauseRange.location - range.location + 1;
	} else {
		lengthOfShowableText = 0;
	}
	range.length = lengthOfShowableText;
	return range;
}

// Note: this code is almost the same as in removeClause:. Group it (see addSentence, etc.) if I include another type of text unit.
- (NSRange)removeSentence:(NSRange)range {

	// Find the end of the previous text unit. (Start at one character from the end and scan backwards.) 
	NSUInteger location = range.location;
	NSUInteger length = range.length - 1;
	NSCharacterSet *aCharacterSet = [NSCharacterSet characterSetWithCharactersInString:sentenceCharactersString];
	NSString *showableText = [self.passage.text substringWithRange:range];
	NSRange endOfPreviousUnitRange = [showableText rangeOfCharacterFromSet:aCharacterSet options:NSBackwardsSearch range:NSMakeRange(location, length)];
	
	// If found, show up to that. Else, show up to the start (i.e., nothing).
	NSUInteger lengthOfShowableText;
	if (endOfPreviousUnitRange.location != NSNotFound) {
		lengthOfShowableText = endOfPreviousUnitRange.location - range.location + 1;
	} else {
		lengthOfShowableText = 0;
	}
	range.length = lengthOfShowableText;
	return range;	
}

- (void)removeTextUnit:(NSString *)textUnit {

	NSRange aRange;
	BOOL firstLettersVisible;
	if (self.firstLetterRange.length > self.showableRange.length) {
		firstLettersVisible = YES;
	} else {
		firstLettersVisible = NO;
	}

	// Sentences and clauses.
	if ([textUnit isEqualToString:sentenceUnitName] || [textUnit isEqualToString:clauseUnitName]) {
		if (firstLettersVisible) {
			aRange = self.firstLetterRange;
		} else {
			aRange = self.showableRange;
		}
		if ([textUnit isEqualToString:sentenceUnitName]) {
			aRange = [self removeSentence:aRange];
		} else {
			aRange = [self removeClause:aRange];
		}
		
		// If first letters were visible, we reduce the first-letter range. Else, we want the first-letter range to match the showable range. So either way, the first-letter range is updated.
		[self updateFirstLetterRangeAndText:aRange];
		
		// If the first-letter range became less than the showable range, make the showable range match.
		if (self.firstLetterRange.length < self.showableRange.length) {
			self.showableRange = self.firstLetterRange;
		}
	} 
	
	// Words and first letters.
	else {
		if ([textUnit isEqualToString:wordUnitName]) {
			self.showableRange = [self removeWord:self.showableRange];
			
			// If first letters were not visible, then they should still not be visible, so make the first-letter range match the showable range.
			if (!firstLettersVisible) {
				
				[self updateFirstLetterRangeAndText:self.showableRange];
			} 
		} else {
			
			// The first-letter range is based on the full text, so we want to remove a full word.
			aRange = [self removeWord:self.firstLetterRange];
			[self updateFirstLetterRangeAndText:aRange];
		}
	}
	
	// If there's nothing left to remove, then stop any repeating timer. For sentences and clauses, this is when the first-letter range is 0. For words, it's the showable range. For first letters, it's when the first-letter range matches the showable range.
	BOOL stopRepeatingTimer = NO;
	if (self.firstLetterRange.length == 0) {
		stopRepeatingTimer = YES;
	} else if ([textUnit isEqualToString:wordUnitName] && (self.showableRange.length == 0) ) {
		stopRepeatingTimer = YES;
	} else if ([textUnit isEqualToString:firstLetterUnitName] && (self.firstLetterRange.length == self.showableRange.length) ) {
		stopRepeatingTimer = YES;
	}
	if (stopRepeatingTimer) {
		//NSLog(@"removeTextUnit: stop repeating timer");
		[self stopARepeatingMethod:self];
	}
	
	[self updateView];
}

- (NSRange)removeWord:(NSRange)range {

	// Find the end of the previous word, and remove everything after that in the showable text. We assume the end of the showable text is a letter or punctuation, i.e., non-whitespace. So we'll scan backwards to the last whitespace, then backwards from there to the next non-whitespace.
			
	// Find last whitespace.
	NSString *text = self.passage.text;
	NSRange lastWhitespaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:range];
	
	// If whitespace was found, then find the next non-whitespace, scanning backwards. Else, only the first word was showable, so show nothing.
	NSUInteger lengthOfShowableText;
	if (lastWhitespaceRange.location != NSNotFound) {
		NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
		NSUInteger lengthOfShowableRangeToLastWhitespace = lastWhitespaceRange.location - range.location + 1;
		NSRange showableRangeUpToLastWhitespace = NSMakeRange(range.location, lengthOfShowableRangeToLastWhitespace);
		NSRange endOfSecondToLastWordRange = [text rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:NSBackwardsSearch range:showableRangeUpToLastWhitespace];
		
		// If the end of the previous word was found, show up to that. Else, only the first word was showable, so show nothing.
		if (endOfSecondToLastWordRange.location != NSNotFound) {
			lengthOfShowableText = endOfSecondToLastWordRange.location - range.location + 1;
		} else {
			lengthOfShowableText = 0;
		}
	} else {
		lengthOfShowableText = 0;
	}

	range.length = lengthOfShowableText;
	return range;
}

- (IBAction)repeatAMethodBasedOnSender:(id)sender {
	
	// Determine the method and arguments to repeat.
	SEL aSelector;
	NSString *textUnitName;
	BOOL firstLetter;
	if (sender == self.addClauseButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = clauseUnitName;
		firstLetter = NO;
	} else if (sender == self.addFirstLetterButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = YES;
	} else if (sender == self.addFirstLetterClauseButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = clauseUnitName;
		firstLetter = YES;
	} else if (sender == self.addFirstLetterSentenceButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = sentenceUnitName;
		firstLetter = YES;
	} else if (sender == self.addSentenceButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = sentenceUnitName;
		firstLetter = NO;
	} else if (sender == self.addWordButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = NO;
	} else if (sender == self.removeClauseButton) {
		aSelector = @selector(removeTextUnit:);
		textUnitName = clauseUnitName;
	} else if (sender == self.removeFirstLetterButton) {
		aSelector = @selector(removeTextUnit:);
		textUnitName = firstLetterUnitName;
	} else if (sender == self.removeSentenceButton) {
		aSelector = @selector(removeTextUnit:);
		textUnitName = sentenceUnitName;
	} else if (sender == self.removeWordButton) {
		aSelector = @selector(removeTextUnit:);
		textUnitName = wordUnitName;
	} else {
		NSLog(@"Warning from repeatAMethodBasedOnSender: Sender is unknown.");
	}
	
	// Create the invocation.
	NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invocation setTarget:self];
	[invocation setSelector:aSelector];
	[invocation setArgument:&textUnitName atIndex:2];
	if (aSelector == @selector(addTextUnit:firstLetter:) ) {
		[invocation setArgument:&firstLetter atIndex:3];
	}
			
	// Make a timer to invoke the method repeatedly.
	NSTimer *aRepeatingTimer = [NSTimer timerWithTimeInterval:0.1 invocation:invocation repeats:YES];
	self.repeatingTimer = aRepeatingTimer;
	
	// Invoke the method once.
	[invocation invoke];
	
	// Wait for the initial delay, then start the repeating timer.
	self.scheduledTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(startRepeatingTimer:) userInfo:nil repeats:NO];
	//NSLog(@"scheduled timer started");
}

- (void)startRepeatingTimer:(NSTimer *)theTimer {

	// The repeating timer is self.repeatingTimer, not theTimer.
	if (self.repeatingTimer != nil) {
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
	} 
	//NSLog(@"startRepeatingTimer called");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Overriden to allow any orientation.
    return YES;
}

- (IBAction)stopARepeatingMethod:(id)sender {

	[self.scheduledTimer invalidate];
	self.scheduledTimer = nil;
	[self.repeatingTimer invalidate];
	self.repeatingTimer = nil;
	//NSLog(@"scheduled and repeating timers stopped");
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

- (IBAction)undoRemoveAllText:(id)sender {

	self.showableRange = self.previousShowableRange;
	[self updateFirstLetterRangeAndText:self.previousFirstLetterRange];
	[self updateView];
}

- (void)updateControlAppearance {

	for (UIButton *aButton in self.passageControls) {
		aButton.enabled = YES;
	}
	
	// Toggle hide/show text control label.
	if (self.showReferenceText) {
		[self.hideOrShowReferenceTextButton setTitle:hideReferenceTextLabel forState:UIControlStateNormal];
	} else {
		[self.hideOrShowReferenceTextButton setTitle:showReferenceTextLabel forState:UIControlStateNormal];
	}
	
	// If there is nothing to remove, disable "remove" controls.
	if (self.firstLetterRange.length == 0) {
		self.removeAllButton.enabled = NO;
		self.removeClauseButton.enabled = NO;
		self.removeSentenceButton.enabled = NO;
		self.removeWordButton.enabled = NO;
	} else if (self.showableRange.length == 0) {
		self.removeWordButton.enabled = NO;
	}
	
	// If the first-letter range equals the showable range, disable "remove" first-letter controls.
	if (self.firstLetterRange.length <= self.showableRange.length) {
		self.removeFirstLetterButton.enabled = NO;
	}
	
	// If there is nothing to add, disable "add" controls.
	if (self.passage.text.length == NSMaxRange(self.showableRange) ) {
		self.addClauseButton.enabled = NO;
		self.addSentenceButton.enabled = NO;
		self.addWordButton.enabled = NO;
	}
	if (self.passage.text.length == NSMaxRange(self.firstLetterRange) ) {
		self.addFirstLetterButton.enabled = NO;
		self.addFirstLetterClauseButton.enabled = NO;
		self.addFirstLetterSentenceButton.enabled = NO;
	}
	
	// For "Undo '- All'" control. If the previous range has nothing, disable. If text is showing, reset the previous ranges and disable.
	if (self.previousFirstLetterRange.length == 0) {
		self.undoRemoveAllButton.enabled = NO;
	} else if (self.firstLetterRange.length > 0) {
		self.previousFirstLetterRange = NSMakeRange(0, 0);
		self.previousShowableRange = NSMakeRange(0, 0);
		self.undoRemoveAllButton.enabled = NO;
	}
}

- (void)updateFirstLetterRangeAndText:(NSRange)newRange {
	
	// If the new range is bigger, add first letters. If smaller, remove first letters.
	if (newRange.length > self.firstLetterRange.length) {
		
		// Get range of added text. Reduce that to first letters. Append to first-letter text.
		NSUInteger location = NSMaxRange(self.firstLetterRange);
		NSUInteger length = NSMaxRange(newRange) - location;
		NSRange addedTextRange = NSMakeRange(location, length);
		NSString *firstLetterTextToAdd = [self reduceStringToFirstLetters:[self.passage.text substringWithRange:addedTextRange]];
		self.firstLetterText = [self.firstLetterText stringByAppendingString:firstLetterTextToAdd];
		self.firstLetterRange = newRange;
		
	} else if (newRange.length < self.firstLetterRange.length) {
	
		// Get range of removed text. Reduce that to first letters. Remove that amount from the end of the first-letter text.
		NSUInteger location = NSMaxRange(newRange);
		NSUInteger length = NSMaxRange(self.firstLetterRange) - location;
		NSRange removedTextRange = NSMakeRange(location, length);
		NSString *firstLetterTextToRemove = [self reduceStringToFirstLetters:[self.passage.text substringWithRange:removedTextRange]];
		NSUInteger startingLocationOfFirstLetterTextToRemove = self.firstLetterText.length - firstLetterTextToRemove.length; 
		self.firstLetterText = [self.firstLetterText substringToIndex:startingLocationOfFirstLetterTextToRemove];
		self.firstLetterRange = newRange;
	} 		
}

- (void)updateView {
	
	// Make sure the text is showing correctly. Make sure the controls are enabled/disabled appropriately.
	if (self.showReferenceText) {
		self.referenceTextView.text = self.passage.text;
	} else {
		self.referenceTextView.text = @"";
	}
	self.workingTextView.text = [self assembleWorkingText];
	[self updateControlAppearance];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	self.passageControls = [NSArray arrayWithObjects: self.addClauseButton, 
		self.addFirstLetterButton, self.addFirstLetterClauseButton, 
		self.addFirstLetterSentenceButton, self.addSentenceButton, 
		self.addWordButton, self.hideOrShowReferenceTextButton, 
		self.removeAllButton, self.removeClauseButton, self.removeFirstLetterButton, self.removeSentenceButton, self.removeWordButton, self.undoRemoveAllButton, nil];
	[self stylizePassageControls];
	
	self.previousShowableRange = NSMakeRange(0, 0);
	self.previousFirstLetterRange = NSMakeRange(0, 0);
	//testing; later showableRange should start with enough clauses to be 10 words. 3 words? 10 letters?
	self.showableRange = NSMakeRange(0, 0);
	self.firstLetterRange = self.showableRange;
	self.firstLetterText = @"";
	//[self addClause];
	
	self.showReferenceText = YES;
	
	[self updateView];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.addClauseButton = nil;
	self.addFirstLetterButton = nil;
	self.addFirstLetterClauseButton = nil;
	self.addFirstLetterSentenceButton = nil;
	self.addSentenceButton = nil;
	self.addWordButton = nil;
	self.hideOrShowReferenceTextButton = nil;
	self.referenceTextView = nil;
	self.removeAllButton = nil;
	self.removeClauseButton = nil;
	self.removeFirstLetterButton = nil;
	self.removeSentenceButton = nil;
	self.removeWordButton = nil;
	self.undoRemoveAllButton = nil;
	self.workingTextView = nil;
	
	// Release any data that is recreated in viewDidLoad.
	self.passageControls = nil;
	self.firstLetterText = nil;
	self.repeatingTimer = nil;
	self.scheduledTimer = nil;
}

@end
