//
//  ConfirmationViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 26/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMPlace.h"

@interface ConfirmationViewController : UIViewController

@property (strong, nonatomic) GMPlace *originPlace;
@property (strong, nonatomic) GMPlace *destPlace;
@property (strong, nonatomic) NSDate *pickupDate;

@property (weak, nonatomic) IBOutlet UILabel *pickupLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupTimeLabel;


@end
