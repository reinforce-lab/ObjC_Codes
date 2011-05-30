//
//  moviePortraitLandscapeViewController.m
//  moviePortraitLandscape
//
//  Created by 上原 昭宏 on 11/05/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "moviePortraitLandscapeViewController.h"
#import "assetPickupViewController.h";

@implementation moviePortraitLandscapeViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
-(void)assetSelected:(ALAsset *)asset
{
	NSDictionary *urls = [asset valueForProperty:ALAssetPropertyURLs];
	if([urls count] > 0) {
		NSURL *url = [[urls allValues] objectAtIndex:0];
		[asset_ release];
		asset_ = [[AVURLAsset URLAssetWithURL:url options:nil] retain];
		[asset_ loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
			[avPlayerView_ play:asset_  gravity:gravity_ testMode:testMode_];
		}];
		
		videoGravityButton_.enabled = YES;
		testModeButton_.enabled = YES;
	}	
	[pickupVC_ dismissModalViewControllerAnimated:YES];
}
-(void)assetSelectionCanceled
{
//	[avPlayerView_ play:asset_  gravity:gravity_ testMode:testMode_];
	[pickupVC_ dismissModalViewControllerAnimated:YES];
}

#pragma mark - event handler
/*
// 画面遷移
*/
-(IBAction)loadVideoButtonTouchUpInside:(id)sender
{
	[avPlayerView_ pause];
	
	pickupVC_ = [[assetPickupViewController alloc] initWithDelegate:self];	
	pickupVC_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:pickupVC_ animated:YES];
	[pickupVC_ release];
}
-(IBAction)videoGravityButtonTouchUpInside:(id)sender
{
	gravityMode_ = (gravityMode_ +1) % 3;
	switch (gravityMode_) {
		case 0:
			gravity_ = AVLayerVideoGravityResize;
			[videoGravityButton_ setTitle:@"Resize" forState:UIControlStateNormal];
			break;
		case 1:
			gravity_ = AVLayerVideoGravityResizeAspect;
			[videoGravityButton_ setTitle:@"Aspect" forState:UIControlStateNormal];
			break;
		case 2:
			gravity_ = AVLayerVideoGravityResizeAspectFill;
			[videoGravityButton_ setTitle:@"AspectFill" forState:UIControlStateNormal];
			break;
	}
	[avPlayerView_ play:asset_  gravity:gravity_ testMode:testMode_];
}
-(IBAction)testModeButtonTouchUpInside:(id)sender
{
	testMode_ = (testMode_ +1) % 3;
	switch (testMode_) {
		case 0:  // none
			[testModeButton_ setTitle:@"None" forState:UIControlStateNormal];
			break;
		case 1: 
			[testModeButton_ setTitle:@"PreferredTransoform" forState:UIControlStateNormal];
			break;
		case 2: 
			[testModeButton_ setTitle:@"LayerInst" forState:UIControlStateNormal];
			break;
	}
	[avPlayerView_ play:asset_  gravity:gravity_ testMode:testMode_];	
}
@end
