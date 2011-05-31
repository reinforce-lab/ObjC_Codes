//
//  realTimeOpenCV_frameAccessSpeedViewController.m
//  realTimeOpenCV_frameAccessSpeed
//
//  Created by 上原 昭宏 on 11/05/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "realTimeOpenCV_frameAccessSpeedViewController.h"

@interface realTimeOpenCV_frameAccessSpeedViewController()
-(void)loadAsset:(NSURL *)url;
-(void)loadAssetCnt;
-(void)process;
@end

@implementation realTimeOpenCV_frameAccessSpeedViewController
#pragma mark -
-(void)assetSelected:(ALAsset *)asset
{
	NSDictionary *urls = [asset valueForProperty:ALAssetPropertyURLs];
	if([urls count] > 0) {
		[url_ release];
		url_ = [[[urls allValues] objectAtIndex:0] retain];
		[self loadAsset:url_];
	}	
	[pickupVC_ dismissModalViewControllerAnimated:YES];
}
-(void)assetSelectionCanceled
{
	//	[avPlayerView_ play:asset_  gravity:gravity_ testMode:testMode_];
	[pickupVC_ dismissModalViewControllerAnimated:YES];
}
#pragma mark - Private methods
-(void)loadAsset:(NSURL *)url
{
	// disable buttons
	loadVideoButton_.enabled = NO;
	pixelFormatButton_.enabled = NO;
	[_indicator startAnimating];
	
	// clear labesl	
	movieDuratinLabel_.text = @"";
	frameSizeLabel_.text = @"";
	transformLabel_.text = @"";
	processDurationLabel_.text = @"";
	
	// load asset
	[asset_ release];
	asset_ = [[AVURLAsset URLAssetWithURL:url options:nil] retain];
	[asset_ loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
		[self loadAssetCnt];
	}];	
}
	
- (void)loadAssetCnt
{
	NSError *error;
	// does asset contains video track?
	NSArray *tracks = [asset_ tracksWithMediaType:AVMediaTypeVideo];
	if([tracks	count] == 0) {
		NSLog(@"%s asset does not contain a video trac.", __func__);
		return;
	}
	
	// get asset reader
	[reader_ release];
	reader_ = [[AVAssetReader assetReaderWithAsset:asset_ error:&error] retain];
	if(error) {
		NSLog(@"%s [AVAssetReader assetReaderWithAsset:asset_ error:] fails. %@", __func__, error);
		return;
	}
	
	// get frame size and count
	AVAssetTrack *videoTrack = [tracks objectAtIndex:0];	
 	CGSize frameSize = [videoTrack naturalSize];	
	float  frameRate = [videoTrack nominalFrameRate];	
	CMTimeRange range = videoTrack.timeRange;	
	
	movieDuratinLabel_.text = [NSString stringWithFormat:@"%d sec", (int)CMTimeGetSeconds(range.duration)];
	frameSizeLabel_.text = [NSString stringWithFormat:@"(%d,%d) rate:%d", 
							(int)frameSize.width, (int)frameSize.height,
							(int)frameRate];
	
	CGAffineTransform t = videoTrack.preferredTransform;
	transformLabel_.text = [NSString stringWithFormat:@"a=%d b=%d c=%d d=%d",
							(int)t.a, (int)t.b, (int)t.c, (int)t.d ];
		
	// 動画の向き、変形を設定
	/*
	if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)  videoOrientation_ = AVCaptureVideoOrientationPortrait;
	if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  videoOrientation_ = AVCaptureVideoOrientationPortraitUpsideDown;
	if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)   videoOrientation_ = AVCaptureVideoOrientationLandscapeRight;
	if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) videoOrientation_ = AVCaptureVideoOrientationLandscapeLeft;		
	isPortrait_ = (videoOrientation_ == AVCaptureVideoOrientationPortrait) || (videoOrientation_ == AVCaptureVideoOrientationPortraitUpsideDown);
	*/
	unsigned int pf;
	switch (pixelFormat_) {
		case 0: pf = kCVPixelFormatType_32BGRA; break;
		case 1: pf = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange; break;
		case 2: pf = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange; break;
	}

	// get track reader output
	// see CVPixelBuffer.h for available options
	// setting AVVideoSettings.h or <CoreVideo/CVPixelBuffer.h>	
	NSDictionary* outputSettings = 	
	[NSDictionary dictionaryWithObjectsAndKeys:								  
	 [NSNumber numberWithUnsignedInt:pf], (id)kCVPixelBufferPixelFormatTypeKey,
	 nil];	
	
	[videoOutput_ release];
	videoOutput_ = [[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:outputSettings] retain];	
	if(videoOutput_ == nil) {
		NSLog(@"%s AVAssetReaderTrackOutput initWithTrack failed for the video track.", __func__);
		return;
	}
	if(![reader_ canAddOutput:videoOutput_]) {
		NSLog(@"%s [reader canAddOutput:moviewOutput] returns false. AVAssetReaderTrackOutput can not be add to the AVAssetReader.", __func__);
		return;
	}
	[reader_ addOutput:videoOutput_];
	
	// start reading
	if(![reader_ startReading]) {
		NSLog(@"%s AVAssetReader can not start reading.", __func__);
		return;
	}	

	[startTime_ release];
	startTime_ = [[NSDate date] retain];
	[self process];	
	// end of processing
	NSTimeInterval ptime = [[NSDate date] timeIntervalSinceDate: startTime_];
	dispatch_async(dispatch_get_main_queue(), ^{
		processDurationLabel_.text = [NSString stringWithFormat:@"%0.1f sec", ptime];
		
		loadVideoButton_.enabled   = YES;
		pixelFormatButton_.enabled = YES;
		[_indicator stopAnimating];
	});
}
-(void)process 
{
	//IplImage *iplimage;	
	CMSampleBufferRef buf;
	while(1){
		// get buffer pointer
		buf = [videoOutput_ copyNextSampleBuffer];
		if(buf) {		
			// lock the pointer
			CVImageBufferRef framebuf = CMSampleBufferGetImageBuffer(buf);
			CVPixelBufferLockBaseAddress(framebuf,  0);

		//create IplImage and process it			
		//uint8_t *bufferBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(framebuf, 0);
		//uint8_t *bufferBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(framebuf);
			/*			
		if (bufferBaseAddress) {

			//size_t width  = CVPixelBufferGetWidth(framebuf);
			//size_t height = CVPixelBufferGetHeight(framebuf);				
			iplimage = cvCreateImageHeader(cvSize(width, height), IPL_DEPTH_8U, 1);
			iplimage->imageData = (char*)bufferBaseAddress;			
			// image processing			
			cvReleaseImageHeader(&iplimage);			
			 */
			// unlock framebuffer, release buffer
			CVPixelBufferUnlockBaseAddress(framebuf, 0);
			CFRelease(buf);
		} else {
			break; // buf == NULL
		}
	}
}
#pragma mark - event hander
-(IBAction)loadMovieButtonTouched:(id)sender
{
	pickupVC_ = [[assetPickupViewController alloc] initWithDelegate:self];	
	pickupVC_.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:pickupVC_ animated:YES];
	[pickupVC_ release];	
}
-(IBAction)pixelFormatButtonTouched:(id)sender
{
	pixelFormat_ = (pixelFormat_ +1) % 3;
	switch (pixelFormat_) {
		case 0: [pixelFormatButton_ setTitle:@"32BGRA" forState:UIControlStateNormal]; break;
		case 1: [pixelFormatButton_ setTitle:@"420YpCbCr8BiPlanarFullRange" forState:UIControlStateNormal]; break;
		case 2: [pixelFormatButton_ setTitle:@"420YpCbCr8BiPlanarVideoRange" forState:UIControlStateNormal]; break;
	}
}
@end
