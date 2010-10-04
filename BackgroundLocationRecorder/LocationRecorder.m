//
//  LocationRecorder.m
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright 2010 Reinforce lab.. All rights reserved.
//

#import "LocationRecorder.h"

@implementation LocationRecorder

#pragma mark -
#pragma mark properties
@synthesize delegate = delegate_;
@synthesize isRecording = isRecording_;

#pragma mark -
#pragma mark initialization methods
-(id)init
{
	self = [super self];
	if(self) 
	{
		manager_ = [[CLLocationManager alloc] init];
		manager_.delegate = self;
	}
	return self;
}
- (void) dealloc
{
	[self stopRecording];
	[manager_ release];
	[super dealloc];	 
}

#pragma mark -
#pragma mark public methods
- (void) startRecording
{
	DebugLog(@"%s", __func__);
	[startingAt_ release];
	startingAt_ = [[NSDate date] retain];
	
	// opening data files
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
	NSString *filename = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [format stringFromDate:startingAt_]];
	// gpx file
	[gpxFilePath_ release];
	gpxFilePath_ = [[filename stringByAppendingString:@".gpx"] copy];
	gpxStream_ = [[NSOutputStream alloc] initToFileAtPath:gpxFilePath_ append:NO];
	[gpxStream_ open];
	[self write:gpxStream_ string:
	 @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\n<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" creator=\"BGRecorder\" version=\"1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">\n"];
	[self write:gpxStream_ string:@"<trk>\n<trkseg>\n"];
	
	// csv file
	[csvFilePath_ release];
	csvFilePath_ = [[filename stringByAppendingString:@".csv"] copy];
	csvStream_ = [[NSOutputStream alloc] initToFileAtPath:csvFilePath_ append:NO];
	[csvStream_ open];
	[self write:csvStream_ string:@"#time, latitude, longitude, horizontal_accuracy\n"];
	
	// start recording
	manager_.headingFilter   = kCLHeadingFilterNone;
	manager_.desiredAccuracy = kCLLocationAccuracyBest;
	[manager_ startUpdatingLocation];
	isRecording_ = TRUE;
}
- (void) stopRecording
{
	DebugLog(@"%s", __func__);
	[manager_ stopUpdatingLocation];	
	// closing files	
	[self write:gpxStream_ string:@"</trkseg></trk></gpx>\n"];
	[gpxStream_ close];
	[gpxStream_ release];
	[csvStream_ close];
	[csvStream_ release];
	
	isRecording_ = FALSE;
}
- (void) deleteCurrentFile
{
	NSFileManager *mgr = [NSFileManager defaultManager];
	[mgr removeItemAtPath:gpxFilePath_ error:nil];
	[mgr removeItemAtPath:csvFilePath_ error:nil];
}
#pragma private methods
- (NSUInteger) write:(NSOutputStream*)inStream string:(NSString*)inString
{
	NSData *data;
	
	data = [inString dataUsingEncoding:NSASCIIStringEncoding];
	return [inStream write:(const uint8_t*)[data bytes] maxLength:[data length]];
}


#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DebugLog(@"%s %@", __func__, error);
	// logging error string
	[self stopRecording];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	DebugLog(@"%s", __func__);
	if(newLocation != nil) {
		// writing to files
		[self write:gpxStream_ string:[NSString stringWithFormat:@"<trkpt lat=\"%.6f\" lon=\"%.6f\"/>\n", 
								   newLocation.coordinate.latitude, 
								   newLocation.coordinate.longitude]];
		NSDate *ts = newLocation.timestamp;
		NSDate *t2 = startingAt_;
		[self write:csvStream_ string:[NSString stringWithFormat:@"%lf, %.6f, %.6f, %f\n", 
								   [ts timeIntervalSinceReferenceDate] -[t2 timeIntervalSinceReferenceDate], 
								   newLocation.coordinate.latitude, 
								   newLocation.coordinate.longitude, 
								   newLocation.horizontalAccuracy]];				

		// invoking delegate method
		if([delegate_ respondsToSelector:@selector(didReceivedNewLocation:)]) {		
			[delegate_ didReceivedNewLocation:newLocation];
		}	
	}
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading 
{
}
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return FALSE;
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
//	NSLog(@"%s %@",__func__, region);
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
//	NSLog(@"%s %@",__func__, region);
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
//	NSLog(@"%s %@",__func__, error);
}
			
@end
