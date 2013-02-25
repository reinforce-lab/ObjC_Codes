//
//  vibrationController.m
//  vibrationSample
//
//  Created by Akihiro Uehara on 12/01/25.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "vibrationController.h"

@interface vibrationController()
-(void)invalidateTimer;
-(void)timerCallback:(NSTimer *)timer;
@end

@implementation vibrationController
#pragma - Variables
NSTimer *timer_;
#pragma mark - Constructor
-(void)dealloc
{
    [self invalidateTimer];
}
#pragma mark - Private methods
-(void)invalidateTimer
{
    if(timer_ != nil) {
        [timer_ invalidate];
    }
    timer_ = nil;
}
#pragma mark - Callback methods
-(void)timerCallback:(NSTimer *)timer
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
#pragma mark - Public methods
-(void)vibrate:(float)period
{
    [self invalidateTimer];
    timer_ = [NSTimer 
              scheduledTimerWithTimeInterval:period 
              target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}
-(void)stop
{
    [self invalidateTimer];
}
@end
