/*
 File: RootViewController.h
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 Abstract: Controls the view that appears initially. (Summary view?)
 */

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

// Go to view for learning a passage. Show Philippians 2.
- (IBAction)goToPhilippians:(id)sender;

@end
