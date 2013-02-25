//
//  ViewController.h
//  vibrationSample
//
//  Created by Akihiro Uehara on 12/01/25.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "vibrationController.h"

@interface ViewController : UIViewController {
    vibrationController *vibrationController_;
}
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *periodSlideBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *vibrationButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *periodTextLabel;

- (IBAction)periodSliderBarValueChanged:(id)sender;
- (IBAction)touchUpInside:(id)sender;
@end
