//
//  realTimeOpenCV_frameAccessSpeedViewController.h
//  realTimeOpenCV_frameAccessSpeed
//
//  Created by 上原 昭宏 on 11/05/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "assetPickupViewController.h"

@interface realTimeOpenCV_frameAccessSpeedViewController : UIViewController<assetSelectionDelegate> {
    IBOutlet UIButton *loadVideoButton_;
	IBOutlet UIButton *pixelFormatButton_;
	
	IBOutlet UIActivityIndicatorView *_indicator;
	
	IBOutlet UILabel *movieDuratinLabel_;
	IBOutlet UILabel *frameSizeLabel_;
	IBOutlet UILabel *transformLabel_;
	IBOutlet UILabel *processDurationLabel_;
		
	assetPickupViewController *pickupVC_;
		
	AVAssetReader *reader_;
	AVAssetReaderTrackOutput *videoOutput_;
						 
	NSURL *url_;
	NSDate  *startTime_;
	AVAsset *asset_;
	int pixelFormat_;
}

-(IBAction)loadMovieButtonTouched:(id)sender;
-(IBAction)pixelFormatButtonTouched:(id)sender;
@end
