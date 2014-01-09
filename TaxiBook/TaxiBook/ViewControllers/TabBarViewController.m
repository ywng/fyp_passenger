//
//  TabBarViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 8/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TabBarViewController.h"
#import <NSUserDefaults+SecureAdditions.h>

@interface TabBarViewController ()

@end

@implementation TabBarViewController

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
    
    UIColor *barColor=[UIColor colorWithRed:48.0f/255.0f green:81.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = barColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes= @{UITextAttributeTextColor : [UIColor whiteColor]};
    self.navigationController.navigationBar.translucent = NO;
    
    // *barTintColor* sets the background color
    // *tintColor* sets the buttons color
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    //check logged in or not
    //if not direct to login and register page
    
    NSString *LoggedIn = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyLoggedIn];
    NSLog(@"Logged in? %@", LoggedIn);
    if ([TaxiBookInternalKeyLoggedIn  isEqual: @"YES"]) {
        
    }else{
     //   [self performSegueWithIdentifier:@"welcomeModal" sender:self];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
