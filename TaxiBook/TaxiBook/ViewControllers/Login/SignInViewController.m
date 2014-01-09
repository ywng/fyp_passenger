//
//  SignInViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 8/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "SignInViewController.h"
#import <NSUserDefaults+SecureAdditions.h>
#import "SubView.h"

@interface SignInViewController ()


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
    if(self.emailLbl.text.length==0){
        [SubView showError:@"Please input user name!" withTitle:@"Login Failed"];
        return;
    }
    if(self.passwordLbl.text.length==0){
        [SubView showError:@"Please input passowrd!" withTitle:@"Login Failed"];
        return;
    }
    
    //check login by POST
    TaxiBookConnectionManager *connection=[TaxiBookConnectionManager sharedManager];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [self.emailLbl text], @"email",
                            [self.passwordLbl text], @"password",
                            @"passenger", @"user_type",nil];

    [connection loginwithParemeters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject){
                                
                                [SubView dismissAlert];
                                [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedIn object:nil];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                [SubView dismissAlert];
                                if ([error.domain isEqualToString:TaxiBookServiceName]) {
                                    NSString *message = [error.userInfo objectForKey:@"message"];
                                    [SubView showError:message withTitle:@"Register Failed"];
                                }else{
                                    [SubView showError:@"Cannot login the system!" withTitle:@"Login Failed"];
                                }
                                
                                return;
                            }];
    
    
    [SubView loadingView:nil];
}





@end
