//
//  PlaceSearchResultTableViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapPlaceSearchService.h"

@protocol PlaceSearchResultDelegate <NSObject>

- (void)userDidSelectThePlaceName:(GMPlace *)place;
- (void)downloadTheExactPlace:(GMPlace *)place;

@end

@interface PlaceSearchResultTableViewController : UITableViewController <CLLocationManagerDelegate, GMPlaceSearchServiceDelegate>

@property (strong, nonatomic) NSString *searchString;
@property (weak, nonatomic) id<PlaceSearchResultDelegate> delegate;

@end
