//
//  DriverInfoView.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface DriverInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxiStatusUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseNumberLabel;

- (void)updateInfo:(Driver *)driver orderStatus:(OrderStatus)orderStatus;

@end
