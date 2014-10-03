//
//  ViewController.m
//  visitMonitoringTest
//
//  Created by Akihiro Uehara on 2014/10/03.
//  Copyright (c) 2014年 Akihiro Uehara. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate> {
    NSMutableString *_log;
    CLLocationManager *_locationManager;
}
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

- (IBAction)clearButtonTouchUpInside:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self clearLog];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    // requesting a permission. NSLocationAlwaysUsageDescription key must be in your app’s Info.plist file.
    [_locationManager requestAlwaysAuthorization];
    
//    _locationManager.pausesLocationUpdatesAutomatically = YES;


}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_locationManager stopMonitoringVisits];
    _locationManager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self clearLog];
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [_locationManager startMonitoringVisits];
            break;
        default:
            break;
    }
    [self write:[NSString stringWithFormat:@"%s status:%d", __PRETTY_FUNCTION__, status]];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self write:[NSString stringWithFormat:@"%s error:%@", __PRETTY_FUNCTION__, error]];
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self write:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
}
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self write:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
}
- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    [self write:[NSString stringWithFormat:@"%@", visit]];
}
-(void)write:(NSString *)msg {
    NSLog(@"%@", msg);
    [_log appendFormat:@"%@\n", msg];
    self.logTextView.text = _log;
}
#pragma mark Methods

-(void)clearLog {
    _log = [[NSMutableString alloc] init];
    self.logTextView.text = @"";
}

- (IBAction)clearButtonTouchUpInside:(id)sender {
    [self clearLog];
}
@end
