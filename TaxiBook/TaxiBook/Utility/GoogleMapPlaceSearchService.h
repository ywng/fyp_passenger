//
//  GoogleMapPlaceSearchService.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Custom class for Google Place Search API Result
*/
@interface GMPlace : NSObject

@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *placeDescription;
@property (strong, nonatomic) NSString *placeSecondaryDescription;

@end

@protocol GMPlaceSearchServiceDelegate <NSObject>

- (void)finishDownloadPlaceSearch:(NSArray *)places;

@end

@interface GoogleMapPlaceSearchService : NSObject

+ (void)searchWithKeyword:(NSString *)keyword withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate;

+ (void)autoCompleteWithKeyword:(NSString *)keyword gpsEnable:(BOOL)gpsEnable withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate;

@end
