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
#pragma mark override methods
- (void)loadView {
	[super loadView];	
}

- (void)viewDidLoad {
    [super viewDidLoad];	

	self.view.backgroundColor = [UIColor blackColor];	
		
	// VideoSession initialization
	[self initVideoSession];
	[self initOpenCV];
		
	// adding camera preview layer	
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
	previewLayer.frame = CGRectMake(0,0, 320, 460); // preview layer fills the view
	[self.view.layer addSublayer:previewLayer];		
	// adding views
/*	
	uiImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
	[self.view addSubview:uiImageView_];
 */
	overlayView_ =[[RectanglesOverlayView alloc] initWithFrame:previewLayer.frame];
	[self.view addSubview:overlayView_];
	mortorInterfaceView_ = [[MortorInterfaceView alloc] initWithFrame:previewLayer.frame];
	[self.view addSubview:mortorInterfaceView_];
	voiceController_ = [[VoiceController alloc] init];
	
	// starting video session (starting preview)
	[captureSession startRunning];	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[overlayView_ release];
	[mortorInterfaceView_ release];
	[voiceController_ release];
	
	[captureSession release];
	[videoOutput release];

	[self releaseOpenCV];
    [super dealloc];
}

#pragma mark -
#pragma mark private methods
- (void)initVideoSession {
	NSError *error;
	captureSession = [[AVCaptureSession alloc] init];
//	captureSession.sessionPreset = AVCaptureSessionPreset640x480;
	captureSession.sessionPreset = AVCaptureSessionPresetMedium;

	// queue for sample buffer callback
	dispatch_queue_t queue = dispatch_queue_create("videoBufferQueue", NULL);
	dispatch_queue_t high_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queue, high_queue);
	
	// setting up vidoe input
	//	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	NSLog(@"video device count: %d", [devices count]);
	AVCaptureDevice *videoDevice = [devices objectAtIndex:1];	
/*	if(videoDevice.hasTorch) {
		if( [videoDevice lockForConfiguration:&error] ) {
			videoDevice.torchMode = AVCaptureTorchModeOff;
			[videoDevice unlockForConfiguration];
		}		
	}*/
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	if(error) {
		NSLog(@"Video input device initialization error. %s, %@",__func__, error);
	}
	[captureSession addInput:videoInput];
	
	// setting up video output
	videoOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
	// Specify the pixel format
    videoOutput.videoSettings = [NSDictionary dictionaryWithObject:
								 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];

								
	[videoOutput setSampleBufferDelegate:self queue:queue];
	// video frame rate
	videoOutput.minFrameDuration = CMTimeMake(1, FrameRate); 
 	videoOutput.alwaysDiscardsLateVideoFrames = YES; // allow dropping a frame when its disposing time ups, default is YES
	[captureSession addOutput:videoOutput];
		
	// setting up audio input
	AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
	if(error) {
		NSLog(@"Audio input device initialization error. %s, %@",__func__, error);
	}
	[captureSession addInput:audioInput];
	
	// setting up audio output
	/*
	audioOutput = [[[AVCaptureAudioDataOutput alloc] init] autorelease];
	[captureSession addOutput:audioOutput];
	[audioOutput setSampleBufferDelegate:self queue:queue];
	*/	
	dispatch_release(queue);		
}
// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    if (!colorSpace) 
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
	
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
	
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, 
															  NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage = 
	CGImageCreate(width,
				  height,
				  8,
				  32,
				  bytesPerRow,
				  colorSpace,
				  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
				  provider,
				  NULL,
				  true,
				  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
	
	// Create and return an image object representing the specified Quartz image
	/*
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformMakeTranslation(0.0, width);
	transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, height, width), cgImage);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
   */
	UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
	
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
    return image;	
}
- (void) initOpenCV {
	// Load XML
	NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	cascade_ = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
	storage_ = cvCreateMemStorage(0);	
}
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
	CGImageRef imageRef = image.CGImage;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

- (void) opencvFaceDetect:(UIImage *)originalImage  {	
//	NSTimeInterval t1 = [NSDate timeIntervalSinceReferenceDate];
	cvSetErrMode(CV_ErrModeParent);
	
	IplImage *image = [self CreateIplImageFromUIImage:originalImage];
	
	// Scaling down
	IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
	cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
	int scale = 2;
	
	// Detect faces and draw rectangle on them
	CvSeq* faces = cvHaarDetectObjects(small_image, cascade_, storage_, 1.2f, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(20, 20));
	cvReleaseImage(&small_image);	
	
	// Create canvas to show the results
	/*	
	CGImageRef imageRef = originalImage.CGImage;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef contextRef = CGBitmapContextCreate(NULL, originalImage.size.width, originalImage.size.height, 8, originalImage.size.width * 4,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), imageRef);
	
	CGContextSetLineWidth(contextRef, 4);
	CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 1.0, 0.5);
	*/
	// Draw results on the iamge
	NSMutableArray *rects = [[NSMutableArray alloc] initWithCapacity:faces->total];
	for(int i=0; i< faces->total; i++) {
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, 0);
		CGRect rect = CGRectMake((CGFloat)(cvrect.x * scale) / originalImage.size.width, 													 
								 (CGFloat)(cvrect.y * scale) / originalImage.size.height, 
								 (CGFloat)(cvrect.width * scale)  / originalImage.size.width, 
								 (CGFloat)(cvrect.height * scale) / originalImage.size.height);								
		[rects addObject:[NSValue valueWithCGRect:rect]];
	}
	[faceRectangles_ release];
	faceRectangles_ = rects;
	/*
	for(int i = 0; i < faces->total; i++) {								
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		// Calc the rect of faces
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
		CGRect face_rect = CGContextConvertRectToDeviceSpace(contextRef, 
															 CGRectMake(cvrect.x * scale, cvrect.y * scale, cvrect.width * scale, cvrect.height * scale));
		CGContextStrokeRect(contextRef, face_rect);
		[pool release];		
	}
	 */					
	/*
	UIImage *returnImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(contextRef)];
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
		
	return returnImage;*/
	
//	NSTimeInterval t2 = [NSDate timeIntervalSinceReferenceDate];
//	NSLog(@"det time: %lf", t2 - t1);
//	return originalImage;
}
-(void)releaseOpenCV{
	cvReleaseMemStorage(&storage_);
	cvReleaseHaarClassifierCascade(&cascade_);
}

#pragma mark -
#pragma mark callback methods
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef) sampleBuffer fromConnection:(AVCaptureConnection*)connection {	
	UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
	[self opencvFaceDetect:image];		
	dispatch_async(dispatch_get_main_queue(), ^ {
		[overlayView_ updateRectangles:faceRectangles_];
		[voiceController_ setFaceRectangles:faceRectangles_];				
		if([faceRectangles_ count] > 0) {
			CGRect rect = [[faceRectangles_ objectAtIndex:0] CGRectValue];
			NSLog(@"det rect: %1.2f %1.2f %1.2f %1.2f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			int diff_degree = (int)((rect.origin.x + rect.size.width / 2 - 0.5) * 40);
			[mortorInterfaceView_ move:diff_degree];	
		}
	});			
}
@end
