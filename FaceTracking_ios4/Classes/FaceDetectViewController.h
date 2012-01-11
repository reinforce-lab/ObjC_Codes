//
//  FaceDetectViewController.h
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright University of Exeter 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceDetectViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

	IBOutlet UIImageView *imageView;
	IBOutlet UIBarButtonItem *cameraButton;
	UIImagePickerController *pickerController;

}

- (IBAction)getImageFromCamera:(id) sender;
- (IBAction)getImageFromPhotoAlbum:(id) sender;
- (IBAction)faceDetect:(id) sender;

@end

