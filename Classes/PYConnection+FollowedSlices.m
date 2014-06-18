//
//  PYConnection+FollowedSlices.m
//  Pods
//
//  Created by Perki on 18.06.14.
//
//

#import "PYConnection+FollowedSlices.h"
#import "PYConstants.h"
#import "PYClient+Utils.h"

@implementation PYConnection (FollowedSlices)

-(void)followedSlicesOnlineWithSuccessHandler:(void (^) (NSArray *slicesList))onlineSlicesList
                           errorHandler:(void (^) (NSError *error))errorHandler {
    
    
    [self apiRequest:[PYClient getURLPath:kROUTE_FOLLOWEDSLICES  withParams:nil]
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 
                 NSArray *JSON = responseDict[kPYAPIResponseFollowedSlices];
                 
                 
                 if (onlineSlicesList) {
                     return onlineSlicesList(JSON);
                     
                 }
                 
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}


@end
