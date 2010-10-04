//
//  MortorInterfaceView.h
//  FaceDetect
//
//  Created by UEHARA AKIHIRO on 10/09/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface MortorInterfaceView : UIView {
  @private
	CLLocationManager *locManager_;
	NSTimeInterval last_face_detected_at_;
	int target_degree_;
	BOOL turn_left_;
	int mortor_power_;
	int phase_;
}
-(void)move:(int)degree;

@end
