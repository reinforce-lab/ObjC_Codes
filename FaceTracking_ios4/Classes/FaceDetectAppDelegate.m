//
//  FaceDetectAppDelegate.m
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright University of Exeter 2009. All rights reserved.
//

#import "FaceDetectAppDelegate.h"
#import "FaceTrackingViewController.h"

@implementation FaceDetectAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	FaceTrackingViewController *controller = [[FaceTrackingViewController alloc] init];
	[window addSubview:controller.view];
	
    // Override point for customization after application launch.
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}
@end
