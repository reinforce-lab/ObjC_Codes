//
//  ViewController.m
//  vibrationSample
//
//  Created by Akihiro Uehara on 12/01/25.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize periodSlideBar;
@synthesize vibrationButton;
@synthesize periodTextLabel;

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
    vibrationController_ = [vibrationController new];
}

- (void)viewDidUnload
{
    [self setPeriodTextLabel:nil];
    [self setPeriodSlideBar:nil];
    [self setVibrationButton:nil];
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

#pragma mark - Event handlers

- (IBAction)periodSliderBarValueChanged:(id)sender {
    periodTextLabel.text = [NSString stringWithFormat:@"%.2f", periodSlideBar.value];

    if(vibrationButton.selected) {
        [vibrationController_ vibrate:periodSlideBar.value];
    }
}

- (IBAction)touchUpInside:(id)sender {
    vibrationButton.selected = ! vibrationButton.selected;
    
    if(vibrationButton.selected) {
        [vibrationController_ vibrate:periodSlideBar.value];
    } else {
        [vibrationController_ stop];
    }
}
@end
