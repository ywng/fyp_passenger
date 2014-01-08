//
//  TaxiBookStringSet.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "TaxiBookStringSet.h"

@implementation TaxiBookStringSet

NSString const *TaxiBookServiceName = @"com.taxibook.taxibook";

#pragma mark -
#pragma mark - NSNotification Set
NSString const *TaxiBookNotificationUsernameCannotFind = @"com.taxibook.notification.user.username.notFound";
NSString const *TaxiBookNotificationUserLoggedOut = @"com.taxibook.notification.user.logout";

#pragma mark -
#pragma mark - Internal Key Mapping

// internal key mapping -- useful when access NSSecureUserDefault

NSString const *TaxiBookInternalKeyUserId = @"com.taxibook.internal.user.userId";
NSString const *TaxiBookInternalKeyUsername = @"com.taxibook.internal.user.username";
NSString const *TaxiBookInternalKeyEmail = @"com.taxibook.internal.user.email";
NSString const *TaxiBookInternalKeyFirstName = @"com.taxibook.internal.user.firstName";
NSString const *TaxiBookInternalKeyLastName = @"com.taxibook.internal.user.lastName";
NSString const *TaxiBookInternalKeyPhone = @"com.taxibook.internal.user.phone";
NSString const *TaxiBookInternalKeySessionToken = @"com.taxibook.internal.user.sessionToken.sessionToken";
NSString const *TaxiBookInternalKeySessionExpireTime = @"com.taxibook.internal.user.sessionToken.expireTime";
NSString const *TaxiBookInternalKeyLoggedIn = @"com.taxibook.internal.user.loggedIn";

@end