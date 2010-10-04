//
//  MortorInterfaceView.m
//  FaceDetect
//
//  Created by UEHARA AKIHIRO on 10/09/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MortorInterfaceView.h"

@implementation MortorInterfaceView
-(id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = FALSE;
		
		// location manager
		locManager_ = [[CLLocationManager alloc] init];
		locManager_.headingFilter = 1;
		locManager_.headingOrientation = CLDeviceOrientationLandscapeRight;
		
		// ui update timer
		[[NSTimer scheduledTimerWithTimeInterval:0.05
		    							  target:self
										selector:@selector(uiUpdate)
										userInfo:nil
										 repeats:YES] retain];
	}
	return self;
}
-(void)uiUpdate {
	[self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat deltaY = self.bounds.size.height / 4;
	
	// when face has not been detected for 2 seconds, stop mortor
	NSTimeInterval not_detected_for = [NSDate timeIntervalSinceReferenceDate] - last_face_detected_at_;
	if(not_detected_for > 0.3) {
		target_degree_ = 0;
	} 

	// set mortor power and direction
	turn_left_ = (target_degree_ < 0) ? TRUE : FALSE;
	int degree = abs(target_degree_);
	if(degree > 30) {
		mortor_power_ = 1;
	} else if(degree > 5) {
		mortor_power_ = 1;
	} else {
		mortor_power_ = 0;
	}
		
	// set current mortor phase
	phase_ = (phase_ +1) %5;
	if(phase_ <= 0) {
		phase_ = 1;
	}

//	NSLog(@"output mortor sig: isTurnLeft %d mortor power: %d", turn_left_, mortor_power_);
	
	// draw left circle
	if(turn_left_) {
		if(mortor_power_ >= phase_) {
			CGContextSetRGBFillColor(context, 255.0, 255.0, 255.0, 1);	
		} else {
			CGContextSetRGBFillColor(context, 0, 0, 0, 1);
		}
	} else  {
		CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	}
	CGRect left_circle = CGRectMake(self.bounds.size.width - deltaY /2, deltaY * 1, deltaY, deltaY);
	CGContextFillEllipseInRect(context, left_circle);
	// draw right circle
	if(! turn_left_) {
		if(mortor_power_ >= phase_) {
			CGContextSetRGBFillColor(context, 255.0, 255.0, 255.0, 1);	
		} else {
			CGContextSetRGBFillColor(context, 0, 0, 0, 1);
		}
	} else  {
		CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	}	
	CGRect right_circle = CGRectMake(self.bounds.size.width - deltaY /2, deltaY * 2, deltaY, deltaY);
	CGContextFillEllipseInRect(context, right_circle);
}
-(void)move:(int)degree {
	last_face_detected_at_ = [NSDate timeIntervalSinceReferenceDate];
	target_degree_ = degree;
//	NSLog(@"move degree: %d target: %d", degree, target_degree_);
}
@end
