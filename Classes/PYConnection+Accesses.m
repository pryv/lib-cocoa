//
//  PYConnection+Accesses.m
//  Pods
//
//  Created by Perki on 16.06.14.
//
//

#import "PYConnection+Accesses.h"
#import "PYConstants.h"
#import "PYClient+Utils.h"

@implementation PYConnection (Accesses)

-(void)accessesOnlineWithSuccessHandler:(void (^) (NSArray *accessesList))onlineAccessesList
                           errorHandler:(void (^) (NSError *error))errorHandler {
    
    
    [self apiRequest:[PYClient getURLPath:kROUTE_ACCESSES  withParams:nil]
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 
                 NSArray *JSON = responseDict[kPYAPIResponseAccesses];
                 
                 
                 if (onlineAccessesList) {
                     return onlineAccessesList(JSON);
                     
                 }
                
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}
@end
