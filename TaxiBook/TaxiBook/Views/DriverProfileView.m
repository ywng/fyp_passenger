//
//  DriverProfileView.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 20/3/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "DriverProfileView.h"
#import <UIKit+AFNetworking.h>

@interface DriverProfileView ()

@property (strong, nonatomic) Driver *displayingDriver;

@end

@implementation DriverProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initView];
}

- (void)initView
{
    self.driverProfilePic.layer.cornerRadius = self.driverProfilePic.frame.size.height/2;
    self.driverProfilePic.clipsToBounds = YES;
}

- (void)updateViewWithDriver:(Driver *)driver
{
    if (!self.displayingDriver && self.displayingDriver.driverId != driver.driverId) {
        // update view
        
        if (driver.profilePicUrl) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:driver.profilePicUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30];
            __weak UIImageView *weakDriverProfilePic = self.driverProfilePic;
            
            [self.driverProfilePic setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakDriverProfilePic setImage:image];
                    [weakDriverProfilePic setNeedsDisplay];
                });
                
                NSLog(@"image loaded");
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"image fail to load");
            }];
        }
        if (driver.firstName && driver.lastName) {
            [self.driverNameLabel setText:[NSString stringWithFormat:@"%@ %@", driver.firstName, driver.lastName]];
        } else {
            [self.driverNameLabel setText:@""];
        }
        self.displayingDriver = driver;
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
