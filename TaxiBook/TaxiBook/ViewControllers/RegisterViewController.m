//
//  TaxiBookRegisterViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 27/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController


- (IBAction)registerButtonPressed:(id)sender {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (self.emailTextField.text.length > 0) {
        [dict setObject:self.emailTextField.text forKey:@"email"];
    }
    if (self.phoneTextField.text.length > 0) {
        [dict setObject:self.phoneTextField.text forKey:@"phone"];
    }
    if (self.firstNameTextField.text.length > 0) {
        [dict setObject:self.firstNameTextField.text forKey:@"first_name"];
    }
    if (self.lastNameTextField.text.length > 0) {
        [dict setObject:self.lastNameTextField.text forKey:@"last_name"];
    }
    if (self.passwordTextField.text.length > 0) {
        [dict setObject:self.passwordTextField.text forKey:@"password"];
    }
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    [manager postToUrl:@"/passenger/register/" withParameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // get the pid
        NSLog(@"responseObject %@", responseObject);
        NSNumber *pid = [responseObject objectForKey:@"pid"];
        
        [self.resultTextView setText:[pid description]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error on register %@", error);
        [self.resultTextView setText:error.description];
    } loginIfNeed:NO];
    
}




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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
	// Do any additional setup after loading the view.
//    [self.emailTextField setText:@"default_email2@email.com"];
//    [self.phoneTextField setText:@"98765431"];
//    [self.firstNameTextField setText:@"default_first"];
//    [self.lastNameTextField setText:@"default_last"];
//    [self.passwordTextField setText:@"passwordSecret"];
    [self.resultTextView setText:@"result shows here"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    [super viewWillDisappear:animated];
}

@end
