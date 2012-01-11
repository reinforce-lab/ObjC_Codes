//
//  FaceTrackingViewController.m
//
//  Created by Akihiro Uehara on 2010/09/21.
//  Copyright 2010 Reinforce Lab. All rights reserved.
//
// Details are described in : Technical Q&A QA1702: How to capture video frames from the camera as images using AV Foundation

#import "FaceTrackingViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define FrameRate 24

@implementation FaceTrackingViewController
@synthesize context = _context;

#pragma mark override methods
- (void)viewDidLoad {
    [super viewDidLoad];	

    faceDetector_ = [CIDetector 
                     detectorOfType:CIDetectorTypeFace context:nil 
                     options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
//    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
//                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
	self.view.backgroundColor = [UIColor blackColor];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(!self.context) {
        NSLog(@"Failed to create ES.");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glGenRenderbuffers(1, &renderBuffer_);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer_);
    
    coreImageContext_ = [CIContext contextWithEAGLContext:self.context];
   
	// VideoSession initialization
	[self initVideoSession];		

  	// starting video session (starting preview)
	[session_ startRunning];	
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    /*
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }*/
}
#pragma mark - private methods
- (void)initVideoSession {
	NSError *error;
    
    session_ = [AVCaptureSession new];
    [session_ beginConfiguration];
    session_.sessionPreset = AVCaptureSessionPreset640x480;
	
	// setting up vidoe input
	//	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	NSLog(@"video device count: %d", [devices count]);
	AVCaptureDevice *videoDevice = [devices objectAtIndex:1];	

	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	if(error) {
		NSLog(@"Video input device initialization error. %s, %@",__func__, error);
	}
	[session_ addInput:videoInput];
	
	// setting up video output
	AVCaptureVideoDataOutput *videoOutput = [AVCaptureVideoDataOutput new];
	// Specify the pixel format
    videoOutput.videoSettings = [NSDictionary dictionaryWithObject:
								 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
	// queue for sample buffer callback
	dispatch_queue_t queue = dispatch_queue_create("videoqueue", NULL);  
    [videoOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);		    
 	videoOutput.alwaysDiscardsLateVideoFrames = YES; // allow dropping a frame when its disposing time ups, default is YES
	[session_ addOutput:videoOutput];
    
    [session_ commitConfiguration];
}

#pragma mark - callback methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer]; 
    /*
    image = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:
             kCIInputImageKey, image,
             @"inputColor0", [CIColor colorWithRed:0.0 green:0.2 blue:0.0],
             @"inputColor1", [CIColor colorWithRed:0.0 green:0.0 blue:1.0],
             nil].outputImage;*/
    [coreImageContext_ drawImage:image atPoint:CGPointZero fromRect:[image extent] ];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    // face detection
    NSArray *features = [faceDetector_ 
                         featuresInImage:image                       
                         options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:8] forKey:CIDetectorImageOrientation]];
    NSLog(@"%@", features);
    /*
     Value Location of the origin of the image
     1 Top, left
     2 Top, right
     3 Bottom, right
     4 Bottom, left
     5 Left, top
     6 Right, top
     7 Right, bottom
     8 Left, bottom
     */

}
@end
