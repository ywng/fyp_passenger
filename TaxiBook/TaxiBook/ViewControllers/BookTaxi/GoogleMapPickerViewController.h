//
//  GoogleMapPickerViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 26/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapPlaceSearchService.h"

@protocol GoogleMapPickerDelegate <NSObject>

- (void)userDidFinishPickingPlace:(GMPlace *)place name:(NSString *)locationName;

@end

@interface GoogleMapPickerViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, GMPlaceSearchServiceDelegate>

@property (weak, nonatomic) id<GoogleMapPickerDelegate> delegate;
@property (strong, nonatomic) GMSMapView *googleMapView;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) GMPlace *currentPlace;


@end
