//
//  AppDelegate.m
//  NotificationCustomSoundSample
//
//  Created by akihiro uehara on 2013/01/28.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate () <AVAudioPlayerDelegate> {
    AVAudioPlayer *_player;
}
@end

@implementation AppDelegate
static void sessionPropertyChanged(void *inClientData,
								   AudioSessionPropertyID inID,
								   UInt32 inDataSize,
								   const void *inData)
{
	AppDelegate *delegate = (__bridge AppDelegate *)inClientData;
 if( inID == kAudioSessionProperty_AudioRouteChange ) {
		UInt32 size = sizeof(CFStringRef);
		CFStringRef route;
		AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
NSLog(@"%s route channged: %@", __func__, (__bridge NSString *)route );
     /*
        NSString *rt = (__bridge_transfer NSString *)route;
     [phy performSelectorOnMainThread:@selector(setIsHeadSetInWP:)
                              withObject:rt
                           waitUntilDone:false];
      */
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // バッジをクリアする
    application.applicationIconBadgeNumber = 0;
    /*
    // ノティフィケーションでアプリが起動した時に、バッジをクリアする。
    UILocalNotification *localNofify = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(localNofify) {
        application.applicationIconBadgeNumber = 0;
    }
    
    // リモートノーティフィケーションで起動した時に、バッジをクリアする。
    if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        application.applicationIconBadgeNumber = 0;
    }
     */
    
    // AudioSessionをsoloに設定
    AudioSessionInitialize(nil, nil, nil, nil);
    UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, sessionPropertyChanged, (__bridge void*)self);
    
    AudioSessionSetActive(YES);
    
    // リモートノーティフィケーションを設定
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    
    /*	AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, sessionPropertyChanged, (__bridge void*)self);*/
    return YES;
}

// ローカル通知を受信
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *fileType = [notification.soundName pathExtension];
    NSString *fileName = [notification.soundName
                          substringToIndex:([notification.soundName length] - [fileType length] -1)];
    NSLog(@"ローカル通知を受信, fileName: %@, fileType:%@", fileName, fileType);

    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    NSURL *url = [NSURL fileURLWithPath:path];

    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(error) {
        NSLog(@"error = %@", error);
        return;
    }
    _player.delegate = self;
    [_player play];
}

// リモートノーティフィケーションを受信
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"リモートノーティフィケーションを受信");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    _player = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Device ID: %@ %d", deviceToken, [deviceToken length]);
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed in registering remote notification. %@", error);
}

@end
