//
//  TaxiBookViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 30/10/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TaxiBookViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@end
