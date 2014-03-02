//
//  AccountViewController.m
//  TaxiBook
//
//  Created by Tony Tsang on 27/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "AccountViewController.h"
#import <NSUserDefaults+SecureAdditions.h>

@interface AccountViewController ()

@end

@implementation AccountViewController

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
    
    NSString *firstName = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyFirstName];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyLastName];
    self.firstNameTextField.text = firstName;
    self.lastNameTextField.text = lastName;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register keyboard change notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"keyboard will show");
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    
    
    self.navigationController.navigationBar.topItem.rightBarButtonItem = doneButton;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    NSLog(@"keyboard did hide");
}

- (void)doneButtonPressed:(id)sender
{
    NSLog(@"done button pressed");
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    [param setObject:@(0) forKey:@"password_flag"];
    [param setObject:@(0) forKey:@"phone_flag"];
    [param setObject:@(1) forKey:@"name_flag"];
    [param setObject:self.firstNameTextField.text forKey:@"first_name"];
    [param setObject:self.lastNameTextField.text forKey:@"last_name"];

    
    // set request to server update profile
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    [manager postToUrl:@"/passenger/edit_profile/" withParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        NSInteger statusCode = [[responseObject objectForKey:@"status_code"] integerValue];
        if (statusCode == 1) {
           // success
            
            [[NSUserDefaults standardUserDefaults] setSecretObject:self.firstNameTextField.text forKey:TaxiBookInternalKeyFirstName];
            [[NSUserDefaults standardUserDefaults] setSecretObject:self.lastNameTextField.text forKey:TaxiBookInternalKeyLastName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something happened" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alertView show];
        
    } loginIfNeed:YES];
    
    
    self.navigationController.navigationBar.topItem.rightBarButtonItem = nil;
}

@end
