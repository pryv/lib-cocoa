//
//  PYChannelClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannelClient.h"
#import "AFNetworking.h"
#import "PYChannel+JSON.h"

@implementation PYChannelClient

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(PYChannelClient)

-(id)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

+(instancetype) channelClient
{
    PYChannelClient *channelClient = [[PYChannelClient alloc] init];
    return channelClient;
}

#pragma mark - PrYv API Channel get all (GET /channnels)

- (void)getChannelsWithRequestType:(PYRequestType)reqType filterParams:(NSString *)filter successHandler:(void (^)(NSArray *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableString *pathString = [NSMutableString stringWithString:@"/channels"];
    if(filter){
        [pathString appendFormat:@"?%@", filter];
    }
    [[self class] apiRequest:[pathString copy] requestType:reqType method:PYRequestMethodGET postData:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *channelList = [[NSMutableArray alloc] init];
        for(NSDictionary *channelDictionary in JSON){
            PYChannel *channelObject = [PYChannel channelFromJson:channelDictionary];
            [channelList addObject:channelObject];
        }
        if(successHandler){
            successHandler(channelList);
        }
    } failure:^(NSError *error){
        if(errorHandler){
            errorHandler(error);
        }
    }];
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
    [[self class] apiRequest:[pathString copy] requestType:reqType method:PYRequestMethodPUT postData:data success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
