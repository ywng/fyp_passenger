//
//  ConfirmationViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 26/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "TaxiBookConnectionManager.h"
#import "SubView.h"
#import "RecentLocationHelper.h"

@interface ConfirmationViewController ()

@end

@implementation ConfirmationViewController

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
    if (self.originPlace.placeDescription && self.originPlace.placeAddress) {
        [self.pickupLocationLabel setText:[NSString stringWithFormat:@"%@, %@", self.originPlace.placeDescription, self.originPlace.placeAddress]];
    } else if (self.originPlace.placeAddress) {
        [self.pickupLocationLabel setText:self.originPlace.placeAddress];
    } else {
        [self.pickupLocationLabel setText:self.originPlace.placeDescription];
    }
    
    if (self.destPlace.placeDescription && self.destPlace.placeAddress) {
        [self.dropoffLocationLabel setText:[NSString stringWithFormat:@"%@, %@", self.destPlace.placeDescription, self.destPlace.placeAddress]];
    } else if (self.destPlace.placeAddress) {
        [self.dropoffLocationLabel setText:self.destPlace.placeAddress];
    } else {
        [self.dropoffLocationLabel setText:self.destPlace.placeDescription];
    }
    
    if ([self.pickupDate timeIntervalSinceNow] <= 60 * 5) {
        // pickup time 5 mins or before
        [self.pickupTimeLabel setText:@"As soon as possible"];
    } else {
        NSString *timeString = [NSDateFormatter localizedStringFromDate:self.pickupDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterFullStyle];
        
        [self.pickupTimeLabel setText:timeString];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction
- (IBAction)bookButtonPressed:(id)sender {
    
    /*
     array('field' => 'gps_from_latitude', 'label' => 'from gps latitude', 'rules' => 'trim|required|xss_clean|min_length[1]|numeric'),
     array('field' => 'gps_from_longitude', 'label' => 'from gps longitude', 'rules' => 'trim|required|xss_clean|min_length[1]|numeric'),
     array('field' => 'from_gps_name', 'label' => 'from gps name', 'rules' => 'trim|xss_clean|max_length[100]'),
     array('field' => 'gps_to_latitude', 'label' => 'to gps latitude', 'rules' => 'trim|required|xss_clean|min_length[1]|numeric'),
     array('field' => 'gps_to_longitude', 'label' => 'to gps longitude', 'rules' => 'trim|required|xss_clean|min_length[1]|numeric'),
     array('field' => 'to_gps_name', 'label' => 'to gps name', 'rules' => 'trim|xss_clean|max_length[100]'),
     array('field' => 'pickup_time', 'label' => 'pick up time', 'rules' => 'trim|required|xss_clean|max_length[50]'),
     array('field' => 'special_note', 'label' => 'special note', 'rules' => 'trim|xss_clean'),
     array('field' => 'estimated_price', 'label' => 'estimated price', 'rules' => 'trim|required|xss_clean|numeric|min_length[1]'),
     array('field' => 'estimated_duration', 'label' => 'estimated duration', 'rules' => 'trim|required|xss_clean|numeric|min_length[1]')
     */
    
    // save originPlace and destPlace into recent place plist
    
    [RecentLocationHelper addRecentLocationEntry:self.originPlace];
    [RecentLocationHelper addRecentLocationEntry:self.destPlace];
    
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@(self.originPlace.coordinate.latitude) forKey:@"gps_from_latitude"];
    [params setObject:@(self.originPlace.coordinate.longitude) forKey:@"gps_from_longitude"];
    [params setObject:@(self.destPlace.coordinate.latitude) forKey:@"gps_to_latitude"];
    [params setObject:@(self.destPlace.coordinate.longitude) forKey:@"gps_to_longitude"];
    [params setObject:self.pickupLocationLabel.text forKey:@"from_gps_name"];
    [params setObject:self.dropoffLocationLabel.text forKey:@"to_gps_name"];
    [params setObject:@(floor([self.pickupDate timeIntervalSince1970])) forKey:@"pickup_time"];
    [params setObject:@(0) forKey:@"estimated_price"];
    [params setObject:@(0) forKey:@"estimated_duration"];
//    [params setObject:self.specialNoteTextView.text forKey:@"special_note"];
    
    [SubView loadingView:nil];
    
    [manager postToUrl:@"/trip/create_trip" withParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"create trip!");
        NSLog(@"%@", responseObject);
        [SubView dismissAlert];
        [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserCreatedOrder object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SubView dismissAlert];
        
        NSString* newStr = [[NSString alloc] initWithData:operation.responseData
                                                 encoding:NSUTF8StringEncoding];
        
        NSLog(@"error return %@", newStr);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    } loginIfNeed:YES];
    
}


@end
