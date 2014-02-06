//
//  TaxiBookBookViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TaxiBookBookingViewController.h"
#import "PlaceSearchResultTableViewController.h"
#import "GoogleMapPickerViewController.h"
#import "ConfirmationViewController.h"

@interface TaxiBookBookingViewController () <GoogleMapPickerDelegate, PlaceSearchResultDelegate>

@property (nonatomic, getter = isOriginExpanded) BOOL originExpand;
@property (nonatomic, getter = isDestExpanded) BOOL destExpand;
@property (nonatomic, getter = isTimeExpanded) BOOL timeExpand;

@property (nonatomic) NSInteger selectedPlaceIndex;

@property (strong, nonatomic) GMPlace *originPlace;
@property (strong, nonatomic) GMPlace *destPlace;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) PlaceSearchResultTableViewController *originTableViewController;
@property (weak, nonatomic) PlaceSearchResultTableViewController *destTableViewController;

@end

@implementation TaxiBookBookingViewController

static NSString *originVCSegueIdentifier = @"origin";
static NSString *destVCSegueIdentifier = @"dest";
static NSString *mapPickerSegueIdentifier = @"mapPicker";
static NSString *confirmSegueIdentifier = @"confirm";


- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    return _dateFormatter;
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
	// Do any additional setup after loading the view.
    self.originExpand = NO;
    self.destExpand = NO;
    self.timeExpand = NO;
    [self.timeLabel setText:[self.dateFormatter stringFromDate:self.timePicker.date]];
    
    // add observer to uitextfield textDidChange event
    [self.originTextField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.destinationTextField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.timePicker setMinimumDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0]];
    
    [self.rightBarButtonItem setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([originVCSegueIdentifier isEqualToString:segue.identifier]) {
        self.originTableViewController = (PlaceSearchResultTableViewController *)segue.destinationViewController;
        self.originTableViewController.delegate = self;
    } else if ([destVCSegueIdentifier isEqualToString:segue.identifier]) {
        self.destTableViewController = (PlaceSearchResultTableViewController *)segue.destinationViewController;
        self.destTableViewController.delegate = self;
    } else if ([mapPickerSegueIdentifier isEqualToString:segue.identifier]) {
        GoogleMapPickerViewController *pickerVC = (GoogleMapPickerViewController *)segue.destinationViewController;
        
        GMPlace *place = nil;
        
        if (self.selectedPlaceIndex == 0) {
            place = self.originPlace;
        } else {
            place = self.destPlace;
        }
        
        pickerVC.delegate = self;
        [pickerVC setCurrentPlace:place];
    } else if ([confirmSegueIdentifier isEqualToString:segue.identifier]) {
        ConfirmationViewController *confirmVC = (ConfirmationViewController *)segue.destinationViewController;
        [confirmVC setOriginPlace:self.originPlace];
        [confirmVC setDestPlace:self.destPlace];
        [confirmVC setPickupDate:self.timePicker.date];
        NSLog(@"%@ self.timePicker.date ", self.timePicker.date);
    }
}


#pragma mark - Tap Gesture Recognizer
- (IBAction)userDidTapOnOriginContainerView:(id)sender {
    
    if (![self isOriginExpanded]) {
        // prepare to expand the view
        [self expandOriginView];
        // hide other view
        [self collapseDestView];
        [self collapseTimeView];
    } else {
        // prepare to collapse the view
        [self collapseOriginView];
    }

}

- (IBAction)userDidTapOnDestContainerView:(id)sender {
    
    if (![self isDestExpanded]) {
        // prepare to expand the view
        [self expandDestView];
        
        // hide other view
        [self collapseOriginView];
        [self collapseTimeView];
        
    } else {
        // prepare to collapse the view
        [self collapseDestView];
    }

}

- (IBAction)userDidTapOnTimeContainerView:(id)sender {
    
    if (![self isTimeExpanded]) {
        // prepare to expand the view
        [self expandTimeView];
        
        // hide other view
        [self collapseOriginView];
        [self collapseDestView];
        
    } else {
        // prepare to collapse the view
        [self collapseTimeView];
    }
    
}

- (IBAction)confirmButtonPressed:(UIBarButtonItem *)sender {
    if ([@"Done" isEqualToString:sender.title]) {
        [self resignAllResponder];
        [self resetAllView];
    } else {
        // check fields to be filled already
        if (self.originPlace && self.destPlace) {
            [self performSegueWithIdentifier:confirmSegueIdentifier sender:self];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please make sure you have put your starting point and ending point." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
}

#pragma mark - Other IBActions
- (IBAction)originMapButtonPressed:(id)sender
{
    self.selectedPlaceIndex = 0;
    [self resetAllView];
    [self performSegueWithIdentifier:mapPickerSegueIdentifier sender:sender];
}

- (IBAction)destMapButtonPressed:(id)sender
{
    self.selectedPlaceIndex = 1;
    [self resetAllView];
    [self performSegueWithIdentifier:mapPickerSegueIdentifier sender:sender];
}


#pragma mark - View Show/Hide

- (void)expandOriginView
{
    if (![self isOriginExpanded]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.originContainerViewHeightConstraint.constant = 44 + 400;
        } completion:^(BOOL finished) {
            self.originExpand = YES;
        }];
    }
}

- (void)collapseOriginView
{
    if ([self isOriginExpanded]) {
        if (![self.originTextField isFirstResponder]) {
            [UIView animateWithDuration:0.3 animations:^{
                self.originContainerViewHeightConstraint.constant = 44;
            } completion:^(BOOL finished) {
                self.originExpand = NO;
            }];
        }
    }
}

- (void)expandDestView
{
    if (![self isDestExpanded]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.destContainerViewHeightConstraint.constant = 44 + 400;
        } completion:^(BOOL finished) {
            self.destExpand = YES;
        }];
    }
}

- (void)collapseDestView
{
    if ([self isDestExpanded]) {
        if (![self.destinationTextField isFirstResponder]) {
            [UIView animateWithDuration:0.3 animations:^{
                self.destContainerViewHeightConstraint.constant = 44;
            } completion:^(BOOL finished) {
                self.destExpand = NO;
            }];
        }
    }
}


- (void)expandTimeView
{
    if (![self isTimeExpanded]) {
        [self resignAllResponder];
        [UIView animateWithDuration:0.3 animations:^{
            self.timeContainerViewHeightConstraint.constant = 44 + 162;
        } completion:^(BOOL finished) {
            self.timeExpand = YES;
        }];
    }
}

- (void)collapseTimeView
{
    if ([self isTimeExpanded]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.timeContainerViewHeightConstraint.constant = 44;
        } completion:^(BOOL finished) {
            self.timeExpand = NO;
        }];
    }
}

- (void)resetAllView
{
    [self collapseOriginView];
    [self collapseDestView];
    [self collapseTimeView];
    
    if ([self.rightBarButtonItem.title isEqualToString:@"Done"]) {
        [self confirmButtonPressed:self.rightBarButtonItem];
    }
}

#pragma mark - UITextFieldDelegate

/**
This method tries to remove the keyboard from current view stack
*/
- (void)resignAllResponder
{
    [self.originTextField resignFirstResponder];
    [self.destinationTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.originTextField == textField) {
        self.selectedPlaceIndex = 0;
        if (![self isOriginExpanded]) {
            [self userDidTapOnOriginContainerView:textField];
        }
    } else if (self.destinationTextField == textField) {
        self.selectedPlaceIndex = 1;
        if (![self isDestExpanded]) {
            [self userDidTapOnDestContainerView:textField];
        }
    }
    self.rightBarButtonItem.title = @"Done";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.rightBarButtonItem.title = @"Confirm";
}

- (void)textDidChange:(UITextField *)textField
{
    if (self.originTextField == textField) {
        [self.originTableViewController setSearchString:textField.text];
    } else if (self.destinationTextField == textField) {
        [self.destTableViewController setSearchString:textField.text];
    } else {
        NSLog(@"what happen %@", textField);
    }
}

#pragma mark - UIDatePicker

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender {
    // update time label
    [self.timeLabel setText:[self.dateFormatter stringFromDate:sender.date]];
    
}



#pragma mark - GoogleMapPickerDelegate

- (void)userDidFinishPickingPlace:(GMPlace *)place name:(NSString *)locationName
{
    if (self.selectedPlaceIndex == 0) {
        
        self.originPlace = place;
        self.originTextField.text = locationName;
        
    } else if (self.selectedPlaceIndex == 1) {
        
        self.destPlace = place;
        self.destinationTextField.text = locationName;
        
    }
    if (!self.originPlace || !self.destPlace) {
        self.rightBarButtonItem.enabled = NO;
    } else {
        self.rightBarButtonItem.enabled = YES;
    }
}


#pragma mark - PlaceSearchResultDelegate

- (void)userDidSelectThePlaceName:(GMPlace *)place
{
    // get the exact result from the search
    if (self.selectedPlaceIndex == 0) {
        self.originTextField.text = place.placeSecondaryDescription;
        
    } else if (self.selectedPlaceIndex == 1) {
        self.destinationTextField.text = place.placeSecondaryDescription;
    }
    [SubView loadingView:@"loading"];
}

- (void)downloadTheExactPlace:(GMPlace *)place
{
    if (self.selectedPlaceIndex == 0) {
        self.originPlace = place;
        [self.originTextField resignFirstResponder];
        [self resetAllView];
    } else if (self.selectedPlaceIndex == 1) {
        self.destPlace = place;
        [self.destinationTextField resignFirstResponder];
        [self resetAllView];
    }
    [SubView dismissAlert];
    
    if (!self.originPlace || !self.destPlace) {
        self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = YES;
    }
}


@end
