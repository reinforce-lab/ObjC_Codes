//
//  MainViewController.h
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright Reinforce lab. 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

#import "BackgroundLocationRecorderAppDelegate.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, LocationRecorderDelegate> {	
@private	
    NSManagedObjectContext *managedObjectContext_;	    
	NSMutableString *logText_;
	NSInteger logUpdatedCounter_;
	NSUInteger dataCount_;
	LocationRecorder *recorder_;
	
	UIBarButtonItem *startStopButton;
	UIBarButtonItem *deleteButton;
	UIBarButtonItem *dataButton;
	
	UILabel *_longitudeLabel;
	UILabel *_latitudeLabel;
	UILabel *_accuracyLabel;
	UILabel *_acquisitionDurLabel;
	UILabel *_dataPointsLabel;
	
	NSTimeInterval lastLocationAcqTime_;
	NSTimeInterval averageTime_;
}

@property (nonatomic, readonly) LocationRecorder *recorder;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dataButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *deleteButton;

@property (nonatomic, retain) IBOutlet UILabel *_longitudeLabel;
@property (nonatomic, retain) IBOutlet UILabel *_latitudeLabel;
@property (nonatomic, retain) IBOutlet UILabel *_accuracyLabel;
@property (nonatomic, retain) IBOutlet UILabel *_acquisitionDurLabel;
@property (nonatomic, retain) IBOutlet UILabel *_dataPointsLabel;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)showInfo:(id)sender;
- (IBAction)clearRecords:(id)sender;
- (IBAction)toggleRecording:(id)sender;
- (IBAction)deleteDataFile:(id)sender;
@end
