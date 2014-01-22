//
//  GoogleMapPlaceSearchService.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "GoogleMapPlaceSearchService.h"
#import <AFNetworking/AFNetworking.h>
#import <GoogleMaps/GoogleMaps.h>

@implementation GMPlace

@end


@interface GoogleMapPlaceSearchService ()

@end

@implementation GoogleMapPlaceSearchService

static NSString *queryAutoCompleteUrl = @"https://maps.googleapis.com/maps/api/place/queryautocomplete/json?";

+ (void)searchWithKeyword:(NSString *)keyword withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate
{
    
}

+ (void)autoCompleteWithKeyword:(NSString *)keyword gpsEnable:(BOOL)gpsEnable withDelegate:(id<GMPlaceSearchServiceDelegate>)delegate
{
    NSString *completedUrl = [NSString stringWithFormat:@"%@key=%@&sensor=%@&input=%@", queryAutoCompleteUrl, TaxiBookGoogleAPIServerKey, gpsEnable?@"true":@"false", [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
//    completedUrl = [completedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"completed URL %@", completedUrl);
    
    [[AFHTTPRequestOperationManager manager] GET:completedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // parse the object here
//        NSLog(@"responseObject %@", responseObject);
        id predictions = [responseObject objectForKey:@"predictions"];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (id prediction in predictions) {
            GMPlace *place = [[GMPlace alloc] init];
            
            place.placeId = [prediction objectForKey:@"id"];
            place.placeSecondaryDescription = [prediction objectForKey:@"description"];
            
            id terms = [prediction objectForKey:@"terms"];
            NSString *description = nil;
            for (id term in terms) {
                if (!description) {
                    description = [term objectForKey:@"value"];
                    break;
                }
            }
            place.placeDescription = description;
            
            [array addObject:place];
        }
        
        [delegate finishDownloadPlaceSearch:array];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to download auto complete search result, error %@", error);
    }];
}

@end
