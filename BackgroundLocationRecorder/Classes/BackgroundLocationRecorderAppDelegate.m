//
//  BackgroundLocationRecorderAppDelegate.m
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright Reinforce lab. 2010. All rights reserved.
//

#import "BackgroundLocationRecorderAppDelegate.h"
#import "MainViewController.h"

@implementation BackgroundLocationRecorderAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize locationRecorder;

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    	
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    DebugLog(@"%s",__func__);
    // Override point for customization after application launch.  
	locationRecorder = [[LocationRecorder alloc] init];
    
    // Add the main view controller's view to the window and display.
    [window addSubview:mainViewController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	DebugLog(@"%s",__func__);
//	[locationRecorder addTag:[NSString stringWithFormat:@"%s", __func__]];
	
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	DebugLog(@"%s",__func__);
//	[locationRecorder addTag:@"applicationDidEnterBackground"];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	DebugLog(@"%s",__func__);
//	[locationRecorder addTag:@"applicationWillEnterForeground"];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	DebugLog(@"%s",__func__);
//	[locationRecorder addTag:@"applicationDidBecomeActive"];
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application 
{
	[locationRecorder release];
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[locationRecorder release];
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
