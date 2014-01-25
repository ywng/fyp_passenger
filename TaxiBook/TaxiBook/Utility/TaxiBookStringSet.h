//
//  TaxiBookStringSet.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxiBookStringSet : NSObject

extern NSString *TaxiBookServiceName;
extern NSString *TaxiBookGoogleAPIIOSKey;
extern NSString *TaxiBookGoogleAPIServerKey;



#pragma mark -
#pragma mark - NSNotification Set
extern NSString *TaxiBookNotificationEmailCannotFind;
extern NSString *TaxiBookNotificationUserLoggedIn;
extern NSString *TaxiBookNotificationUserLoggedOut;

#pragma mark -
#pragma mark - Internal Key Mapping

// internal key mapping -- useful when access NSSecureUserDefault

extern NSString *TaxiBookInternalKeyUserId;
//extern NSString *TaxiBookInternalKeyUsername;
extern NSString *TaxiBookInternalKeyEmail;
extern NSString *TaxiBookInternalKeyFirstName;
extern NSString *TaxiBookInternalKeyLastName;
extern NSString *TaxiBookInternalKeyPhone;
extern NSString *TaxiBookInternalKeySessionToken;
extern NSString *TaxiBookInternalKeySessionExpireTime;
extern NSString *TaxiBookInternalKeyLoggedIn;
extern NSString *TaxiBookInternalKeyLanguage;

@end
