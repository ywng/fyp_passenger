//
//  TaxiBookBookingSummaryTableViewCell.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 20/3/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxiBookBookingSummaryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
