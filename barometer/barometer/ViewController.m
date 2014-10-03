//
//  ViewController.m
//  barometer
//
//  Created by Akihiro Uehara on 2014/10/03.
//  Copyright (c) 2014年 Akihiro Uehara. All rights reserved.
//

#import "ViewController.h"
@import CoreMotion;

@interface ViewController () {
    CMAltimeter *_altimater;
    bool _isFirstSample;
    double _currentValue;
    double _averageValue;
    double _altitudValue;
}

@property (weak, nonatomic) IBOutlet UILabel *currentValueTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageValueTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *variationValueTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeValueTextLabel;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    _isFirstSample = YES;
    
    self.warningTextLabel.hidden = [CMAltimeter isRelativeAltitudeAvailable];
    if([CMAltimeter isRelativeAltitudeAvailable]) {
        _altimater = [[CMAltimeter alloc] init];
        [_altimater startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData *data, NSError *error) {
            [self altitudeDataHandlr:data error:error];
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_altimater stopRelativeAltitudeUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)altitudeDataHandlr:(CMAltitudeData *)data error:(NSError *)error {
    if(error != nil) return;
    
    double altitude = [[data relativeAltitude] doubleValue];
    double pressure = [[data pressure] doubleValue];

    _currentValue = pressure;
    _altitudValue = altitude;

    if(_isFirstSample) {
        _averageValue = pressure;
    } else {
        _averageValue = 0.1 * _currentValue + (1 - 0.1) * _averageValue;
    }
    _isFirstSample = NO;
    
    self.currentValueTextLabel.text  = [NSString stringWithFormat:@"%1.5e", _currentValue];
    self.averageValueTextLabel.text  = [NSString stringWithFormat:@"%1.5e", _averageValue];
    self.altitudeValueTextLabel.text = [NSString stringWithFormat:@"%1.3e", _altitudValue];
    
}
@end
