//
//  ViewController.h
//  metronome
//
//  Created by 昭宏 上原 on 11/10/21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetronomePlayer.h"

@interface ViewController : UIViewController<MetronomePlayerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *stopButton_;
@property (strong, nonatomic) IBOutlet UIButton *startButton_;
@property (strong, nonatomic) IBOutlet UISlider *tempoSlidebar_;
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel_;
@property (strong, nonatomic) IBOutlet UIView *indicatorView_;

- (IBAction)stopButtonTouchUpInside:(id)sender;
- (IBAction)startButtonTouchUpInside:(id)sender;
- (IBAction)tempoSliderbarValueChanged:(id)sender;

@end
