//
//  ViewController.m
//  NotificationCustomSoundSample
//
//  Created by akihiro uehara on 2013/01/28.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray *_soundFiles;
    NSInteger _soundFilesIndex;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _soundFiles = [NSArray arrayWithObjects:
                   @"PikaPika30sec.wav",
                   @"bochika15sec.wav",
                   @"wink15sec.wav",
                   @"blink_wink15sec.wav",
                   @"fuwafuwa.mp3",
                   @"yukuri15sec.wav",
                   @"boanboan15sec.wav",
                   @"nemunemu15sec.wav",
                   nil];

    self.delayTimeTextLabel.delegate = self;
    self.soundFilePicker.dataSource  = self;
    self.soundFilePicker.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)notificationButtonTouchUpInside:(id)sender {
    // 現在の通知をすべて消す
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // 新しい通知を登録
    int seconds          = [self.delayTimeTextLabel.text intValue];
    NSString *soundFileName = [_soundFiles objectAtIndex:_soundFilesIndex];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
    notification.timeZone = [NSTimeZone defaultTimeZone];

    notification.alertAction = @"表示";
    notification.alertBody = [NSString stringWithFormat:@"カスタム音 %@ 再生" , soundFileName];
    notification.hasAction = NO; // アプリに遷移しない
    
    notification.soundName = soundFileName; //音ファイル設定
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_soundFiles count];
}
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_soundFiles objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _soundFilesIndex = row;
}
@end
