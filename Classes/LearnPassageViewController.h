/*
 File: LearnPassageViewController.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: Controls the view for learning/memorizing a passage. Regular controls dominate first-letter controls.
 */

#import <UIKit/UIKit.h>

@class Passage;

@interface LearnPassageViewController : UIViewController {
}

// Control for showing everything.
//rename this to "undoRemoveAllButton"?
@property (nonatomic, retain) IBOutlet UIButton *addAllButton;

// Control for showing more clauses.
// do I end up using this button enough?
@property (nonatomic, retain) IBOutlet UIButton *addClauseButton;

// Control for showing more first letters, by word.
@property (nonatomic, retain) IBOutlet UIButton *addFirstLetterWordButton;

// Control for showing more first letters, by sentence.
@property (nonatomic, retain) IBOutlet UIButton *addFirstLetterSentenceButton;

// Control for showing more sentences.
@property (nonatomic, retain) IBOutlet UIButton *addSentenceButton;

// Control for showing more words.
@property (nonatomic, retain) IBOutlet UIButton *addWordButton;

// Control for hiding/showing the reference text.
@property (nonatomic, retain) IBOutlet UIButton *hideOrShowReferenceTextButton;

// Control for hiding/showing all (showable) text.
//for working text
@property (nonatomic, retain) IBOutlet UIButton *hideOrShowTextButton;

// For displaying the passage text.
@property (nonatomic, retain) IBOutlet UITextView *referenceTextView;

// Control for showing nothing.
@property (nonatomic, retain) IBOutlet UIButton *removeAllButton;

// Control for showing no first letters.
//do I end up using this button?
@property (nonatomic, retain) IBOutlet UIButton *removeAllFirstLettersButton;

// Control for showing less clauses.
@property (nonatomic, retain) IBOutlet UIButton *removeClauseButton;

// Control for showing fewer first letters, by sentence.
@property (nonatomic, retain) IBOutlet UIButton *removeFirstLetterSentenceButton;

// Control for showing fewer first letters, by word.
@property (nonatomic, retain) IBOutlet UIButton *removeFirstLetterWordButton;

// Control for showing fewer sentences.
@property (nonatomic, retain) IBOutlet UIButton *removeSentenceButton;

// Control for showing less words.
@property (nonatomic, retain) IBOutlet UIButton *removeWordButton;

// Control for undoing the "-All" first-letters button.
@property (nonatomic, retain) IBOutlet UIButton *undoRemoveAllFirstLettersButton;

// For working with the passage text.
@property (nonatomic, retain) IBOutlet UITextView *workingTextView;

// Add all text to the showable text. Actually, for now this should just undo "removeAllText". Testing.
- (IBAction)addAllText:(id)sender;

// If the reference text is showing, hide it. If hidden, show it.
- (IBAction)hideOrShowReferenceText:(id)sender;

// If any of the passage is showing, hide it. If hidden, show it. The amount to show is determined by the other passage controls and can still be changed while the passage is hidden.
//for working text
- (IBAction)hideOrShowText:(id)sender;

// The designated initializer.
- (id)initWithPassage:(Passage *)thePassage;

// Remove all first letters from the working text.
- (IBAction)removeAllFirstLetters:(id)sender;

// Remove all text from the showable text.
- (IBAction)removeAllText:(id)sender;

// Call a method based on the sender's identity. Then, after an initial delay, repeat the method indefinitely. (Example: holding down the delete key.)
- (IBAction)repeatAMethodBasedOnSender:(id)sender;

// Stop a repeating method. Assumes the repetition is done by a timer whose reference has been stored.
- (IBAction)stopARepeatingMethod:(id)sender;

// Undo "removeAllFirstLetters:."
- (IBAction)undoRemoveAllFirstLetters:(id)sender;

@end
