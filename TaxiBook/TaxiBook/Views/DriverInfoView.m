//
//  DriverInfoView.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "DriverInfoView.h"

@implementation DriverInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateInfo:(Driver *)driver orderStatus:(OrderStatus)orderStatus
{
    switch (orderStatus) {
        case OrderStatusPending: {
            [self.taxiStatusUpdateLabel setText:@"Waiting for confirmation"];
        }
            break;
        case OrderStatusBidded: {
            [self.taxiStatusUpdateLabel setText:@"Waiting"];
        }
            break;
        case OrderStatusCustomerConfirmed: {
            [self.taxiStatusUpdateLabel setText:@"Taxi\nwill come"];
        }
            break;
        case OrderStatusDriverComing: {
            [self.taxiStatusUpdateLabel setText:@"Taxi\nis coming"];
        }
            break;
        case OrderStatusDriverWaiting: {
            [self.taxiStatusUpdateLabel setText:@"Taxi\nhas arrived"];
        }
            break;
        case OrderStatusDriverPickedUp: {
            [self.taxiStatusUpdateLabel setText:@"Taxi is going to destination"];
        }
            break;
        case OrderStatusOrderFinished: {
            [self.taxiStatusUpdateLabel setText:@"Trip finished"];
        }
            break;
        
        default:
        {
            [self.taxiStatusUpdateLabel setText:@"Unknown status"];
        }
            break;
    }
    
    if (!driver) {
        [self.driverNameLabel setText:@"Waiting for driver"];
        [self.mobileNumberLabel setText:@"Unknown"];
        [self.licenseNumberLabel setText:@"Unknown"];
        [self.taxiStatusUpdateLabel setText:@"Unknown"];
    } else {
        [self.driverNameLabel setText:[NSString stringWithFormat:@"%@ %@", driver.firstName, driver.lastName]];
        [self.mobileNumberLabel setText:[NSString stringWithFormat:@"(852) %@", driver.phoneNumber]];
        [self.licenseNumberLabel setText:driver.licenseNumber];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
