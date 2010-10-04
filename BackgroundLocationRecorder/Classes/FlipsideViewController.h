//
//  FlipsideViewController.h
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright Reinforce lab. 2010. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController {
@private
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UIBarButtonItem *mTrashButton;
	IBOutlet UITextView *mFileListTextBox;
}
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mTrashButton;
@property (nonatomic, retain) IBOutlet UITextView *mFileListTextBox;
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (IBAction)clear:(id)sender;
// private methods
- (void)removeDataFiles;
- (void)updateDataFileList;
- (NSArray *)getDocumentFileList;
@end

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
