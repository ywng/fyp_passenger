//
//  PlaceSearchResultTableViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapPlaceSearchService.h"

@interface PlaceSearchResultTableViewController : UITableViewController <GMPlaceSearchServiceDelegate>

@property (strong, nonatomic) NSString *searchString;

@end
