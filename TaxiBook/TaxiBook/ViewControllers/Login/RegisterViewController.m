//
//  TaxiBookRegisterViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 27/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "RegisterViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <NSUserDefaults+SecureAdditions.h>
#import "SubView.h"

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
    // [self setupLoadingView];
    [manager registerPassenger:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // get the pid
        NSLog(@"responseObject %@", responseObject);
        
        NSInteger pid = [[responseObject objectForKey:@"pid"] integerValue];
        
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.emailTextField.text forKey:TaxiBookInternalKeyEmail];
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.firstNameTextField.text forKey:TaxiBookInternalKeyFirstName];
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.lastNameTextField.text forKey:TaxiBookInternalKeyLastName];
        [[NSUserDefaults standardUserDefaults] setSecretInteger:pid forKey:TaxiBookInternalKeyUserId];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [manager loginwithParemeters:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text, @"user_type": @"passenger"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedIn object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [SubView dismissAlert];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error login %@", error);
            [SubView dismissAlert];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error on register %@", error);
        [SubView dismissAlert];
    }];
    
    [SubView loadingView:nil];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.

}


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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
	// Do any additional setup after loading the view.
//    [self.emailTextField setText:@"default_email2@email.com"];
//    [self.phoneTextField setText:@"98765431"];
//    [self.firstNameTextField setText:@"default_first"];
//    [self.lastNameTextField setText:@"default_last"];
//    [self.passwordTextField setText:@"passwordSecret"];
    
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
