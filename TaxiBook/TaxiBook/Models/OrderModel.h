//
//  OrderModel.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 28/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@class OrderModel;

@protocol OrderModelDelegate <NSObject>

- (void)finishDownloadOrders:(OrderModel *)orderModel;
- (void)failDownloadOrders:(OrderModel *)orderModel;

@end

@interface OrderModel : NSObject

#define DefaultOrderModelLimit 20

+ (OrderModel *)newInstanceWithIdentifier:(NSString *)identifier delegate:(id<OrderModelDelegate>)delegate;

- (void)clearData;
- (NSUInteger)count;
- (Order *)objectAtIndex:(NSUInteger)index;
- (void)downloadActiveOrders;
- (void)downloadActiveOrders:(NSUInteger)limit offset:(NSUInteger)offset;

- (void)downloadOrderDetail:(NSUInteger)orderId;


@end
