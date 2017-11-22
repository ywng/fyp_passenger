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
        [self initSetup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSetup];
}

- (void)initSetup
{
    [self.mobileNumberTextView setContentInset:UIEdgeInsetsMake(-6, -4, 0, 0)];
}

- (void)updateInfo:(Driver *)driver orderStatus:(OrderStatus)orderStatus
{
    [self.taxiStatusUpdateLabel setText:[Order orderStatusToString:orderStatus]];
    
    if (!driver) {
        [self.driverNameLabel setText:@"Waiting for driver"];
        [self.mobileNumberTextView setText:@"Unknown"];
        [self.licenseNumberLabel setText:@"Unknown"];
        [self.taxiStatusUpdateLabel setText:@"Unknown"];
    } else {
        [self.driverNameLabel setText:[NSString stringWithFormat:@"%@ %@", driver.firstName, driver.lastName]];
        [self.mobileNumberTextView setText:[NSString stringWithFormat:@"+852-%@", driver.phoneNumber]];

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
