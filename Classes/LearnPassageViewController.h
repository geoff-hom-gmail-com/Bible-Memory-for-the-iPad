/*
 File: LearnPassageViewController.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: Controls the view for learning/memorizing a passage.
 */

#import <UIKit/UIKit.h>

@class Passage;

@interface LearnPassageViewController : UIViewController {
}

// Control for showing more clauses.
@property (nonatomic, retain) IBOutlet UIButton *addClauseButton;

// Control for showing more words.
@property (nonatomic, retain) IBOutlet UIButton *addWordButton;

// Control for hiding/showing all (showable) text.
@property (nonatomic, retain) IBOutlet UIButton *hideOrShowTextButton;

// Control for showing less clauses.
@property (nonatomic, retain) IBOutlet UIButton *removeClauseButton;

// Control for showing less words.
@property (nonatomic, retain) IBOutlet UIButton *removeWordButton;

// For displaying the passage text.
@property (nonatomic, retain) IBOutlet UITextView *textView;

// If any of the passage is showing, hide it. If hidden, show it. The amount to show is determined by the other passage controls and can still be changed while the passage is hidden.
- (IBAction)hideOrShowText:(id)sender;

// The designated initializer.
- (id)initWithPassage:(Passage *)thePassage;

// Call a method based on the sender's identity. Then, after an initial delay, repeat the method indefinitely. (Example: holding down the delete key.)
- (IBAction)repeatAMethodBasedOnSender:(id)sender;

// Stop a repeating method. Assumes the repetition is done by a timer whose reference has been stored.
- (IBAction)stopARepeatingMethod:(id)sender;

@end
