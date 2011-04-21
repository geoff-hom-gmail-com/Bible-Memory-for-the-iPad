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

// The range of the passage's text that should be shown, if the "Show Text" control is on.
@property (nonatomic, assign) NSRange showableRange;

// Whether the reference text is visible.
@property (nonatomic, assign) BOOL showReferenceText;

// Whether the showable text is visible.
@property (nonatomic, assign) BOOL showShowableText;

// Add the next clause from the passage's text to the range. The new range is returned. By "next clause," we mean up to the next clause-ending punctuation mark. (E.g., a semi-colon, but not an apostraphe.) Note that a comma-delimited list will be several clauses (e.g., in "love, joy, peace, patience and kindness," the first clause is simply "love,".) I'm not sure how to easily distinguish between a list and a real clause. 
- (NSRange)addClause:(NSRange)range;

// Add the next sentence in the passage to the showable text. Include whitespace before the sentence. If part of a sentence is already showing, add that sentence.
- (void)addSentence;
//- (void)addSentence:(BOOL)firstLetterMode;

// Add the next text unit from the passage text. If not in first-letter mode, add to the regular range. Else, add to the first-letter range.
- (void)addTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode;

// Add the next word from the passage's text to the range. The new range is returned.
- (NSRange)addWord:(NSRange)range;

// Return the working text by combining the showable range and the first-letter range.
- (NSString *)assembleWorkingText;

// Remove all letters from the string, except for first letters. (So retain whitespace, punctuation, etc.)
- (NSString *)reduceStringToFirstLetters:(NSString *)string;

// Remove the last clause from the range. The new range is returned. See addClause: for our definition of a clause. If only part of a clause is showing, then that becomes the clause to remove. 
- (NSRange)removeClause:(NSRange)range;

// Remove the last sentence from the showable text. If part of a sentence is showing, then remove that sentence.
// description needs update
- (void)removeSentence;

// Remove the text unit from the showable range. However, if the first-letter range is greater than the showable range, then remove from the first-letter range (and first-letter text) instead.
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

@synthesize addClauseButton, addFirstLetterClauseButton, addFirstLetterWordButton, addFirstLetterSentenceButton, addSentenceButton, addWordButton, hideOrShowReferenceTextButton, hideOrShowTextButton, referenceTextView, removeAllButton, removeAllFirstLettersButton, removeClauseButton, removeFirstLetterSentenceButton, removeFirstLetterWordButton, removeSentenceButton, removeWordButton, undoRemoveAllButton, undoRemoveAllFirstLettersButton, workingTextView;
@synthesize firstLetterRange, firstLetterText, passage, passageControls, previousFirstLetterRange, previousShowableRange, repeatingTimer, showableRange, showReferenceText, showShowableText;

- (NSRange)addClause:(NSRange)range {

	// Find the next clause-ending punctuation mark.
	NSString *text = self.passage.text;
	NSUInteger location = range.length;
	NSUInteger length = text.length - location;
	NSCharacterSet *clauseCharacterSet = [NSCharacterSet characterSetWithCharactersInString:clauseCharactersString];
	NSRange endOfNextClauseRange = [text rangeOfCharacterFromSet:clauseCharacterSet options:0 range:NSMakeRange(location, length)];
	
	// If found, show up to (and including) that. Else, show up to the end.
	NSUInteger lengthOfShowableText;
	if (endOfNextClauseRange.location != NSNotFound) {
		lengthOfShowableText = endOfNextClauseRange.location - range.location + 1;
	} else {
		lengthOfShowableText = text.length - range.location;
	}
	range.length = lengthOfShowableText;
	return range;
}

- (void)addSentence {

	// Add something only if there's something to add. Else, stop any repeating timer.
	BOOL stopTimer = NO;
	if (self.showableRange.location + self.showableRange.length != self.passage.text.length) {
	
		// Find the end of the next sentence. 
		NSUInteger location = self.showableRange.length;
		NSUInteger length = self.passage.text.length - location;
		NSCharacterSet *sentenceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:sentenceCharactersString];
		NSRange endOfNextSentenceRange = [self.passage.text rangeOfCharacterFromSet:sentenceCharacterSet options:0 range:NSMakeRange(location, length)];
		
		// If the end of the next sentence was found, show up to that. Else, show up to the end.
		NSUInteger lengthOfShowableText;
		if (endOfNextSentenceRange.location != NSNotFound) {
			lengthOfShowableText = endOfNextSentenceRange.location - self.showableRange.location + 1;
		} else {
			lengthOfShowableText = self.passage.text.length - self.showableRange.location;
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
		//aRange = [self addSentence:aRange];
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
	
	NSArray *anArray = [NSArray arrayWithObjects: addClauseButton, addFirstLetterClauseButton, addFirstLetterWordButton, addSentenceButton, addWordButton, firstLetterText, hideOrShowReferenceTextButton, hideOrShowTextButton, passage, passageControls, referenceTextView, removeAllButton, removeClauseButton, removeSentenceButton, removeWordButton, repeatingTimer, undoRemoveAllButton, workingTextView, nil];
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

- (IBAction)hideOrShowReferenceText:(id)sender {
	
	if ([self.hideOrShowReferenceTextButton.titleLabel.text isEqualToString:hideReferenceTextLabel]) {
		self.showReferenceText = NO;
	} else {
		self.showReferenceText = YES;
	}
	[self updateView];
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

- (IBAction)removeAllFirstLetters:(id)sender {
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

- (void)removeSentence {

	// Remove something only if there's something to remove. Else, stop any repeating timer.
	BOOL stopTimer = NO;
	if (self.showableRange.length != 0) {
	
		// Find the end of the previous sentence. (Start at one character from the end and scan backwards.) 
		NSUInteger location = self.showableRange.location;
		NSUInteger length = self.showableRange.length - 1;
		NSCharacterSet *sentenceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:sentenceCharactersString];
		NSString *showableText = [self.passage.text substringWithRange:self.showableRange];
		NSRange endOfPreviousSentenceRange = [showableText rangeOfCharacterFromSet:sentenceCharacterSet options:NSBackwardsSearch range:NSMakeRange(location, length)];
		
		// If the end of the previous sentence was found, show up to that. Else, show up to the start (i.e., nothing).
		NSUInteger lengthOfShowableText;
		if (endOfPreviousSentenceRange.location != NSNotFound) {
			lengthOfShowableText = endOfPreviousSentenceRange.location - self.showableRange.location + 1;
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

// Remove the text unit from the showable range. However, if the first-letter range is greater than the showable range, then remove from the first-letter range (and first-letter text) instead.

- (void)removeTextUnit:(NSString *)textUnit {

	NSRange aRange;
	BOOL firstLetterMode;
	if (self.firstLetterRange.length > self.showableRange.length) {
		aRange = self.firstLetterRange;
		firstLetterMode = YES;
	} else {
		aRange = self.showableRange;
		firstLetterMode = NO;
	}
	
	if ([textUnit isEqualToString:clauseUnitName]) {
		aRange = [self removeClause:aRange];
	} else if ([textUnit isEqualToString:sentenceUnitName]) {
		NSLog(@"remove sentence");
		//aRange = [self removeSentence:aRange];
	} else if ([textUnit isEqualToString:wordUnitName]) {
		aRange = [self removeWord:aRange];
	} else {
		NSLog(@"Warning: Text unit not found: %@", textUnit);
	}
	
	// If the showable range was reduced, then make the first-letter range match that.
	if (!firstLetterMode) {
		
		self.showableRange = aRange;
		[self updateFirstLetterRangeAndText:aRange];
	} 
	
	// If the first-letter range was reduced, then that range may now be less than the showable range. (E.g., a clause shows some full words and some first letters, and the clause is removed.) In that case, make the showable range match.
	else {
		
		[self updateFirstLetterRangeAndText:aRange];
		if (self.firstLetterRange.length < self.showableRange.length) {
			self.showableRange = aRange;
		} 
	}
	[self updateView];
	
	// If there's nothing left to remove, then stop any repeating timer.
	if (self.firstLetterRange.length == 0) {
		[self stopARepeatingMethod:self];
	}
}

// old version; deprecated
/*
- (void)removeTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode {

	NSRange aRange;
	if (!firstLetterMode) {
		aRange = self.showableRange;
	} else {
		aRange = self.firstLetterRange;
	}
	
	if ([textUnit isEqualToString:clauseUnitName]) {
		aRange = [self removeClause:aRange];
	} else if ([textUnit isEqualToString:sentenceUnitName]) {
		NSLog(@"remove sentence");
		//aRange = [self removeSentence:aRange];
	} else if ([textUnit isEqualToString:wordUnitName]) {
		aRange = [self removeWord:aRange];
	} else {
		NSLog(@"Warning: Text unit not found: %@", textUnit);
	}
	
	if (!firstLetterMode) {
		
		// If first letters were not already showing, then don't show any for the removed text unit.
		if (self.firstLetterRange.length <= self.showableRange.length) {
			[self updateFirstLetterRangeAndText:aRange];
		}
		self.showableRange = aRange;
		
		
	} else {
	
		// The first-letter range should be at least as large as the showable range. E.g., if the rest of a sentence is shown in first letters, and then the first letters are removed for the entire sentence, then this would apply.
		if (aRange.length < self.showableRange.length) {
			aRange = self.showableRange;
		} 
		[self updateFirstLetterRangeAndText:aRange];
	}
	[self updateView];
	
	// If there's nothing left to remove, then stop any repeating timer. Words can be removed until the start of the passage, but first-letter words can be removed only until the end of the showable text.
	BOOL stopTimer = NO;
	if ( (!firstLetterMode) && (self.showableRange.length == 0) ) {
		stopTimer = YES;
	} else if ( (firstLetterMode) && (self.firstLetterRange.length <= self.showableRange.length) ) {
		stopTimer = YES;
	}
	if (stopTimer) {
		[self stopARepeatingMethod:self];
	}
}
*/

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
	} else if (sender == self.removeSentenceButton) {
		aSelector = @selector(removeTextUnit:);
		textUnitName = sentenceUnitName;
	} else if (sender == self.removeWordButton) {
		aSelector = @selector(removeTextUnit:);
		textUnitName = wordUnitName;
	} else if (sender == self.addFirstLetterClauseButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = clauseUnitName;
		firstLetter = YES;
	} else if (sender == self.addFirstLetterWordButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = YES;
	//} else if (sender == self.removeFirstLetterWordButton) {
//		aSelector = @selector(removeTextUnit:firstLetter:);
//		textUnitName = wordUnitName;
//		firstLetter = YES;
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
	[NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(startRepeatingTimer:) userInfo:nil repeats:NO];
}

- (void)startRepeatingTimer:(NSTimer *)theTimer {

	// The repeating timer is self.repeatingTimer, not theTimer.
	if (self.repeatingTimer != nil) {
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
	} 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Overriden to allow any orientation.
    return YES;
}

- (IBAction)stopARepeatingMethod:(id)sender {

	[self.repeatingTimer invalidate];
	self.repeatingTimer = nil;
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

- (IBAction)undoRemoveAllFirstLetters:(id)sender {
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
	
	// Toggle hide/show text control label.
	//try without this button for now
	self.hideOrShowTextButton.hidden = YES;
	if (self.showShowableText) {
		[self.hideOrShowTextButton setTitle:hideTextLabel forState:UIControlStateNormal];
	} else {
		[self.hideOrShowTextButton setTitle:showTextLabel forState:UIControlStateNormal];
	}
	
	// If there is nothing to remove, disable "subtract" controls.
	if (self.firstLetterRange.length == 0) {
		self.removeAllButton.enabled = NO;
		self.removeClauseButton.enabled = NO;
		self.removeSentenceButton.enabled = NO;
		self.removeWordButton.enabled = NO;
	}
	
	// If first-letter range equals showable range, disable "subtract" first-letter controls.
	//if (self.firstLetterRange.length <= self.showableRange.length) {
//		self.removeFirstLetterWordButton.enabled = NO;
//	}
	
	// If there is nothing to add, disable "add" controls.
	if (self.passage.text.length == NSMaxRange(self.showableRange) ) {
		self.addClauseButton.enabled = NO;
		self.addSentenceButton.enabled = NO;
		self.addWordButton.enabled = NO;
		//NSLog(@"\"add\" controls disabled");
	}
	if (self.passage.text.length == NSMaxRange(self.firstLetterRange) ) {
		self.addFirstLetterClauseButton.enabled = NO;
		self.addFirstLetterWordButton.enabled = NO;
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
	if (self.showShowableText) {
		self.workingTextView.text = [self assembleWorkingText];
	} else {
		self.workingTextView.text = @"";
	}
	[self updateControlAppearance];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	self.passageControls = [NSArray arrayWithObjects: self.addClauseButton, self.addFirstLetterClauseButton, self.addFirstLetterWordButton, self.addSentenceButton, self.addWordButton, self.hideOrShowReferenceTextButton, self.hideOrShowTextButton, self.removeAllButton, self.removeClauseButton, self.removeFirstLetterWordButton, self.removeSentenceButton, self.removeWordButton, self.undoRemoveAllButton, nil];
	[self stylizePassageControls];
	
	self.previousShowableRange = NSMakeRange(0, 0);
	self.previousFirstLetterRange = NSMakeRange(0, 0);
	//testing; later showableRange should start with enough clauses to be 10 words. 3 words? 10 letters?
	self.showableRange = NSMakeRange(0, 0);
	self.firstLetterRange = self.showableRange;
	//[self addClause];
	
	self.showReferenceText = YES;
	self.showShowableText = YES;
	
	[self updateView];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.addClauseButton = nil;
	self.addFirstLetterClauseButton = nil;
	self.addFirstLetterWordButton = nil;
	self.addSentenceButton = nil;
	self.addWordButton = nil;
	self.hideOrShowReferenceTextButton = nil;
	self.hideOrShowTextButton = nil;
	self.referenceTextView = nil;
	self.removeAllButton = nil;
	self.removeClauseButton = nil;
	self.removeSentenceButton = nil;
	self.removeWordButton = nil;
	self.undoRemoveAllButton = nil;
	self.workingTextView = nil;
	
	// Release any data that is recreated in viewDidLoad.
	self.passageControls = nil;
	// showableRange still in dev
}

@end
