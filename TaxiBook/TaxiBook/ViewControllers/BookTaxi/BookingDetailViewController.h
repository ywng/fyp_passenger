//
//  BookingDetailViewController.h
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "DriverInfoView.h"
#import "Order.h"

@interface BookingDetailViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) Order *displayOrder;

@property (strong, nonatomic) GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedFeeLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollableContentView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) DriverInfoView *driverInfoView;

@end
