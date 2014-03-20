//
//  DriverProfileView.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 20/3/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Driver.h"

@interface DriverProfileView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *driverProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;

- (void)updateViewWithDriver:(Driver *)driver;

@end
