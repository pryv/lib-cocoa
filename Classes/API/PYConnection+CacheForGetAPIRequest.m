//
//  PYConnection+CacheForGetAPIRequest.m
//  Pods
//
//  Created by Perki on 30.06.14.
//
//

#import "PYConnection+CacheForGetAPIRequest.h"

@implementation PYConnection (CacheForGetAPIRequest)


/**
 * Make a "get" request Online and CacheIt
 */
- (void) apiRequestGetOnlineAndCache:(NSString *)path
                             success:(void(^)(NSDictionary *JSON))successHandler
                             failure:(PYClientFailureBlock)failureHandler {
    
    [self apiRequest:path method:PYRequestMethodGET postData:nil attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSON) {
                 [self.cacheForGetAPIRequests setObject:JSON forKey:path];
                 [self.cacheForGetAPIRequests setObject:[NSDate date] forKey:[path stringByAppendingString:@" date"]];
                 if (successHandler) successHandler(JSON);
             } failure:^(NSError *error) {
                 if (failureHandler) failureHandler(error);
             }];
}

- (void) apiRequestGetOnlineOrFromCache:(NSString *)path
                     refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                                success:(void(^)(NSDate *cachedAt, NSDictionary *JSON))successHandler
                                failure:(PYClientFailureBlock)failureHandler {
    
    NSDictionary* JSON = [self.cacheForGetAPIRequests objectForKey:path];
    NSDate* date = [self.cacheForGetAPIRequests objectForKey:[path stringByAppendingString:@" date"]];

    
    if (JSON && date && successHandler && (maxAge > 0)) {
        if ([date timeIntervalSinceNow] < maxAge)
            return successHandler(date, JSON);
    };
    
    
    [self apiRequestGetOnlineAndCache:path
             success:^(NSDictionary *JSON) {
                 if (successHandler) successHandler(nil, JSON);
             } failure:^(NSError *error) {
                 if (JSON && date && successHandler) {
                         return successHandler(date, JSON);
                 };
                 if (failureHandler) failureHandler(error);
             }];
}



@end
