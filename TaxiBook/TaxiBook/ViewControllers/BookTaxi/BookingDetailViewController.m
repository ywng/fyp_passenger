//
//  BookingDetailViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "BookingDetailViewController.h"
#import "MDDirectionService.h"
#import "SubView.h"

@interface BookingDetailViewController () <MDDirectionServiceDelegate>

@end

@implementation BookingDetailViewController

- (GMSMapView *)googleMapView
{
    if (!_googleMapView) {
        CGRect mapRect = self.mapView.frame;
        GMSCameraPosition *camera = nil;
        if (self.displayOrder.fromGPS.latitude != 0 && self.displayOrder.fromGPS.longitude != 0) {
            camera = [GMSCameraPosition cameraWithLatitude:self.displayOrder.fromGPS.latitude longitude:self.displayOrder.fromGPS.longitude zoom:15];
        } else {
            camera = [GMSCameraPosition cameraWithLatitude:22.3964 longitude:114.1095 zoom:11];
        }
        
        
        _googleMapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, mapRect.size.width, mapRect.size.height) camera:camera];
        [self.mapView addSubview:_googleMapView];
    }
    
    return _googleMapView;
}

- (DriverInfoView *)loadDriverInfoView
{
    NSArray *ele = [[NSBundle mainBundle] loadNibNamed:@"DriverInfoView" owner:self options:nil];
    if ([ele count] > 0) {
        return [ele objectAtIndex:0];
    } else {
        return nil;
    }
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
    
    [self setupGoogleMapView];
    if (!self.displayOrder) {
        self.displayOrder = [[Order alloc] init];
        self.displayOrder.orderId = 1;
    }
    [self updateDisplayOrder];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupGoogleMapView];
}

#pragma mark - View update

- (void)updateDisplayOrder
{
    TaxiBookConnectionManager *sharedManager = [TaxiBookConnectionManager sharedManager];
    
    __weak BookingDetailViewController *weakSelf = self;
    
    [SubView loadingView:nil];
    
    [sharedManager getUrl:[NSString stringWithFormat:@"/trip/trip_details?oid=%ld", (long)self.displayOrder.orderId] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonData = [responseObject objectForKey:@"order"];
        
        weakSelf.displayOrder = [Order newInstanceFromServerData:jsonData];
        
        jsonData = [responseObject objectForKey:@"driver"];
        if (jsonData) {
            weakSelf.displayOrder.confirmedDriver = [Driver newInstanceFromServerData:jsonData];
        }
        
        [weakSelf updateView];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SubView dismissAlert];
    } loginIfNeed:YES];
}

- (void)updateView
{
    [self.googleMapView clear];
    BOOL fromShown = NO, toShown = NO;
    if (self.displayOrder.fromGPS.latitude != 0 && self.displayOrder.fromGPS.longitude != 0) {
        [self.googleMapView setCamera:[GMSCameraPosition cameraWithLatitude:self.displayOrder.fromGPS.latitude longitude:self.displayOrder.fromGPS.longitude zoom:15]];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.displayOrder.fromGPS.latitude, self.displayOrder.fromGPS.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = @"Pick up location";
        marker.map = self.googleMapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        fromShown = YES;
    }
    if (self.displayOrder.toGPS.latitude != 0 && self.displayOrder.toGPS.longitude != 0) {
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = @"Drop off location";
        marker.map = self.googleMapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        [self.googleMapView setCamera:[GMSCameraPosition cameraWithLatitude:self.displayOrder.fromGPS.latitude longitude:self.displayOrder.fromGPS.longitude zoom:15]];
        toShown = YES;
    }
    if (fromShown && toShown) {
        
        // update the camera view to display two locations
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.displayOrder.fromGPS.latitude, self.displayOrder.fromGPS.longitude) coordinate:CLLocationCoordinate2DMake(self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude)];
        [self.googleMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        
        
        
        // draw polylines
        
        NSString *origin = [NSString stringWithFormat:@"%f,%f", self.displayOrder.fromGPS.latitude, self.displayOrder.fromGPS.longitude];
        NSString *to = [NSString stringWithFormat:@"%f,%f", self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude];
        
        NSString *sensor = @"false";
        NSArray *parameters = [NSArray arrayWithObjects:sensor, @[origin, to], nil];
        NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
        NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters forKeys:keys];
        MDDirectionService *mds=[[MDDirectionService alloc] init];
        [mds setDirectionsQuery:query withDelegate:self];
        
        // need to rewrite mds to compatible with AFNetworking
    }
    
    // check status to add/remove view
    [self setupContentView];
    
    
    [SubView dismissAlert];
}

- (void)setupGoogleMapView
{
    CGRect mapRect = self.mapView.frame;
    [self.googleMapView setFrame:CGRectMake(0, 0, mapRect.size.width, mapRect.size.height)];
}

- (void)finishDownloadDirections:(NSDictionary *)json
{
    [self drawDirection:json];
}

- (void)drawDirection:(NSDictionary *)json
{
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overviewRoute = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overviewRoute];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.googleMapView;
    
    NSDictionary *distances = [[[routes objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"];
    NSDictionary *durations = [[[routes objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"];
    
    NSLog(@"distances %@; durations %@", distances, durations);
    
    [self.distanceLabel setText:[distances objectForKey:@"text"]];
    [self.durationLabel setText:[durations objectForKey:@"text"]];
    
    [self.durationLabel sizeToFit];
    
    
    [self.displayOrder setEstimatedDuration:[[durations objectForKey:@"value"] doubleValue]];
    
    // make up taxi fee
    float distance = [[distances objectForKey:@"value"] floatValue];
    
    if (distance < 2000) {
        self.displayOrder.estimatedPrice = 18.0;
    } else {
        self.displayOrder.estimatedPrice = 18 + (distance - 2000) /100 *1.5; // make up formula
    }
    
    [self.estimatedFeeLabel setText:[NSString stringWithFormat:@"Estimated Fee: HK$ %.1f", self.displayOrder.estimatedPrice]];
    
    self.distanceLabel.hidden = NO;
    self.durationLabel.hidden = NO;
    self.estimatedFeeLabel.hidden = NO;
}

- (void)setupContentView
{
    switch (self.displayOrder.orderStatus) {
        case OrderStatusPending:
        {
            self.contentView.frame = CGRectMake(0, 0, 320, 100);
            self.pageControl.numberOfPages = 1;
        }
            break;
        case OrderStatusBidded:
        {
            self.contentView.frame = CGRectMake(0, 0, 640, 100);
            self.pageControl.numberOfPages = 2;
        }
            break;
        case OrderStatusCustomerConfirmed:
        {
            self.contentView.frame = CGRectMake(0, 0, 640, 100);
            self.pageControl.numberOfPages = 2;
        }
            break;
        case OrderStatusDriverComing:
        {
            self.contentView.frame = CGRectMake(0, 0, 640, 100);
            self.pageControl.numberOfPages = 2;
        }
            break;
        case OrderStatusDriverWaiting:
        {
            self.contentView.frame = CGRectMake(0, 0, 640, 100);
            self.pageControl.numberOfPages = 2;
        }
            break;
        case OrderStatusDriverPickedUp:
        {
            self.contentView.frame = CGRectMake(0, 0, 640, 100);
            self.pageControl.numberOfPages = 2;
        }
            break;
        case OrderStatusOrderFinished:
        {
            self.contentView.frame = CGRectMake(0, 0, 640, 100);
            self.pageControl.numberOfPages = 2;
        }
            break;
        default:
        {
            self.contentView.frame = CGRectMake(0, 0, 320, 100);
            self.pageControl.numberOfPages = 1;
        }
            break;
    }
    
    [self.scrollableContentView setScrollEnabled:YES];
    [self.scrollableContentView setContentSize:self.contentView.frame.size];
//    self.scrollableContentView.contentSize = self.contentView.frame.size;

    if (self.pageControl.numberOfPages > 1) {
        if (!self.driverInfoView) {
            self.driverInfoView = [self loadDriverInfoView];
            [self.driverInfoView setFrame:CGRectMake(320, 0, 320, 100)];
            [self.contentView addSubview:self.driverInfoView];
            [self.driverInfoView updateInfo:self.displayOrder.confirmedDriver orderStatus:self.displayOrder.orderStatus];
        } else {
            [self.driverInfoView updateInfo:self.displayOrder.confirmedDriver orderStatus:self.displayOrder.orderStatus];
        }
    }
    [self.scrollableContentView setNeedsUpdateConstraints];
}

- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    
    CGFloat preferContentOffset = sender.currentPage * [UIScreen mainScreen].bounds.size.width;
    
//    
//    if (self.contentView.frame.size.width <= preferContentOffset) {
//        preferContentOffset = self.contentView.frame.size.width - [UIScreen mainScreen].bounds.size.width;
//    }
    
    [self.scrollableContentView setContentOffset:CGPointMake(preferContentOffset, 0) animated:YES];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollableContentView) {
        CGFloat pageWidth = self.scrollableContentView.frame.size.width;
        float fractionalPage = self.scrollableContentView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        self.pageControl.currentPage = page;
        
    }
}



@end
