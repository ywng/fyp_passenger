//
//  Order.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 10/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, OrderStatus) {
    OrderStatusPending = 0,
    OrderStatusBidded = 1,
    OrderStatusCustomerConfirmed = 2,
    OrderStatusDriverComing = 3,
    OrderStatusDriverWaiting = 4,
    OrderStatusDriverPickedUp = 5,
    OrderStatusOrderFinished = 6,
    OrderStatusUnknown = 1<<9
};


@interface TaxiBookGPS : NSObject

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) NSString *streetDescription;

@end


@interface Order : NSObject

@property (nonatomic) NSInteger orderId;
@property (nonatomic) NSInteger driverId;
@property (nonatomic) NSInteger passengerId; // current user id
@property (strong, nonatomic) TaxiBookGPS *fromGPS;
@property (strong, nonatomic) TaxiBookGPS *toGPS;
@property (strong, nonatomic) NSDate *postTime;
@property (strong, nonatomic) NSDate *orderTime;
@property (strong, nonatomic) NSString *specialNote;
@property (nonatomic) OrderStatus orderStatus;
@property (nonatomic) float estimatedPrice;
@property (nonatomic) NSTimeInterval estimatedDuration;
@property (strong, nonatomic) NSDate *estimatedPickupTime;


// only inactive order
@property (nonatomic) float actualPrice;

+ (Order *)newInstanceFromServerData:(id)jsonData;

@end
