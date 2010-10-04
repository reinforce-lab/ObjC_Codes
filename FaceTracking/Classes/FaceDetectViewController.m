//
//  FaceDetectViewController.m
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright University of Exeter 2009. All rights reserved.
//

#import "FaceDetectViewController.h"
#import "Utilities.h"
#import "opencv/cv.h"

@implementation FaceDetectViewController


#pragma mark Instance Methods

- (IBAction)getImageFromCamera:(id) sender {
	pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	NSArray* mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	pickerController.mediaTypes = mediaTypes;
    [self presentModalViewController:pickerController animated:YES];
	
}

- (IBAction)getImageFromPhotoAlbum:(id) sender {
	pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentModalViewController:pickerController animated:YES];
}

- (IBAction)faceDetect:(id) sender {	
	UIImage *processedImage = [Utilities opencvFaceDetect:imageView.image];
	imageView.image = processedImage;
}

#pragma mark UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:YES];
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	image = [Utilities scaleAndRotateImage:image];
    imageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];

	pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		cameraButton.enabled = YES; 
	} else {
		cameraButton.enabled = NO;
	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[pickerController release];
	[imageView release];
    [super dealloc];
}

@end
