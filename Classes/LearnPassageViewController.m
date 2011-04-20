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

// The previous showable range. (For undo.)
@property (nonatomic, assign) NSRange previousRange;

// For repeating the current control.
@property (nonatomic, retain) NSTimer *repeatingTimer;

// The range of the passage's text that should be shown, if the "Show Text" control is on.
@property (nonatomic, assign) NSRange showableRange;

// Whether the reference text is visible.
@property (nonatomic, assign) BOOL showReferenceText;

// Whether the showable text is visible.
@property (nonatomic, assign) BOOL showShowableText;

// Add the next clause in the passage to the showable text. Include whitespace before the clause. By "clause" we mean the next set of 3+ words ending in a punctuation mark. However, if part of a clause is already showing, add that entire clause (so less than 3 words may be added).
// I suppose by clause I really mean the text (including whitespace) between two punctuation marks, plus the ending punctuation mark. Revise descriptions once I figure out if I really want a 3-word minimum.
- (void)addClause;
//- (void)addClause:(BOOL)firstLetterMode;

// Add the next sentence in the passage to the showable text. Include whitespace before the sentence. If part of a sentence is already showing, add that sentence.
- (void)addSentence;
//- (void)addSentence:(BOOL)firstLetterMode;

// Add the text unit from the passage text. If not in first-letter mode, add to the regular range. Else, add to the first-letter range.
- (void)addTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode;

// Add the next word from the passage's text. If in first-letter mode, then add the first letter instead of the entire word. Either way, include whitespace before the word and punctuation after.
// I could let addTextUnit handle the first-letter-mode stuff. Just return a range here and move part to addTextUnit.
- (void)addWord:(BOOL)firstLetterMode;
// Add the next word from the passage's text to the range. The new range is returned.
//- (NSRange)addWord:(NSRange)range;

// Return the working text by combining the showable range and the first-letter range.
- (NSString *)assembleWorkingText;

// Remove all letters from the string, except for first letters. (So retain whitespace, punctuation, etc.)
- (NSString *)reduceStringToFirstLetters:(NSString *)string;

// Remove the last clause from the showable text. (See addClause for our definition of a clause.) If only part of a clause is showing, then hide that clause.
- (void)removeClause;

// Remove the first letters of the last sentence from the showable text. If part of a sentence is showing, then remove that sentence instead.
- (void)removeFirstLetterSentence;

// Remove the first letter of the last word from the showable text. Also remove any whitespace before the word. 
- (void)removeFirstLetterWord;

// Remove the last sentence from the showable text. If part of a sentence is showing, then remove that sentence.
- (void)removeSentence;

// Remove the text unit. If not in first-letter mode, remove from the showable range. Else, remove from the first-letter range (and text).
- (void)removeTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode;

// Remove the last word from the showable text. Also remove any whitespace before the word. 
//- (void)removeWord;

// Remove the last word from the range. The new range is returned.
- (NSRange)removeWord:(NSRange)range;

// Start the current repeating timer, if any.
- (void)startRepeatingTimer;

// Change the section/word controls so they look distinct from the standard round-rectangle button. These controls are used by the user differently than a standard UIButton.
- (void)stylizePassageControls;

// Enable/disable passage controls based on context. Change control labels based on context.
- (void)updateControlAppearance;

// Update what's seen. For example, in response to the showable text changing.
- (void)updateView;

@end

@implementation LearnPassageViewController

@synthesize addAllButton, addClauseButton, addFirstLetterWordButton, addFirstLetterSentenceButton, addSentenceButton, addWordButton, hideOrShowReferenceTextButton, hideOrShowTextButton, referenceTextView, removeAllButton, removeAllFirstLettersButton, removeClauseButton, removeFirstLetterSentenceButton, removeFirstLetterWordButton, removeSentenceButton, removeWordButton, undoRemoveAllFirstLettersButton, workingTextView;
@synthesize firstLetterRange, firstLetterText, passage, passageControls, previousRange, repeatingTimer, showableRange, showReferenceText, showShowableText;

- (IBAction)addAllText:(id)sender {

	self.showableRange = self.previousRange;
	[self updateView];
}

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
	
	// See if there's something left to add. If so, add the text unit. Else, stop any repeating timer.
	NSString *text = self.passage.text;
	BOOL stopTimer = NO;
	NSRange aRange;
	if (!firstLetterMode) {
		aRange = self.showableRange;
	} else {
		aRange = self.firstLetterRange;
	}
	if (NSMaxRange(aRange) != text.length) {
	
		if ([textUnit isEqualToString:clauseUnitName]) {
			NSLog(@"add clause");
		} else if ([textUnit isEqualToString:sentenceUnitName]) {
			NSLog(@"add sentence");
		} else if ([textUnit isEqualToString:wordUnitName]) {
			[self addWord:firstLetterMode];
		} else {
			NSLog(@"Warning: Text unit not found: %@", textUnit);
		}
		[self updateView];
		
		// If the new range is at the end of the passage, we can also stop the timer.
		if (NSMaxRange(aRange) == text.length) {
			stopTimer = YES;
		}
	} else {
		stopTimer = YES;
	}
	
	if (stopTimer) {
		[self stopARepeatingMethod:self];
	}
}

- (void)addWord:(BOOL)firstLetterMode {

	NSRange aRange;
	if (!firstLetterMode) {
		aRange = self.showableRange;
	} else {
		aRange = self.firstLetterRange;
	}

	// Scan forward from the end of the range. Find the start of the next word by scanning past whitespace. Then, find the end of the word/punctuation by scanning up to whitespace and going back one.
	
	// Scan past whitespace.
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *sourceText = [self.passage.text substringFromIndex:NSMaxRange(aRange)];
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

	NSUInteger newLength = endingLocation + NSMaxRange(aRange) + 1;
	aRange.length = newLength;
	if (!firstLetterMode) {
		self.showableRange = aRange;
	} else {
		
		// Get range of added text. Reduce that to first letters. Append to first-letter text.
		NSUInteger location = NSMaxRange(self.firstLetterRange);
		NSUInteger length = NSMaxRange(aRange) - location;
		NSRange addedTextRange = NSMakeRange(location, length);
		NSString *firstLetterTextToAdd = [self reduceStringToFirstLetters:[self.passage.text substringWithRange:addedTextRange]];
		self.firstLetterText = [self.firstLetterText stringByAppendingString:firstLetterTextToAdd];
		self.firstLetterRange = aRange;
	}
}

/*
- (void)addWordFromText:(NSString *)text toRange:(NSRange *)rangePointer {

	// Scan forward from the end of the range text. Find the start of the next word by looking for non-whitespace. Then, find the end of the word by looking for whitespace and going back one.
	
	//NSString *passageText = self.passage.text;
		
	// Scan starts from end of range text = location = (index of last range char in passage text) + 1 = [(theRange length) - (theRange location) - 1] + 1 = length - location.
	NSUInteger location = rangePointer->length - rangePointer->location;
	
	// Scan ends at end of passage text. Length = (index of last char) - location + 1 = (index of last char) + 1 - location = (passage text length) - location.
	NSUInteger length = text.length - location;
	
	NSCharacterSet *nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
	NSRange startOfNextWordRange = [text rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:0 range:NSMakeRange(location, length)];

	location = startOfNextWordRange.location;
	length = text.length - location;
	NSRange startOfNextNextWhitespaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(location, length)];
	
	// Get new range. The end of the range is just before the whitespace found. However, if the added word is the last word, then no whitespace would have been found. In that case, the end of the range is the end of the passage text.
	NSUInteger endingLocation;
	if (startOfNextNextWhitespaceRange.location != NSNotFound) {
		endingLocation = startOfNextNextWhitespaceRange.location - 1;
	} else {
		endingLocation = text.length - 1;
	}
	NSUInteger lengthOfShowableText = endingLocation - rangePointer->location + 1;
	rangePointer->length = lengthOfShowableText;
}
*/

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
	
	NSArray *anArray = [NSArray arrayWithObjects:addAllButton, addClauseButton, addFirstLetterWordButton, addSentenceButton, addWordButton, firstLetterText, hideOrShowReferenceTextButton, hideOrShowTextButton, passage, passageControls, referenceTextView, removeAllButton, removeClauseButton, removeSentenceButton, removeWordButton, repeatingTimer, workingTextView, nil];
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
	
	self.previousRange = self.showableRange;
	self.showableRange = NSMakeRange(self.showableRange.location, 0);
	[self updateView];
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

- (void)removeFirstLetterSentence {
}

- (void)removeFirstLetterWord {
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

- (void)removeTextUnit:(NSString *)textUnit firstLetter:(BOOL)firstLetterMode {

	// See if there's something left to remove. If so, remove the text unit. Else, stop any repeating timer.
	NSString *text = self.passage.text;
	BOOL stopTimer = NO;
	NSRange aRange;
	if (!firstLetterMode) {
		aRange = self.showableRange;
	} else {
		aRange = self.firstLetterRange;
	}
	if (aRange.length != 0) {
	
		if ([textUnit isEqualToString:clauseUnitName]) {
			NSLog(@"remove clause");
		} else if ([textUnit isEqualToString:sentenceUnitName]) {
			NSLog(@"remove sentence");
		} else if ([textUnit isEqualToString:wordUnitName]) {
			aRange = [self removeWord:aRange];
		} else {
			NSLog(@"Warning: Text unit not found: %@", textUnit);
		}
		
		if (!firstLetterMode) {
			self.showableRange = aRange;
		} else {
			
			// Get range of removed text. Reduce that to first letters. Remove that amount from the end of the first-letter text.
			NSUInteger location = NSMaxRange(aRange);
			NSUInteger length = NSMaxRange(self.firstLetterRange) - location;
			NSRange removedTextRange = NSMakeRange(location, length);
			NSString *firstLetterTextToRemove = [self reduceStringToFirstLetters:[text substringWithRange:removedTextRange]];
			NSUInteger startingLocationOfFirstLetterTextToRemove = self.firstLetterText.length - firstLetterTextToRemove.length; 
			self.firstLetterText = [self.firstLetterText substringToIndex:startingLocationOfFirstLetterTextToRemove];
			self.firstLetterRange = aRange;
		}
		[self updateView];
		
		// If the new range is at the start of the passage, we can also stop the timer.
		if (aRange.length == 0) {
			stopTimer = YES;
		}
	} else {
		stopTimer = YES;
	}
	
	if (stopTimer) {
		[self stopARepeatingMethod:self];
	}
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

	range = NSMakeRange(range.location, lengthOfShowableText);
	return range;
}

/*
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
*/

- (IBAction)repeatAMethodBasedOnSender:(id)sender {
	
	// Determine the method and arguments to repeat.
	SEL aSelector;
	NSString *textUnitName;
	BOOL firstLetter;
	if (sender == self.addClauseButton) {
		aSelector = @selector(addClause);
	} else if (sender == self.addSentenceButton) {
		aSelector = @selector(addSentence);
	} else if (sender == self.addWordButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = NO;
	} else if (sender == self.removeClauseButton) {
		aSelector = @selector(removeClause);
	} else if (sender == self.removeSentenceButton) {
		aSelector = @selector(removeSentence);
	} else if (sender == self.removeWordButton) {
		aSelector = @selector(removeTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = NO;
	} else if (sender == self.addFirstLetterWordButton) {
		aSelector = @selector(addTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = YES;
	} else if (sender == self.removeFirstLetterWordButton) {
		aSelector = @selector(removeTextUnit:firstLetter:);
		textUnitName = wordUnitName;
		firstLetter = YES;
	} else {
		NSLog(@"Warning from repeatAMethodBasedOnSender: Sender is unknown.");
	}
	
	// Create the invocation.
	NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invocation setTarget:self];
	[invocation setSelector:aSelector];
	[invocation setArgument:&textUnitName atIndex:2];
	[invocation setArgument:&firstLetter atIndex:3];
			
	// Invoke the method once.
	[invocation invoke];

	// Make a timer to invoke the method repeatedly.
	NSTimer *aRepeatingTimer = [NSTimer timerWithTimeInterval:0.1 invocation:invocation repeats:YES];
	self.repeatingTimer = aRepeatingTimer;
	
	// Wait for the initial delay, then start the repeating timer.
	[NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(startRepeatingTimer) userInfo:nil repeats:NO];
}

- (void)startRepeatingTimer {

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

- (IBAction)undoRemoveAllFirstLetters:(id)sender {
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
	if (self.showShowableText) {
		[self.hideOrShowTextButton setTitle:hideTextLabel forState:UIControlStateNormal];
	} else {
		[self.hideOrShowTextButton setTitle:showTextLabel forState:UIControlStateNormal];
	}
	
	// If nothing in a range, disable "subtract" controls.
	if (self.showableRange.length == 0) {
		self.removeAllButton.enabled = NO;
		self.removeClauseButton.enabled = NO;
		self.removeSentenceButton.enabled = NO;
		self.removeWordButton.enabled = NO;
	}
	if (self.firstLetterRange.length == 0) {
		self.removeFirstLetterWordButton.enabled = NO;
	}
	
	// If everything is in a range, disable "add" controls.
	if (self.passage.text.length == self.showableRange.location + self.showableRange.length) {
		self.addClauseButton.enabled = NO;
		self.addSentenceButton.enabled = NO;
		self.addWordButton.enabled = NO;
		//NSLog(@"\"add\" controls disabled");
	}
	if (self.passage.text.length == self.firstLetterRange.location + self.firstLetterRange.length) {
		self.addFirstLetterWordButton.enabled = NO;
	}
	
	// For "Undo -All" control. Disable if showable range has something or previous range has nothing.
	if ((self.showableRange.length != 0) || (self.previousRange.length == 0)) {
		self.addAllButton.enabled = NO;
	} else {
		self.addAllButton.enabled = YES;
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
	self.passageControls = [NSArray arrayWithObjects:self.addAllButton, self.addClauseButton, self.addFirstLetterWordButton, self.addSentenceButton, self.addWordButton, self.hideOrShowReferenceTextButton, self.hideOrShowTextButton, self.removeAllButton, self.removeClauseButton, self.removeFirstLetterWordButton, self.removeSentenceButton, self.removeWordButton, nil];
	[self stylizePassageControls];
	
	//testing; later showableRange should start with enough clauses to be 10 words. 3 words? 10 letters?
	self.showableRange = NSMakeRange(0, 0);
	self.firstLetterRange = NSMakeRange(0, 0);
	//[self addClause];
	
	self.showReferenceText = YES;
	self.showShowableText = YES;
	
	[self updateView];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.addAllButton = nil;
	self.addClauseButton = nil;
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
	self.workingTextView = nil;
	
	// Release any data that is recreated in viewDidLoad.
	self.passageControls = nil;
	// showableRange still in dev
}

@end
