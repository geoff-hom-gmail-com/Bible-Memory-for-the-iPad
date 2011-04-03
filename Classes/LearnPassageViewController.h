/*
 File: LearnPassageViewController.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: Controls the view for learning/memorizing a passage.
 */

#import <UIKit/UIKit.h>

@interface LearnPassageViewController : UIViewController {
}

@property (nonatomic, retain) IBOutlet UIButton *addClauseButton;
@property (nonatomic, retain) IBOutlet UIButton *addWordButton;
@property (nonatomic, retain) IBOutlet UIButton *hideOrShowTextButton;
@property (nonatomic, retain) IBOutlet UIButton *removeClauseButton;
@property (nonatomic, retain) IBOutlet UIButton *removeWordButton;
@property (nonatomic, retain) IBOutlet UITextView *textView;

// Show the next clause. By "clause" we mean the next set of words ending in a punctuation mark, with a minimum of 3 words. However, if part of a clause is already showing, show that entire clause (so less than 3 words may be added).
- (IBAction)addClause:(id)sender;

// If any of the passage is showing, hide it. If hidden, show it. The amount to show is determined by the other passage controls and can still be changed while the passage is hidden.
- (IBAction)hideOrShowText:(id)sender;

// Hide the last clause. By "clause" we arbitrarily mean a sequence of at least three words ending with a punctuation mark. If just part of a clause is showing, then hide that clause. (So less than 3 words may be hidden.)
- (IBAction)removeClause:(id)sender;

// Call a method based on the sender's identity. Then, after an initial delay, repeat the method indefinitely. (Example: holding down the delete key.)
- (IBAction)repeatAMethodBasedOnSender:(id)sender;

// Stop a repeating method. Assumes the repetition is done by a timer whose reference has been stored.
- (IBAction)stopARepeatingMethod:(id)sender;

@end
