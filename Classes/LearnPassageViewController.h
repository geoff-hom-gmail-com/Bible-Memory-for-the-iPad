/*
 File: LearnPassageViewController.h
 Authors: Geoff Hom (GeoffHom@gmail.com)
 Abstract: Controls the view for learning/memorizing a passage.
 */

#import <UIKit/UIKit.h>

@class Passage;

@interface LearnPassageViewController : UIViewController {
}

// Control for showing more clauses.
@property (nonatomic, retain) IBOutlet UIButton *addClauseButton;

// Control for showing more first letters, by word.
@property (nonatomic, retain) IBOutlet UIButton *addFirstLetterButton;

// Control for showing more first letters, by clause.
@property (nonatomic, retain) IBOutlet UIButton *addFirstLetterClauseButton;

// Control for showing more first letters, by sentence.
@property (nonatomic, retain) IBOutlet UIButton *addFirstLetterSentenceButton;

// Control for showing more sentences.
@property (nonatomic, retain) IBOutlet UIButton *addSentenceButton;

// Control for showing more words.
@property (nonatomic, retain) IBOutlet UIButton *addWordButton;

// Control for hiding/showing the reference text.
@property (nonatomic, retain) IBOutlet UIButton *hideOrShowReferenceTextButton;

// For displaying the passage text.
@property (nonatomic, retain) IBOutlet UITextView *referenceTextView;

// Control for showing nothing.
@property (nonatomic, retain) IBOutlet UIButton *removeAllButton;

// Control for showing fewer clauses.
@property (nonatomic, retain) IBOutlet UIButton *removeClauseButton;

// Control for showing fewer first letters, by word.
@property (nonatomic, retain) IBOutlet UIButton *removeFirstLetterButton;

// Control for showing fewer first letters, by sentence.
// deprecate?
@property (nonatomic, retain) IBOutlet UIButton *removeFirstLetterSentenceButton;

// Control for showing fewer sentences.
@property (nonatomic, retain) IBOutlet UIButton *removeSentenceButton;

// Control for showing fewer words.
@property (nonatomic, retain) IBOutlet UIButton *removeWordButton;

// Control for undoing the "- All" button.
@property (nonatomic, retain) IBOutlet UIButton *undoRemoveAllButton;

// For working with the passage text.
@property (nonatomic, retain) IBOutlet UITextView *workingTextView;

// If the reference text is showing, hide it. If hidden, show it.
- (IBAction)hideOrShowReferenceText:(id)sender;

// The designated initializer.
- (id)initWithPassage:(Passage *)thePassage;

// Remove/reset all text from the showable text and first-letter text.
- (IBAction)removeAllText:(id)sender;

// Call a method based on the sender's identity. Then, after an initial delay, repeat the method indefinitely. (Example: holding down the delete key.)
- (IBAction)repeatAMethodBasedOnSender:(id)sender;

// Stop a repeating method. Assumes the repetition is done by a timer whose reference has been stored.
- (IBAction)stopARepeatingMethod:(id)sender;

// Undo the most recent "remove all text."
- (IBAction)undoRemoveAllText:(id)sender;

@end
