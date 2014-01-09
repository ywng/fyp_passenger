//
//  WelcomeViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 8/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

#pragma mark - VC Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcomeBackground"]];
 
    UIColor *barColor=[UIColor colorWithRed:48.0f/255.0f green:81.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = barColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.translucent = NO;
    
    // *barTintColor* sets the background color
    // *tintColor* sets the buttons color
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
}




@end
