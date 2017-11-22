//
//  RecentLocationHelper.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMPlace.h"

@interface GMPlaceWithLRU : GMPlace

@property (strong, nonatomic) NSNumber *lruNumber;

@end

@interface RecentLocationHelper : NSObject

+ (NSArray *)getRecentLocations;

+ (void)addRecentLocationEntry:(GMPlace *)place;

@end
