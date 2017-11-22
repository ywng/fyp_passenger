//
//  AccountViewController.m
//  TaxiBook
//
//  Created by Tony Tsang on 27/2/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "AccountViewController.h"
#import <NSUserDefaults+SecureAdditions.h>
#import "SubView.h"
#import "FDTakeController.h"
#import <UIKit+AFNetworking.h>

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CALayer *imageLayer = self.profileImage.layer;
    [imageLayer setCornerRadius:33];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
    
    NSString *firstName = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyFirstName];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyLastName];
    NSString *email = [[NSUserDefaults standardUserDefaults]secretStringForKey:TaxiBookInternalKeyEmail];
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults]secretStringForKey:TaxiBookInternalKeyPhone];
    self.firstNameTextField.text = firstName;
    self.lastNameTextField.text = lastName;
    self.emailLabel.text = email;
    self.phoneNumberTextField.text = phoneNumber;
    
    BOOL hasProfilePic = [[NSUserDefaults standardUserDefaults] secretBoolForKey:TaxiBookInternalKeyHasProfilePic];
    
    if (hasProfilePic) {
        
        NSURL *imageUrl = [[NSUserDefaults standardUserDefaults] secretURLForKey:TaxiBookInternalKeyProfilePic];
        
        [self.profileImage setImageWithURL:imageUrl];
        
    }
    else {
        [self.profileImage setImage:[UIImage imageNamed:@"noProfilePic"]];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editProfilePic:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [self.profileImage addGestureRecognizer:singleTap];
    [self.profileImage setUserInteractionEnabled:YES];
    
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.viewControllerForPresentingImagePickerController = self;
    self.takeController.delegate = self;
    self.takeController.allowsEditingPhoto = YES;
    self.takeController.tabBar = self.tabBarController.tabBar;
    
}

- (void)editProfilePic:(UIGestureRecognizer *)gestureRecognizer {
    [self.takeController takePhotoOrChooseFromLibrary];
    self.takeController.allowsEditingPhoto = false;
    
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    [self.profileImage setImage:photo];
    [SubView loadingView:nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    [manager editProfilePic:dict image:photo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger statusCode = [[responseObject objectForKey:@"status_code"] integerValue];
        if (statusCode == 1) {
            // success
            
            [SubView dismissAlert];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SubView dismissAlert];
        NSData *dataFromServer = operation.responseData;
        
        NSString *stringFromServer = [[NSString alloc] initWithData:dataFromServer encoding:NSUTF8StringEncoding];
        NSLog(@"string from server : %@", stringFromServer);
        
        NSLog(@"Error: %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something happened" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alertView show];
        
    } loginIfNeed:YES];
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
    [self.phoneNumberTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    //validate password
    if (self.passwordTextField.hasText) {
        if (self.passwordTextField.text.length<6) {
            NSLog(@"Password too short");
            [SubView showError:@"Please input at least 6 characters for password" withTitle:@"Update Failed"];
            return;
        }
        else {
            [param setObject:@(1) forKey:@"password_flag"];
            [param setObject:self.passwordTextField.text forKey:@"password"];
        }
    }
    else {
        [param setObject:@(0) forKey:@"password_flag"];
    }
    
    //validate phone number
    if (self.phoneNumberTextField.text.length==8) {
        NSScanner *scanner = [NSScanner scannerWithString:self.phoneNumberTextField.text];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        if (isNumeric) {
            [param setObject:@(1) forKey:@"phone_flag"];
            [param setObject:self.phoneNumberTextField.text forKey:@"phone"];
        }
        else {
            [param setObject:@(0) forKey:@"phone_flag"];
            NSLog(@"Non numeric phone number");
            [SubView showError:@"Please input a valid phone number" withTitle:@"Update Failed"];
            return;
        }
    }
    else {
        [param setObject:@(0) forKey:@"phone_flag"];
        NSLog(@"Non 8-digit phone number");
        [SubView showError:@"Please input a valid phone number" withTitle:@"Update Failed"];
        return;
    }
    
    if (self.lastNameTextField.text.length>0) {
        if (self.firstNameTextField.text.length>0) {
            [param setObject:@(1) forKey:@"name_flag"];
            [param setObject:self.firstNameTextField.text forKey:@"first_name"];
            [param setObject:self.lastNameTextField.text forKey:@"last_name"];
        }
        else {
            [param setObject:@(0) forKey:@"name_flag"];
            NSLog(@"No first name");
            [SubView showError:@"Please input your first name" withTitle:@"Update Failed"];
            return;
        }
    }
    else {
        [param setObject:@(0) forKey:@"name_flag"];
        NSLog(@"No last name");
        [SubView showError:@"Please input your last name" withTitle:@"Update Failed"];
        return;
    }
    
    // set request to server update profile
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    [manager postToUrl:@"/passenger/edit_profile/" withParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        NSInteger statusCode = [[responseObject objectForKey:@"status_code"] integerValue];
        if (statusCode == 1) {
           // success
            
            [[NSUserDefaults standardUserDefaults] setSecretObject:self.firstNameTextField.text forKey:TaxiBookInternalKeyFirstName];
            [[NSUserDefaults standardUserDefaults] setSecretObject:self.lastNameTextField.text forKey:TaxiBookInternalKeyLastName];
            [[NSUserDefaults standardUserDefaults] setSecretObject:self.phoneNumberTextField.text forKey:TaxiBookInternalKeyPhone];
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
