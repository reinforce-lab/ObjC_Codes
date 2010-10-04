//
//  LocationRecorder.h
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright 2010 Reinforce lab.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationRecorderDelegate <NSObject>
@optional
-(void) didReceivedNewLocation:(CLLocation *)newLocation;
@end

@interface LocationRecorder : NSObject <CLLocationManagerDelegate> {
@private
	id<LocationRecorderDelegate> delegate_;	
	
	NSOutputStream *csvStream_;
	NSString *csvFilePath_;
	NSOutputStream *gpxStream_;
	NSString *gpxFilePath_;
	
	CLLocationManager* manager_;
	CLLocation *latestLocation_;
	BOOL isRecording_;
	NSDate *startingAt_;
}
@property (nonatomic, retain)   id<LocationRecorderDelegate> delegate;
@property (nonatomic, readonly) BOOL    isRecording;

- (void) startRecording;
- (void) stopRecording;
- (void) deleteCurrentFile;
- (NSUInteger) write:(NSOutputStream*)inStream string:(NSString*)inString;

@end
