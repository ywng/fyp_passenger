//
//  Order.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "Order.h"

@implementation TaxiBookGPS

@end

@interface Order ()

@end


@implementation Order

+ (Order *)newInstanceFromServerData:(id)jsonData
{
    Order *newOrder = [[Order alloc] init];
    
    // orderId
    
    id tmp = [jsonData objectForKey:@"oid"];
    
    if (tmp && tmp != [NSNull null]) {
        newOrder.orderId = [tmp integerValue];
    }
    
    // driverId
    
    tmp = [jsonData objectForKey:@"did"];
    if (tmp && tmp != [NSNull null]) {
        newOrder.driverId = [tmp integerValue];
    }
    
    // passengerId
    
    tmp = [jsonData objectForKey:@"pid"];
    if (tmp && tmp != [NSNull null]) {
        newOrder.passengerId = [tmp integerValue];
    }
    
    
    // fromGPS
    TaxiBookGPS *fromGPS = [[TaxiBookGPS alloc] init], *toGPS = [[TaxiBookGPS alloc] init];
    
    tmp = [jsonData objectForKey:@"locaton_from"];
    if (tmp && tmp!= [NSNull null]) {
        fromGPS.streetDescription = tmp;
    }
    
    tmp = [jsonData objectForKey:@"gps_from_latitude"];
    if (tmp && tmp!= [NSNull null]) {
        fromGPS.latitude = [tmp floatValue];
    }
    
    tmp = [jsonData objectForKey:@"gps_from_longitude"];
    if (tmp && tmp!= [NSNull null]) {
        fromGPS.longitude = [tmp floatValue];
    }
    
    newOrder.fromGPS = fromGPS;
    
    // toGPS
    
    tmp = [jsonData objectForKey:@"locaton_to"];
    if (tmp && tmp!= [NSNull null]) {
        toGPS.streetDescription = tmp;
    }
    
    tmp = [jsonData objectForKey:@"gps_to_latitude"];
    if (tmp && tmp!= [NSNull null]) {
        toGPS.latitude = [tmp floatValue];
    }
    
    tmp = [jsonData objectForKey:@"gps_to_longitude"];
    if (tmp && tmp!= [NSNull null]) {
        toGPS.longitude = [tmp floatValue];
    }
    
    newOrder.toGPS = toGPS;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzzzz"];
    
    // postTime
    
    tmp = [jsonData objectForKey:@"post_time"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.postTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ +08:00", tmp]];
    }
    
    // orderTime
    
    tmp = [jsonData objectForKey:@"order_time"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.orderTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ +08:00", tmp]];
    }
    
    // specialNote
    
    tmp = [jsonData objectForKey:@"special_note"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.specialNote = tmp;
    }
    
    // orderStatus
    tmp = [jsonData objectForKey:@"status_id"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.orderStatus = (OrderStatus)([tmp integerValue]);
        
    } else {
        newOrder.orderStatus = OrderStatusUnknown;
    }
    
    // estimatedPrice
    
    tmp = [jsonData objectForKey:@"estimated_price"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.estimatedPrice = [tmp floatValue];
    }
    
    // estimatedDuration
    
    tmp = [jsonData objectForKey:@"estimated_duration"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.estimatedDuration = (NSTimeInterval)[tmp doubleValue];
    }
    
    // estimatedPickupTime
    
    tmp = [jsonData objectForKey:@"estimated_pickuptime"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.estimatedPickupTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ +08:00", tmp]];
    }
    
    // actual price
    
    tmp = [jsonData objectForKey:@"actual_price"];
    if (tmp && tmp!= [NSNull null]) {
        newOrder.actualPrice = [tmp floatValue];
    }
    
    return newOrder;
}


@end
