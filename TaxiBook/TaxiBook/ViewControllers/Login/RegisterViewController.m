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
    }else{
        [SubView showError:@"Please input email address!" withTitle:@"Register Failed"];
        return;
    }
    if (self.phoneTextField.text.length > 0) {
        [dict setObject:self.phoneTextField.text forKey:@"phone"];
    }else{
        [SubView showError:@"Please input 8-digit phone number!" withTitle:@"Register Failed"];
        return;
    }
    if (self.firstNameTextField.text.length > 0) {
        [dict setObject:self.firstNameTextField.text forKey:@"first_name"];
    }else{
        [SubView showError:@"Please input your first name!" withTitle:@"Register Failed"];
        return;
    }
    if (self.lastNameTextField.text.length > 0) {
        [dict setObject:self.lastNameTextField.text forKey:@"last_name"];
    }else{
        [SubView showError:@"Please input your last name!" withTitle:@"Register Failed"];
        return;
    }
    if (self.passwordTextField.text.length > 0) {
        [dict setObject:self.passwordTextField.text forKey:@"password"];
    }else{
        [SubView showError:@"Please input at least 6 character password!" withTitle:@"Register Failed"];
        return;
    }
    if(![self.retypePasswordTextField.text isEqualToString:self.passwordTextField.text]){
        [SubView showError:@"Please ensure the password is typed correctly!" withTitle:@"Register Failed"];
        return;
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
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.phoneTextField.text forKey:TaxiBookInternalKeyPhone];
        [[NSUserDefaults standardUserDefaults] setSecretInteger:pid forKey:TaxiBookInternalKeyUserId];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [manager loginwithParemeters:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text, @"user_type": @"passenger"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //the notification is already included in login request
            //[[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedIn object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [SubView dismissAlert];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SubView dismissAlert];
            NSLog(@"error login %@", error);
            
            if ([error.domain isEqualToString:TaxiBookServiceName]) {
                NSString *message = [error.userInfo objectForKey:@"message"];
                [SubView showError:message withTitle:@"Register Failed"];
            }else{
                [SubView showError:@"Cannot login after registration!" withTitle:@"Login Failed"];
            }
            
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SubView dismissAlert];
        NSLog(@"error on register %@", error);
        
        if ([error.domain isEqualToString:TaxiBookServiceName]) {
            NSString *message = [error.userInfo objectForKey:@"message"];
            [SubView showError:message withTitle:@"Register Failed"];
        }else{
            [SubView showError:@"Cannot register an account!" withTitle:@"Registration Failed"];
        }
        
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
   // [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
	// Do any additional setup after loading the view.
//    [self.emailTextField setText:@"default_email2@email.com"];
//    [self.phoneTextField setText:@"98765431"];
//    [self.firstNameTextField setText:@"default_first"];
//    [self.lastNameTextField setText:@"default_last"];
//    [self.passwordTextField setText:@"passwordSecret"];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.phoneTextField.inputAccessoryView = numberToolbar;
    
}


-(void)doneWithNumberPad{
    NSInteger nextTag = self.phoneTextField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [self.phoneTextField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [self.phoneTextField resignFirstResponder];
    }
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
