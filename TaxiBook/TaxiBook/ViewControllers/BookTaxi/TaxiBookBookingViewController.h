//
//  TaxiBookBookingViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubView.h"

@interface TaxiBookBookingViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (weak, nonatomic) IBOutlet UITextField *originTextField;
@property (weak, nonatomic) IBOutlet UIView *originSearchTableView;
@property (weak, nonatomic) IBOutlet UIButton *originMapButton;


@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UIView *destSearchTableView;
@property (weak, nonatomic) IBOutlet UIButton *destMapButton;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;



// Constraints to be changed dynamic
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *destContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeContainerViewHeightConstraint;

@end
