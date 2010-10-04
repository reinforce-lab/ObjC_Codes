//
//  MainViewController.m
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright Reinforce lab. 2010. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

NSString *kStartButtonTitle  =@"Start";
NSString *kStopButtonTitle   =@"Stop";

#pragma mark -
#pragma mark properties

@synthesize _longitudeLabel;
@synthesize _latitudeLabel;
@synthesize _accuracyLabel;
@synthesize _acquisitionDurLabel;
@synthesize _dataPointsLabel;

@synthesize startStopButton;
@synthesize managedObjectContext;
@synthesize deleteButton;
@synthesize dataButton;
@synthesize recorder = recorder_;

#pragma mark -
#pragma mark constructor
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return self;
}
- (void)dealloc {
    [managedObjectContext release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController override methods
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	// variable initialization	
	BackgroundLocationRecorderAppDelegate *dlg = [[UIApplication sharedApplication] delegate];
	recorder_ = [dlg.locationRecorder retain];
	recorder_.delegate = self;
	
	// setting button title
	startStopButton.title = kStartButtonTitle;	
}

 // Implement viewWillAppear: to do additional setup before the view is presented. You might, for example, fetch objects from the managed object context if necessary.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];		
}

- (void) viewWillDisappear:(BOOL)animated {	
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	// release instances
	recorder_.delegate = nil;	
	[recorder_ release];	
}


/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark -
#pragma mark FlipsideViewController delegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark LocationRecorder Delegate
-(void) didReceivedNewLocation:(CLLocation *)location
{
	DebugLog(@"%s %@", __func__, location);
	// updating labels		
	_longitudeLabel.text = [NSString stringWithFormat:@"%1.2f", location.coordinate.longitude];
	_latitudeLabel.text  = [NSString stringWithFormat:@"%1.2f", location.coordinate.latitude];
	_accuracyLabel.text  = [NSString stringWithFormat:@"%1.0f", location.horizontalAccuracy];		

	NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - lastLocationAcqTime_;
	lastLocationAcqTime_ = [NSDate timeIntervalSinceReferenceDate];
	averageTime_ = 0.1 * duration + 0.9 * averageTime_; // Low pass filter
	
	_acquisitionDurLabel.text = [NSString stringWithFormat:@"%1.1f", averageTime_];
	_dataPointsLabel.text     = [NSString stringWithFormat:@"%d", dataCount_++];
}
-(void) didRecordCleared
{
}

#pragma mark -
#pragma mark private methods

#pragma mark -
#pragma mark actions
- (IBAction)showInfo:(id)sender 
{        
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}
- (IBAction)clearRecords:(id)sender 
{	
	// clear location recorder
	[recorder_ deleteCurrentFile];
}
- (IBAction)toggleRecording:(id)sender
{
	if([startStopButton.title isEqualToString:kStartButtonTitle ])
	{
		// disable data and delete buttuon
		dataButton.enabled = FALSE;
		deleteButton.enabled = FALSE;
		
		// start location recorder
		[recorder_ startRecording];
		// set button title
		startStopButton.title = kStopButtonTitle;
		// set starting time
		lastLocationAcqTime_   = [NSDate timeIntervalSinceReferenceDate];
		averageTime_ = 0;
	}
	else		
	{
		// stop location recorder
		[recorder_ stopRecording];
//		[recorder_ addTag:[[LocationTag alloc] initWithTag:kLocationStopTag]];		
				
		// clear log textview
		NSString *nullText = @"-";
		_longitudeLabel.text = nullText;
		_latitudeLabel.text  = nullText;
		_accuracyLabel.text  = nullText;
		_acquisitionDurLabel.text = nullText;
		_dataPointsLabel.text     = nullText;
		dataCount_ = 0;
				
		// set button title
		startStopButton.title = kStartButtonTitle;
		
		// enable data/delete button
		dataButton.enabled = TRUE;
		deleteButton.enabled = TRUE;
	}
}
-(IBAction)deleteDataFile:(id)sender
{	
	[recorder_ deleteCurrentFile];
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:@"Delete data" message:@"Current GPS data file has been removed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}
@end
