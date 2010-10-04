//
//  FaceTrackingViewController.h
//
//  Created by Akihiro Uehara on 2010/09/21.
//  Copyright 2010 Reinforce Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import "RectanglesOverlayView.h"
#import "MortorInterfaceView.h"
#import "VoiceController.h"

#import "Utilities.h"
#import "opencv/cv.h"

@interface FaceTrackingViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {		
 @private
	NSArray *faceRectangles_;	
	
//	UIImageView *uiImageView_;
	RectanglesOverlayView *overlayView_;
	MortorInterfaceView *mortorInterfaceView_;
	VoiceController *voiceController_;
	
	//OpenCV
	CvHaarClassifierCascade* cascade_;
	CvMemStorage* storage_;	
	
	//Video capture API
	AVCaptureSession *captureSession;
	AVCaptureVideoDataOutput *videoOutput;
}

- (void) initVideoSession;
- (void) initOpenCV;
- (void) releaseOpenCV;
- (void) opencvFaceDetect:(UIImage *)originalImage; 
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
