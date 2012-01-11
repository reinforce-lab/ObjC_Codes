//
//  FaceTrackingViewController.h
//
//  Created by Akihiro Uehara on 2010/09/21.
//  Copyright 2010 Reinforce Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

//
// see http://indieambitions.com/idevblogaday/raw-video-data-app-quick-dirty/
//
@interface FaceTrackingViewController : GLKViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {
 @private
	AVCaptureSession *session_;
    CIContext *coreImageContext_;
    GLuint renderBuffer_;
    CIDetector *faceDetector_;
}
@property (strong, nonatomic) EAGLContext *context;

- (void) initVideoSession;
@end
