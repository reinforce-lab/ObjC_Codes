//
//  ViewController.h
//  NotificationCustomSoundSample
//
//  Created by akihiro uehara on 2013/01/28.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *delayTimeTextLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *soundFileSegmentButton;
- (IBAction)notificationButtonTouchUpInside:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *soundFilePicker;

@end
