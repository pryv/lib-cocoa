//
//  AccessClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/25/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#define appId @"pryv-mobile-position-ios"

#import "AccessClient.h"

@implementation AccessClient

-(id)init
{
    self = [super init];
    if(self){
    }
    return self;
}


+ (instancetype)accessClient
{
    return  [[self alloc] init];
}

/*POST /admin/login
 Opens a new admin session, authenticating with the provided credentials. (See also POST /admin/login/persona.)*/

//- (void)getSessionWithRequestType:(PYRequestType)reqType
//                         username:(NSString *)username
//                         password:(NSString *)password
//                    applicationId:(NSString *)appLicationId
//                   successHandler:(void (^)(NSArray *folderList))successHandler
//                     errorHandler:(void (^)(NSError *error))errorHandler
//{
//    
//    NSDictionary *postData = @{@"username" : username,
//                               @"password" : password,
//                               @"appId" : @"pryv-mobile-position-ios" };
//    
//    NSMutableString *pathString = [NSMutableString stringWithFormat:@"/admin/login"];
//    [[self class] apiRequest:[pathString copy]
//                 requestType:reqType
//                      method:PYRequestMethodPOST
//                    postData:postData
//                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                         NSLog(@"JSON is %@",JSON);
//                         
//                     } failure:^(NSError *error) {
//                         NSLog(@"error is %@",error);
//                     }];
//
//}


//GET /admin/accesses
//Gets all manageable accesses, which are the shared accesses. (Your app's own access token is retrieved with POST /admin/get-app-token.)

//- (void)accessesStufWithRequestType:(PYRequestType)reqType
//                     successHandler:(void (^)(NSArray *folderList))successHandler
//                       errorHandler:(void (^)(NSError *error))errorHandler
//{
//    NSMutableString *pathString = [NSMutableString stringWithFormat:@"/accesses"];
//    [[self class] apiRequest:[pathString copy]
//                 requestType:reqType
//                      method:PYRequestMethodGET
//                    postData:nil
//                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                         NSLog(@"JSON is %@",JSON);
//                         
//                     } failure:^(NSError *error) {
//                         NSLog(@"error is %@",error);
//                     }];
//    
//}

//Creates a new shared access. You can only create accesses whose permissions are a subset of those linked to your own access token.
//@body -> The new access's data
//Successful response:
// - 201 Created
// - token (identity): The created access's token.

//- (void)accessesStufPostWithRequestType:(PYRequestType)reqType
//                     successHandler:(void (^)(NSArray *folderList))successHandler
//                       errorHandler:(void (^)(NSError *error))errorHandler
//{
//    
//    NSDictionary *postData = @{
//                               @"type": @"personal",
//                               @"name" : @"SomeName",
//                               @"permissions":@[
//                                       @{@"channelId": @"diary",
//                                         @"level" : @"contribute",
//                                         }
//                                       ],
//                               
//                               };
//    
//    NSMutableString *pathString = [NSMutableString stringWithFormat:@"/accesses"];
//    [[self class] apiRequest:[pathString copy]
//                 requestType:reqType
//                      method:PYRequestMethodPOST
//                    postData:postData
//                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                         NSLog(@"JSON is %@",JSON);
//                         
//                     } failure:^(NSError *error) {
//                         NSLog(@"error is %@",error);
//                     }];
//    
//}


@end
