//
//  FlipsideViewController.m
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright Reinforce lab. 2010. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

#pragma mark -
#pragma mark properties
@synthesize delegate;
@synthesize mTrashButton;
@synthesize mFileListTextBox;

#pragma mark -
#pragma mark public methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
	// updating data file list
	[self updateDataFileList];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Event handlers
- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}
- (IBAction)clear:(id)sender {
	[self removeDataFiles];
	[self updateDataFileList];
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:@"Delete data" 
							  message:@"All GPS data files have been removed." 
							  delegate:self 
							  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}

#pragma mark -
#pragma mark private methods
- (NSArray *)getDocumentFileList {
	// getting document directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	// getting file list
	NSFileManager *mgr = [NSFileManager defaultManager];
	NSArray *files= [mgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
	NSMutableArray *filePaths = [NSMutableArray arrayWithCapacity:[files count]];
	for(NSString *file in files) {
		[filePaths addObject:[documentsDirectory stringByAppendingPathComponent:file]];
	}
	return filePaths;
}
- (void)removeDataFiles {
	// removing files
	NSArray *files = [self getDocumentFileList];
	NSFileManager *mgr = [NSFileManager defaultManager];
	for(NSString *file in files) {
		[mgr removeItemAtPath:file error:nil];
	}
}
- (void)updateDataFileList {
	NSArray *files = [self getDocumentFileList];
	NSMutableString *txt = [[[NSMutableString alloc] init] autorelease];
	for(NSString *file in files) {
		if([[file pathExtension] isEqualToString:@"gpx"]) {
			[txt appendFormat:@"%@\n", [file lastPathComponent]];
		}
	}
	mFileListTextBox.text = txt;
}
@end
