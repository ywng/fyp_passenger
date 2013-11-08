//
//  TaxiBookConnectionManager.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 8/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "TaxiBookConnectionManager.h"
#import "SSKeychain/SSKeychain.h"
#import "NSUserDefaults+SecureAdditions.h"

@implementation TaxiBookHTTPOperation

@end

@interface TaxiBookConnectionManager ()

@property (strong, nonatomic) NSString *serverDomain;
@property (atomic) BOOL isLoggingIn;

@property (strong, nonatomic) AFHTTPRequestOperationManager *normalRequestManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *imageRequestManager;

@property (strong, nonatomic) NSMutableArray *waitForProcessQueue;

@end


@implementation TaxiBookConnectionManager

+ (TaxiBookConnectionManager *)sharedManager
{
    static TaxiBookConnectionManager *_manager = nil;
    
    if (!_manager) {
        _manager = [[TaxiBookConnectionManager alloc] init];
    }
    return _manager;

}

- (NSMutableArray *)waitForProcessQueue
{
    if (!_waitForProcessQueue) {
        _waitForProcessQueue = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _waitForProcessQueue;
}

- (AFHTTPRequestOperationManager *)normalRequestManager
{
    if (!_normalRequestManager) {
        _normalRequestManager = [AFHTTPRequestOperationManager manager];
    }
    
    return _normalRequestManager;
}

- (AFHTTPRequestOperationManager *)imageRequestManager
{
    if (!_imageRequestManager) {
        _imageRequestManager = [AFHTTPRequestOperationManager manager];
    }
    
    return _imageRequestManager;
}



- (void)loginwithParemeters:(NSDictionary *)formDataParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"new login request to server");
    if (self.isLoggingIn) {
        NSError *error = [NSError errorWithDomain:TaxiBookServiceName code:TaxiBookErrorAlreadyLoggingIn userInfo:@{@"internal_message": @"logging in, please try again"}];
        
        failure(nil, error);
        return ; // stop the request
    }
    
    [self setIsLoggingIn:YES];
    NSString *postUrl = [[NSString stringWithFormat:@"%@%@", self.serverDomain, @"/passenger/login/"] stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    
    [self.normalRequestManager POST:postUrl parameters:formDataParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"received login data from server");
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        
        [self setIsLoggingIn:NO];
        
        if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            
            NSString *sessionToken = [responseObject objectForKey:@"session_token"];
            NSString *expireTime = [responseObject objectForKey:@"expire_time"];
            NSString *username = [responseObject objectForKey:@"username"];
            NSNumber *userId = [responseObject objectForKey:@"user_id"];
            
            [[NSUserDefaults standardUserDefaults] setSecretObject:username forKey:TaxiBookInternalKeyUsername];
            [[NSUserDefaults standardUserDefaults] setSecretObject:sessionToken forKey:TaxiBookInternalKeySessionToken];
            [[NSUserDefaults standardUserDefaults] setSecretObject:expireTime forKey:TaxiBookInternalKeySessionExpireTime];
            [[NSUserDefaults standardUserDefaults] setSecretObject:userId forKey:TaxiBookInternalKeyUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            success(operation, responseObject);
            for (NSInteger index = [self.waitForProcessQueue count] - 1; index >= 0; index -- ) {
                // pop all operation in the queue with the cannot login error
                TaxiBookHTTPOperation *taxibookOperation = [self.waitForProcessQueue objectAtIndex:index];
                [self.waitForProcessQueue removeLastObject];
                if (taxibookOperation.requestType == RequestManagerTypeNormal) {
                    [self postToUrl:taxibookOperation.relativeUrl withParameters:taxibookOperation.params success:taxibookOperation.success failure:taxibookOperation.failure loginIfNeed:NO];
                } else {
                    // we do not have photo upload for now
//                    [self uploadImageToUrl:taxibookOperation.relativeUrl withParameters:taxibookOperation.params filePath:taxibookOperation.fileURL success:taxibookOperation.success failure:taxibookOperation.failure loginIfNeed:NO];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setIsLoggingIn:NO];
        NSLog(@"received login error data from server %@", error);
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
        [userInfo setObject:@"loginError" forKey:@"addition error messsage"];
        
        NSError *customError = [NSError errorWithDomain:TaxiBookServiceName code:-4 userInfo:userInfo];
        for (NSInteger index = [self.waitForProcessQueue count] - 1; index >= 0; index -- ) {
            // pop all operation in the queue with the cannot login error
            TaxiBookHTTPOperation *taxibookOperation = [self.waitForProcessQueue objectAtIndex:index];
            [self.waitForProcessQueue removeLastObject];
            taxibookOperation.failure(operation, customError);
        }
        
        failure(operation, error);
    }];
}

- (void)postToUrl:(NSString *)relativeUrl withParameters:(NSDictionary *)formDataParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure loginIfNeed:(BOOL)loginIfNeed
{
    NSLog(@"new request to server: %@ param: %@", relativeUrl, formDataParameters);
    
    NSMutableDictionary *combinedParameters = [[NSMutableDictionary alloc] initWithDictionary:formDataParameters copyItems:YES];
    
    if (![combinedParameters objectForKey:TaxiBookInternalKeyUsername]) {
        
        // get username and session_token stored in nsuserdefault
        
        NSString *username = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyUsername];
        if (!username) {
            NSLog(@"username cannot find");
            [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUsernameCannotFind object:nil];
            return ;
        }
        NSString *sessionToken = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeySessionToken];
        if (!sessionToken) {
            NSLog(@"session token cannot find");
            sessionToken = @""; // let it expire the token and re-login
        }
        
        [combinedParameters setValue:username forKey:@"username"];
        [combinedParameters setValue:sessionToken forKey:@"session_token"];
    }
    
    NSString *postUrl = [[NSString stringWithFormat:@"%@%@", self.serverDomain, relativeUrl] stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    
    [self.normalRequestManager POST:postUrl parameters:combinedParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *responseStatusCode = [responseObject objectForKey:@"status_code"];
        NSLog(@"received data from server %@", relativeUrl);
        if (responseStatusCode && [responseStatusCode integerValue] == -1 && loginIfNeed) {
            // Credential checking failed, re-login the user

            NSDictionary *parameters = nil;
            NSString *reLoginEmail = [[NSUserDefaults standardUserDefaults] secretStringForKey:TaxiBookInternalKeyEmail];
            NSString *password = [SSKeychain passwordForService:TaxiBookServiceName account:reLoginEmail];

            if (!password) {
                // cannot find a password
                [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
                return;
            }
            parameters = @{@"email" : reLoginEmail, @"password" : password};
            
            [self loginwithParemeters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // re-do the post method again
                [self postToUrl:relativeUrl withParameters:formDataParameters success:success failure:failure loginIfNeed:NO]; // break the loop if credential check if fail again
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if ([error.domain isEqualToString:TaxiBookServiceName] && error.code == TaxiBookErrorAlreadyLoggingIn) {
                    // create a TaxiBookHTTPOperation object
                    TaxiBookHTTPOperation *taxibookOperation = [[TaxiBookHTTPOperation alloc] init];
                    taxibookOperation.relativeUrl = relativeUrl;
                    taxibookOperation.requestType = RequestManagerTypeNormal;
                    taxibookOperation.params = formDataParameters;
                    taxibookOperation.success = success;
                    taxibookOperation.failure = failure;
                    [self.waitForProcessQueue insertObject:taxibookOperation atIndex:0];
                } else {
                    // force logout
                    [[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedOut object:nil];
                }
            }];
        }
        else if (responseStatusCode && [responseStatusCode integerValue] < 0) {
            NSError *errorWithMessage = [NSError errorWithDomain:TaxiBookServiceName code:[responseStatusCode integerValue] userInfo:@{@"message": [responseObject objectForKey:@"message"]}];
            failure(operation, errorWithMessage); // negative reponse code consider to be fail
        } else {
            success(operation, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error.domain isEqualToString:TaxiBookServiceName]) {
            NSLog(@"received error from server %@ %@", relativeUrl, error);
        }
        failure(operation, error);
    }];
}

- (void)loadImageFromUrl:(NSString *)url success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFImageResponseSerializer *imageResponse = [[AFImageResponseSerializer alloc] init];
    
    [self.imageRequestManager setResponseSerializer:imageResponse];
    [self.imageRequestManager GET:url parameters:nil success:success failure:failure];
}

- (id)init
{
    if (self = [super init]) {
        self.serverDomain = @"";
        self.isLoggingIn = NO;
//        __weak TaxiBookConnectionManager *weakSelf = self;
        [self.normalRequestManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"internet status change %ld" ,status);
            if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
                // network not available
            }
        }];
    }
    return self;

}

- (void)dealloc
{
    if (_normalRequestManager) {
        _normalRequestManager = nil;
    }
    if (_imageRequestManager) {
        _imageRequestManager = nil;
    }
}

@end
