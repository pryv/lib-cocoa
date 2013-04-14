//
//  PYAccess.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYAccess.h"
#import "PYChannel+JSON.h"

@implementation PYAccess

@synthesize userID = _userID;
@synthesize accessToken = _accessToken;

- (void)dealloc
{
    [_userID release];
    [_accessToken release];
    [super dealloc];
}

#pragma mark - PrYv API Channel get all (GET /channnels)

- (void)getChannelsWithRequestType:(PYRequestType)reqType
                      filterParams:(NSDictionary *)filter
                    successHandler:(void (^)(NSArray *))successHandler
                      errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableString *pathString = [NSMutableString stringWithString:@"/channels"];
    if (filter) {
        
        [pathString appendString:@"?"];
        for (NSString *key in [filter allKeys])
        {
            [pathString appendFormat:@"%@=%@&",key,[filter valueForKey:key]];
        }
        [pathString deleteCharactersInRange:NSMakeRange([pathString length]-1, 1)];
        
    }
    
    [PYClient apiRequest:pathString
                   access:self
              requestType:reqType
                   method:PYRequestMethodGET
                postData:nil
             attachments:nil
                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     NSMutableArray *channelList = [[NSMutableArray alloc] init];
                     for(NSDictionary *channelDictionary in JSON){
                         PYChannel *channelObject = [PYChannel channelFromJson:channelDictionary];
                         channelObject.access = self;
                         [channelList addObject:channelObject];
                     }
                     if(successHandler){
                         successHandler(channelList);
                     }
                 } failure:^(NSError *error){
                     if(errorHandler){
                         errorHandler(error);
                     }
                 }
      ];
}

//#pragma mark - PrYv API Channel create (POST /channnels)

//- (void)createChannelWithRequestType:(PYRequestType)reqType
//                             channel:(PYChannel *)newChannel
//                      successHandler:(void (^)(PYChannel *channel))successHandler
//                        errorhandler:(void (^)(NSError *error))errorHandler
//{
//    NSString *pathString = @"/channels";
//
//    NSDictionary *postData = [PYChannel jsonFromChannel:newChannel];
//
//    [[self class] apiRequest:pathString requestType:reqType method:PYRequestMethodPOST postData:postData success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"JSON %@", JSON);
//        NSString *channelId = [JSON objectForKey:@"id"];
//        newChannel.channelId = channelId;
//        if(successHandler){
//            successHandler(newChannel);
//        }
//    } failure:^(NSError *error){
//        if(errorHandler){
//            errorHandler(error);
//        }
//    }];
//}

- (void)editChannelWithRequestType:(PYRequestType)reqType
                         channelId:(NSString *)channelId
                              data:(NSDictionary *)data
                    successHandler:(void (^)())successHandler
                      errorHandler:(void (^)(NSError *error))errorHandler
{
    NSString *pathString = [NSString stringWithFormat:@"/channels/%@", channelId];
    [PYClient apiRequest:pathString
              access:self
         requestType:reqType
              method:PYRequestMethodPUT
            postData:data
             attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 if(successHandler){
                     successHandler();
                 }
             } failure:^(NSError *error){
                 if(errorHandler){
                     errorHandler(error);
                 }
             }];
}

- (void)deleteChannelWithRequestType:(PYRequestType)reqType
                           channelId:(NSString *)channelId
                      successHandler:(void (^)())successHandler
                        errorHandler:(void (^)(NSError *error))errorHandler
{
    NSString *pathString = [NSString stringWithFormat:@"/channels/%@", channelId];

    [PYClient apiRequest:pathString
                  access:self
             requestType:reqType
                  method:PYRequestMethodDELETE
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     if(successHandler){
                         successHandler();
                     }
                 } failure:^(NSError *error){
                     if(errorHandler){
                         errorHandler(error);
                     }
                 }];

}

@end
