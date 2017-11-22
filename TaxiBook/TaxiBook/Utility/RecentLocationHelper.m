//
//  RecentLocationHelper.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/4/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "RecentLocationHelper.h"

@implementation GMPlaceWithLRU

@end

@implementation RecentLocationHelper

#define DefaultMaxCount 20

+ (NSArray *)getRecentLocations
{
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"recentPlace.plist"];
    
    // check to see if Data.plist exists in documents
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        // read property list into memory as an NSData object
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSArray *temp = (NSArray *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        NSMutableArray *tempPlace = [[NSMutableArray alloc] init];
        if ([temp count] > 0) {
            for (int i = 0; i < [temp count]; i++) {
                NSDictionary *dict = [temp objectAtIndex:i];
                GMPlaceWithLRU *recentPlace = [[GMPlaceWithLRU alloc] init];
                recentPlace.placeId = [dict objectForKey:@"placeId"];
                recentPlace.placeAddress = [dict objectForKey:@"placeAddress"];
                recentPlace.placeReference = [dict objectForKey:@"placeReference"];
                recentPlace.placeSecondaryDescription = [dict objectForKey:@"placeSecondaryDescription"];
                recentPlace.placeDescription = [dict objectForKey:@"placeDescription"];
                recentPlace.coordinate = CLLocationCoordinate2DMake([[dict objectForKey:@"coordinate-latitude"] doubleValue], [[dict objectForKey:@"coordinate-longitude"] doubleValue]);
                recentPlace.lruNumber = [dict objectForKey:@"lruNumber"];
                
                [tempPlace addObject:recentPlace];
            }
        }
        return tempPlace;
    }
    return @[];
}

+ (void)addRecentLocationEntry:(GMPlace *)place
{
    NSMutableArray *currentLocationList = [[NSMutableArray alloc] initWithArray:[RecentLocationHelper getRecentLocations]];
    // check if there is any matched place
    NSInteger matchIndex = -1;
    
    for (GMPlaceWithLRU *recentPlace in currentLocationList) {
        NSString *recentPlaceCoordinateString = [NSString stringWithFormat:@"%g,%g", recentPlace.coordinate.latitude, recentPlace.coordinate.longitude];
        NSString *placeCoordinateString = [NSString stringWithFormat:@"%g,%g", place.coordinate.latitude, place.coordinate.longitude];
        if ([recentPlaceCoordinateString isEqualToString:placeCoordinateString]) {
            matchIndex = [currentLocationList indexOfObject:recentPlace];
            break;
        }
    }
    if (matchIndex != -1) {
        // good, replace the LRU number and put it back
        for (int i = 0; i < [currentLocationList count]; i++) {
            GMPlaceWithLRU *recentPlace = [currentLocationList objectAtIndex:i];
            if (i == matchIndex) {
                recentPlace.lruNumber = @(0);
            } else {
                recentPlace.lruNumber = [NSNumber numberWithInteger:[recentPlace.lruNumber integerValue] + 1];
            }
        }
    } else {
        NSInteger removeIndex = -1;
        for (GMPlaceWithLRU *recentPlace in currentLocationList) {
            if ([recentPlace.lruNumber integerValue]  == [currentLocationList count] - 1) {
                // remove
                removeIndex = [currentLocationList indexOfObject:recentPlace];
            }
            recentPlace.lruNumber = [NSNumber numberWithInteger:[recentPlace.lruNumber integerValue] + 1];
        }
        if ([currentLocationList count] >= DefaultMaxCount) {
            // delete the entry with largest LRU number
            if (removeIndex != -1) {
                [currentLocationList removeObjectAtIndex:removeIndex];
            }
        }
        GMPlaceWithLRU *mostRecentPlace = [[GMPlaceWithLRU alloc] init];
        mostRecentPlace.placeId = place.placeId;
        mostRecentPlace.placeAddress = place.placeAddress;
        mostRecentPlace.placeDescription = place.placeDescription;
        mostRecentPlace.placeReference = place.placeReference;
        mostRecentPlace.placeSecondaryDescription = place.placeSecondaryDescription;
        mostRecentPlace.coordinate = place.coordinate;
        mostRecentPlace.lruNumber = @(0);
        
        [currentLocationList addObject:mostRecentPlace];
    }
    
    // save back
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:[currentLocationList count]];
    
    for (GMPlaceWithLRU *recentPlace in currentLocationList) {
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        if (recentPlace.placeId) {
            [tempDict setObject:recentPlace.placeId forKey:@"placeId"];
        }
        if (recentPlace.placeAddress) {
            [tempDict setObject:recentPlace.placeAddress forKey:@"placeAddress"];
        }
        if (recentPlace.placeDescription) {
            [tempDict setObject:recentPlace.placeDescription forKey:@"placeDescription"];
        }
        if (recentPlace.placeReference) {
            [tempDict setObject:recentPlace.placeReference forKey:@"placeReference"];
        }
        if (recentPlace.placeSecondaryDescription) {
            [tempDict setObject:recentPlace.placeSecondaryDescription forKey:@"placeSecondaryDescription"];
        }
        if (recentPlace.lruNumber) {
            [tempDict setObject:recentPlace.lruNumber forKey:@"lruNumber"];
        }
        if (recentPlace.coordinate.latitude != 0 || recentPlace.coordinate.longitude != 0) {
            [tempDict setObject:@(recentPlace.coordinate.longitude) forKey:@"coordinate-longitude"];
            [tempDict setObject:@(recentPlace.coordinate.latitude) forKey:@"coordinate-latitude"];
        }
        [dataArray addObject:tempDict];
    }
    [RecentLocationHelper _saveInternally:dataArray];
    
}

+ (void)_saveInternally:(NSArray *)array
{
    // get paths from root direcory
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	// get documents path
	NSString *documentsPath = [paths objectAtIndex:0];
	// get the path to our Data/plist file
	NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"recentPlace.plist"];
    
    NSString *error = nil;
	// create NSData from dictionary
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:array format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    // check is plistData exists
	if(plistData)
	{
		// write plistData to our Data.plist file
        [plistData writeToFile:plistPath atomically:YES];
    }
    else
	{
        NSLog(@"Error in saveData: %@", error);
    }

}


@end
