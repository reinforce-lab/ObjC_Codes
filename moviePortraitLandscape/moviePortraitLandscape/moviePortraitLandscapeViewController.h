//
//  moviePortraitLandscapeViewController.h
//  moviePortraitLandscape
//
//  Created by 上原 昭宏 on 11/05/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "avPlayerView.h"
#import "assetPickupViewController.h";

@interface moviePortraitLandscapeViewController : UIViewController<assetSelectionDelegate> {
    IBOutlet avPlayerView *avPlayerView_;
	
	IBOutlet UIButton *loadVideoButton_;
	IBOutlet UIButton *videoGravityButton_;
	IBOutlet UIButton *testModeButton_;

	assetPickupViewController *pickupVC_;
	
	AVAsset *asset_;
	NSString *gravity_;
	int gravityMode_;
	int testMode_;
}
-(IBAction)loadVideoButtonTouchUpInside:(id)sender;
-(IBAction)videoGravityButtonTouchUpInside:(id)sender;
-(IBAction)testModeButtonTouchUpInside:(id)sender;
@end
