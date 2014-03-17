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

@interface BookingDetailViewController () <MDDirectionServiceDelegate> {
    BOOL notFirstUpdate;
}

@property (strong, nonatomic) OrderModel *orderModel;
@property (strong, nonatomic) NSTimer *updateTimer;

@property (strong, nonatomic) GMSMarker *fromMarker;
@property (strong, nonatomic) GMSMarker *toMarker;

@property (strong, nonatomic) GMSCircle *driverPointer;

@property (nonatomic) OrderStatus previousOrderStatus;
@property (strong, nonatomic) UIView *mapOverlayView;

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

- (UIView *)mapOverlayView
{
    if (!_mapOverlayView) {
        _mapOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    }
    return _mapOverlayView;
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

- (OrderModel *)orderModel
{
    if (!_orderModel) {
        _orderModel = [OrderModel newInstanceWithIdentifier:self.description delegate:self];
    }
    return _orderModel;
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
    self.previousOrderStatus = OrderStatusUnknown;
    [self setupGoogleMapView];
    [SubView loadingView:nil];
    [self updateDisplayOrder];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateDisplayOrder) userInfo:nil repeats:YES];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self.description);
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

#pragma mark - OrderModelDelegate

- (void)finishDownloadOrders:(OrderModel *)orderModel
{
    [self.displayOrder updateDetail:[orderModel objectAtIndex:0]];
    if (!notFirstUpdate) {
        [self updateView];
        notFirstUpdate = YES;
    } else {
        [self minorUpdateView];
    }
    [SubView dismissAlert];
}

- (void)failDownloadOrders:(OrderModel *)orderModel
{
    [self minorUpdateView];
    [SubView dismissAlert];
}

#pragma mark - View update

- (void)updateDisplayOrder
{
    [self.orderModel downloadOrderDetail:self.displayOrder.orderId];
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
        self.fromMarker = marker;
        fromShown = YES;
    }
    if (self.displayOrder.toGPS.latitude != 0 && self.displayOrder.toGPS.longitude != 0) {
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.displayOrder.toGPS.latitude, self.displayOrder.toGPS.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = @"Drop off location";
        marker.map = self.googleMapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        [self.googleMapView setCamera:[GMSCameraPosition cameraWithLatitude:self.displayOrder.toGPS.latitude longitude:self.displayOrder.toGPS.longitude zoom:15]];
        self.toMarker = marker;
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

- (void)minorUpdateView
{
    // redraw driver location
    if (self.displayOrder.confirmedDriver.currentLocation) {
        if (!self.driverPointer) {
            self.driverPointer = [GMSCircle circleWithPosition:CLLocationCoordinate2DMake(self.displayOrder.confirmedDriver.currentLocation.latitude, self.displayOrder.confirmedDriver.currentLocation.longitude)
                                                                           radius:10];
        } else {
            [self.driverPointer setPosition:CLLocationCoordinate2DMake(self.displayOrder.confirmedDriver.currentLocation.latitude, self.displayOrder.confirmedDriver.currentLocation.longitude)];
        }
        self.driverPointer.map = self.googleMapView;
    }
    
    // based on the status to update
    [self setupContentView];
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
    if ([[json objectForKey:@"routes"] count] > 0) {
        NSDictionary *routes = [json objectForKey:@"routes"][0];
        
        NSDictionary *route = [routes objectForKey:@"overview_polyline"];
        NSString *overviewRoute = [route objectForKey:@"points"];
        GMSPath *path = [GMSPath pathFromEncodedPath:overviewRoute];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeWidth = 5;
        polyline.map = self.googleMapView;

        UIColor *transBlue = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.7];
        UIColor *transPurple = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:0.7];
        
        GMSStrokeStyle *bluePurple = [GMSStrokeStyle gradientFromColor:transBlue toColor:transPurple];
        GMSStyleSpan *redYellowSpan = [GMSStyleSpan spanWithStyle:bluePurple];
        
        polyline.spans = @[redYellowSpan];
        
        NSDictionary *distances = [[[routes objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"];
        NSDictionary *durations = [[[routes objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"];
        
        NSLog(@"distances %@; durations %@", distances, durations);

//        [self.distanceLabel setText:[distances objectForKey:@"text"]];
//        [self.durationLabel setText:[durations objectForKey:@"text"]];
//        
//        [self.durationLabel sizeToFit];
        
        [self.displayOrder setEstimatedDuration:[[durations objectForKey:@"value"] doubleValue]];
        
        // make up taxi fee
        float distance = [[distances objectForKey:@"value"] floatValue];
        
        if (distance < 2000) {
            self.displayOrder.estimatedPrice = 18.0;
        } else {
            self.displayOrder.estimatedPrice = 18 + (distance - 2000) /100 *1.5; // make up formula
        }
        
//        [self.estimatedFeeLabel setText:[NSString stringWithFormat:@"Estimated Fee: HK$ %.1f", self.displayOrder.estimatedPrice]];
//        
//        self.distanceLabel.hidden = NO;
//        self.durationLabel.hidden = NO;
//        self.estimatedFeeLabel.hidden = NO;
    } else {
        // zero result
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No possible routes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)setupContentView
{
    
    if (!self.driverInfoView) {
        self.driverInfoView = [self loadDriverInfoView];
        [self.driverInfoView setFrame:CGRectMake(320, 0, 320, 100)];
        [self.bottomContainerView addSubview:self.driverInfoView];
        [self.driverInfoView updateInfo:self.displayOrder.confirmedDriver orderStatus:self.displayOrder.orderStatus];
    } else {
        [self.driverInfoView updateInfo:self.displayOrder.confirmedDriver orderStatus:self.displayOrder.orderStatus];
    }
    
    
    switch (self.displayOrder.orderStatus) {
        case OrderStatusPending:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:60.0/255 green:188.0/255 blue:1 alpha:1] withString:@"Waiting for driver's confirmation" spinnerNeed:YES];
                
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        case OrderStatusBidded:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:@"You have one confirmed driver" spinnerNeed:NO];
                
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        case OrderStatusCustomerConfirmed:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:60.0/255 green:188.0/255 blue:1 alpha:1] withString:@"Your driver will come soon..." spinnerNeed:YES];
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        case OrderStatusDriverComing:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:60.0/255 green:188.0/255 blue:1 alpha:1] withString:@"Your driver is coming" spinnerNeed:NO];
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        case OrderStatusDriverWaiting:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:@"Your driver has arrived" spinnerNeed:NO];
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        case OrderStatusDriverPickedUp:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:@"Your trip is started" spinnerNeed:NO];
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        case OrderStatusOrderFinished:
        {
            if (self.previousOrderStatus != self.displayOrder.orderStatus) {
                
                /* top bar config */
                [self.mapOverlayView removeFromSuperview];
                self.mapOverlayView = nil;
                [self setupTopBarWithColor:[UIColor colorWithRed:0 green:237.0/255 blue:88.0/255 alpha:1] withString:@"Thank you for riding with TaxiBook!" spinnerNeed:NO];
                [self.view addSubview:self.mapOverlayView];
                
                /* bottom view config */
            }
        }
            break;
        default:
        {
        }
            break;
    }
    self.previousOrderStatus = self.displayOrder.orderStatus;
}

- (void)setupTopBarWithColor:(UIColor *)color withString:(NSString *)string spinnerNeed:(BOOL)spinnerNeed
{
    [self.mapOverlayView setBackgroundColor:color];
    UILabel *label = nil;
    if (spinnerNeed) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setCenter:CGPointMake(30, 22)];
        [activityIndicator startAnimating];
        [self.mapOverlayView addSubview:activityIndicator];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 30)];
        [label setCenter:CGPointMake(180, 22)];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        [label setCenter:CGPointMake(160, 22)];
    }
    
    [label setText:string];
    [label setFont:[UIFont fontWithName:UIFontTextStyleHeadline size:15]];
    [label setTextColor:[UIColor whiteColor]];
    
    [self.mapOverlayView addSubview:label];
}


@end
