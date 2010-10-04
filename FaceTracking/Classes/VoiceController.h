//
//  VoiceController.h
//  FaceDetect
//
//  Created by UEHARA AKIHIRO on 10/09/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VoiceController : NSObject<AVAudioPlayerDelegate> {
@private
	NSArray *audioFiles_;
	AVAudioPlayer *player_;
	NSTimeInterval lastPlayedAt_;
}
-(void) setFaceRectangles:(NSArray *)rectangles;
@end
