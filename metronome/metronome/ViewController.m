//
//  ViewController.m
//  metronome
//
//  Created by 昭宏 上原 on 11/10/21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
MetronomePlayer *player_;

@synthesize stopButton_;
@synthesize startButton_;
@synthesize tempoSlidebar_;
@synthesize tempoLabel_;
@synthesize indicatorView_;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    player_ = [[MetronomePlayer alloc] initWithSounds:@"b_005" snd1:@"b_043"];
    player_.delegate = self;
    [player_ addObserver:self forKeyPath:@"tempo" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidUnload
{
    [player_ stop];
    
    [self setStopButton_:nil];
    [self setStartButton_:nil];
    [self setTempoSlidebar_:nil];
    [self setTempoLabel_:nil];
    [self setIndicatorView_:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)stopButtonTouchUpInside:(id)sender {
    [player_ stop];
}

- (IBAction)startButtonTouchUpInside:(id)sender {
    [player_ start];
}

- (IBAction)tempoSliderbarValueChanged:(id)sender {
    player_.tempo = (int)tempoSlidebar_.value;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        tempoLabel_.text = [NSString stringWithFormat:@"%d", player_.tempo];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - MetronomePlayerDelegate
-(void)keepTime
{
    [UIView 
     animateWithDuration:0.1           
     animations:^{
         indicatorView_.backgroundColor = [UIColor orangeColor];
     }                                    
     completion:^(BOOL finished) {                        
         [UIView animateWithDuration:0.1 animations:^{
             indicatorView_.backgroundColor = [UIColor grayColor];
         }];
     }];
}
@end
