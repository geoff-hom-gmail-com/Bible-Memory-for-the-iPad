/*
  Project: bible-memory-ipad
	 File: LearnTextViewController.h
 Abstract:
 
 Created by Geoffrey Hom on 11/24/10.
 */

#import <UIKit/UIKit.h>
#import "PassagesTableViewController.h"

@interface LearnTextViewController : UIViewController <PassagesTableViewDelegate> {
	Passage *currentPassage;
	NSMutableString *currentTextShowing;
	UIButton *doneButton;
	UIButton *editSectionsButton;
	UIButton *hideClauseButton;
	UIButton *hideSectionButton;
	UIButton *hideWordButton;
	UITextView *instructions1TextView;
	UITextView *instructions2TextView;
	UITextView *instructions3TextView;
	NSManagedObjectContext *managedObjectContext;
	NSArray *passageControls;
	UITextView *passageTextView;
	UIButton *showClauseButton;
	UIButton *showSectionButton;
	UIButton *showWordButton;
}

@property (nonatomic, retain) Passage *currentPassage;
@property (nonatomic, retain) NSMutableString *currentTextShowing;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *editSectionsButton;
@property (nonatomic, retain) IBOutlet UIButton *hideClauseButton;
@property (nonatomic, retain) IBOutlet UIButton *hideSectionButton;
@property (nonatomic, retain) IBOutlet UIButton *hideWordButton;
@property (nonatomic, retain) IBOutlet UITextView *instructions1TextView;
@property (nonatomic, retain) IBOutlet UITextView *instructions2TextView;
@property (nonatomic, retain) IBOutlet UITextView *instructions3TextView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *passageControls;
@property (nonatomic, retain) IBOutlet UITextView *passageTextView;
@property (nonatomic, retain) IBOutlet UIButton *showClauseButton;
@property (nonatomic, retain) IBOutlet UIButton *showSectionButton;
@property (nonatomic, retain) IBOutlet UIButton *showWordButton;

//- (NSString *)currentInstructions;
- (void)changeAppearanceOfControls;
- (IBAction)changeCurrentBrickRange:(id)sender;
- (void)enableOrDisableControls;
- (IBAction)hideClause:(id)sender;
//- (IBAction)hideSection:(id)sender;
- (IBAction)hideWord:(id)sender;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;
- (IBAction)showClause:(id)sender;
//- (IBAction)showSection:(id)sender;
- (IBAction)showWord:(id)sender;
- (void)updateView;

@end