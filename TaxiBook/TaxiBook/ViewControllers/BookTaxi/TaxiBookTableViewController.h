//
//  TaxiBookTableViewController.h
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TaxiBookTableViewController : UITableViewController<GMSMapViewDelegate>

@property (strong, nonatomic) GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *originView;
@property (weak, nonatomic) IBOutlet UIView *destView;


@end
