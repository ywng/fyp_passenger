//
//  TaxiBookViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 30/10/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "TaxiBookViewController.h"

@interface TaxiBookViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *bestLocation;

@end

@implementation TaxiBookViewController

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)updateLabelWithLocation:(CLLocation *)location
{
    [self.latitudeLabel setText:[NSString stringWithFormat:@"latitude: %.8g", location.coordinate.latitude]];
    [self.longitudeLabel setText:[NSString stringWithFormat:@"longitude: %.8g", location.coordinate.longitude]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        
        // prepare getting a list of available location
        [self updateLabelWithLocation:location];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        NSLog(@"user denied");
        [[self locationManager] stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        NSLog(@"location unknown");
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([CLLocationManager locationServicesEnabled] != NO) {
        
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager setDistanceFilter:500];
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"not available");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
