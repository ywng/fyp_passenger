//
//  GoogleMapPickerViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 26/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "GoogleMapPickerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SubView.h"


@interface GoogleMapPickerViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *bestLocation;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) GMPlace *selectedPlace;

@property (strong, nonatomic) UIBarButtonItem *tempBarButtonHolder;

@property (strong, nonatomic) GMSMarker *marker;

@end

@implementation GoogleMapPickerViewController

- (GMSMapView *)googleMapView
{
    if (!_googleMapView) {
        CGRect mapRect = self.mapView.frame;
        
        _googleMapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, mapRect.size.width, mapRect.size.height) camera:nil];
        [_googleMapView setMyLocationEnabled:YES];
        _googleMapView.delegate = self;
        [self.mapView addSubview:_googleMapView];
    }
    
    return _googleMapView;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)setBestLocation:(CLLocation *)bestLocation
{
    _bestLocation = bestLocation;
    // update the map
    
}


#pragma mark - VC Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ([CLLocationManager locationServicesEnabled] != NO) {
        
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager setDistanceFilter:500];
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"not available");
        
        // load up images to tell user
    }
    
    if (self.currentPlace) {
        // set marker and move the camera
        
        GMSMarker *marker = [GMSMarker markerWithPosition:self.currentPlace.coordinate];
        marker.map = self.googleMapView;
        self.marker = marker;
        
        self.locationLabel.text = self.currentPlace.placeAddress;
        
        [self.googleMapView animateToLocation:self.currentPlace.coordinate];
        [self.googleMapView animateToZoom:15];
        
    } else {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:22.3964 longitude:114.1095 zoom:11];
        [self.googleMapView setCamera:camera];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)doneButtonPressed:(id)sender {
    
    if (self.selectedPlace) {
        
//        // need to do a complete search
//        [SubView loadingView:nil];
//        
//        [GoogleMapPlaceSearchService searchWithKeyword:self.selectedPlace.placeAddress gpsEnable:YES location:[[CLLocation alloc] initWithLatitude:self.selectedPlace.coordinate.latitude longitude:self.selectedPlace.coordinate.longitude] withDelegate:self];
//        
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(GoogleMapPickerDelegate)]) {
            
            [self.delegate userDidFinishPickingPlace:self.selectedPlace name:self.selectedPlace.placeAddress];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - CLLocationManagerDelegate method

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    BOOL needToUpdateCameraView = NO;
    
    if (!self.bestLocation && !self.currentPlace) {
        needToUpdateCameraView = YES;
    }
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        [self setBestLocation:location];
    }
    
    // Schedule location manager to run again in 10 seconds
    [self.locationManager stopUpdatingLocation];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(turnOnLocationManager)  userInfo:nil repeats:NO];
    
    if (needToUpdateCameraView) {
        [self.googleMapView animateToLocation:location.coordinate];
        [self.googleMapView animateToZoom:15];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        NSLog(@"user denied");
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        NSLog(@"location unknown");
    } else {
        NSLog(@"error: %@", error);
    }
}

- (void)turnOnLocationManager {
    [self.locationManager startUpdatingLocation];
}


#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"did long press %f, %f", coordinate.latitude, coordinate.longitude);
    
    if (!self.marker) {
        GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
        marker.map = self.googleMapView;
        self.marker = marker;
    } else {
        self.marker.position = coordinate;
    }
    
    // try to download
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    if (!self.tempBarButtonHolder) {
        self.tempBarButtonHolder = self.navigationController.navigationBar.topItem.rightBarButtonItem;
    }
    
    self.navigationController.navigationBar.topItem.rightBarButtonItem = barButtonItem;
    
    [GoogleMapPlaceSearchService reverseGeocodingWithLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] withDelegate:self];
    
}

- (void)finishDownloadPlaceSearch:(NSArray *)places searchType:(PlaceSearchType)searchType
{
    if (searchType == PlaceSearchTypeReverseGeocoding) {
        if ([places count] >= 1) {
            // get the first result
            GMPlace *place = [places objectAtIndex:0];
            self.selectedPlace = place;
            [self.locationLabel setText:place.placeAddress];
        }
        
        self.navigationController.navigationBar.topItem.rightBarButtonItem = self.tempBarButtonHolder;
        self.tempBarButtonHolder = nil;
    }
}


@end
