//
//  DriverProfileView.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 20/3/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Driver.h"

@protocol DriverProfileViewDelegate <NSObject>

@optional

- (void)driverProfilePicFinishLoading;

@end

@interface DriverProfileView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *driverProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) id<DriverProfileViewDelegate> delegate;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *starImageViewCollection;

- (void)updateViewWithDriver:(Driver *)driver;
- (void)updateViewWithDriver:(Driver *)driver manuallyUpdate:(BOOL)manuallyUpdate;

@end
