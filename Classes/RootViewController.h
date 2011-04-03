/*
 File: RootViewController.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: Controls the view that appears initially. (Summary view?)
 */

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
}

@property (nonatomic, retain) IBOutlet UITextView *logTextView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextView *passageTitlesTextView;

// Go to view for learning a passage. Show Philippians 2.
- (IBAction)goToPhilippians:(id)sender;

// For dev. Make the Core Data store for default data from a property list. The resulting store can be used to initialize the persistent store on the user's device.
- (IBAction)makeDefaultDataStore:(id)sender;

@end
