//
//  SignInViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 8/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation SignInViewController

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

- (IBAction)login:(UIButton *)sender {
    //check password and
    if(self.user.text.length==0){
        [self showError:@"Please input user name!"];
        return;
    }
    if(self.password.text.length==0){
        [self showError:@"Please input passowrd!"];
        return;
    }
    
    BOOL loggedIn=false;
    //check login by POST
    TaxiBookConnectionManager *connection=[TaxiBookConnectionManager sharedManager];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            self.user, @"email",
                            self.password, @"password",
                            @"passenger", @"user_type",nil];

    [connection loginwithParemeters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject){
                                

                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                [self showError:[error localizedDescription]];
                                [self.password resignFirstResponder];
                                return;
                            }];
    
    
    
    if(!loggedIn){
        [self showError:@"Incorrect password or user name. Please input again!"];
        [self.password resignFirstResponder];
        return;
    }else{
        
        
        
    }
}

-(void) showError:(NSString*)message{
    UIAlertView *messagePopup = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [messagePopup show];
}

@end
