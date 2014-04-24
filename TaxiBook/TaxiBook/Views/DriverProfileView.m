//
//  DriverProfileView.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 20/3/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "DriverProfileView.h"
#import <UIKit+AFNetworking.h>
#import "UIImage+Color.h"

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
    [self.driverProfilePic setBackgroundColor:[UIColor clearColor]];
}

- (void)updateViewWithDriver:(Driver *)driver
{
    [self updateViewWithDriver:driver manuallyUpdate:NO];
}

- (void)updateViewWithDriver:(Driver *)driver manuallyUpdate:(BOOL)manuallyUpdate
{
    if (!self.displayingDriver && self.displayingDriver.driverId != driver.driverId) {
        // update view
        
        static UIImage *grayImage = nil;
        
        if (!grayImage) {
            grayImage = [UIImage imageWithColor:[UIColor grayColor] andSize:self.driverProfilePic.frame.size];
        }
        
        if (driver.profilePicUrl) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:driver.profilePicUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30];
            __weak DriverProfileView *weakSelf = self;
            
            [self.driverProfilePic setImageWithURLRequest:request placeholderImage:grayImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.driverProfilePic setImage:image];
                    [weakSelf setNeedsDisplay];
                    
                    if (!manuallyUpdate && self.delegate && [self.delegate respondsToSelector:@selector(driverProfilePicFinishLoading)]) {
                        [self.delegate driverProfilePicFinishLoading];
                    }
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
        // reset
        
        float driverScore = [driver.rating floatValue];
        int floorDriverScore = (int)(floorf(driverScore));
        for (int  i = 1; i<= 6; i++) {
            UIImageView *star = (UIImageView *)[self viewWithTag:i];
            if (i <= floorDriverScore) {
                [star setImage:[UIImage imageNamed:@"star_filled"]];
            } else {
                [star setImage:[UIImage imageNamed:@"star_unfilled"]];
            }
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
