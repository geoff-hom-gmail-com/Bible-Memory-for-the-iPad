/*
  Project: bible-memory-ipad
	 File: ShowTextViewController.h
 Abstract:
 
 Created by Geoffrey Hom on 11/22/10.
 */

#import <UIKit/UIKit.h>
#import "PassagesTableViewController.h"

@interface ShowTextViewController : UIViewController <PassagesTableViewDelegate> {
	Passage *currentPassage;
	NSManagedObjectContext *managedObjectContext;
	UITextView *textView;
	UIWebView *webView;
}

@property (nonatomic, retain) Passage *currentPassage;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)editPhrases:(id)sender;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;
- (IBAction)resetBricks:(id)sender;

@end
