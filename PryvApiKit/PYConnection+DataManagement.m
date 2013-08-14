//
//  PYConnection+DataManagement.m
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYConnection+DataManagement.h"
#import "PYStream+JSON.h"


@implementation PYConnection (DataManagement)

- (void)getAllStreamsWithRequestType:(PYRequestType)reqType
                    gotCachedStreams:(void (^) (NSArray *cachedStreamList))cachedStreams
                    gotOnlineStreams:(void (^) (NSArray *onlineStreamList))onlineStreams
                        errorHandler:(void (^)(NSError *error))errorHandler;

{
    //Return current cached streams
    NSArray *allStreamsFromCache = [PYStreamsCachingUtillity getStreamsFromCache];
    [allStreamsFromCache makeObjectsPerformSelector:@selector(setConnection:) withObject:self];
    if (cachedStreams) {
        NSUInteger currentNumberOfStreamsInCache = [PYStreamsCachingUtillity getStreamsFromCache].count;
        if (currentNumberOfStreamsInCache > 0) {
            //if there are cached streams return it, when get response return in onlineList
            cachedStreams(allStreamsFromCache);
        }
    }
    
    //This method should retrieve always online streams and streamsToAdd, streamsModified, streamsToRemove (for visual details) - not yet implemented due to web service limitations
    [self getStreamsWithRequestType:reqType
                             filter:nil
                     successHandler:^(NSArray *streamsList) {
                         if (onlineStreams) {
                             onlineStreams(streamsList);
                         }
                     }
                       errorHandler:errorHandler];
    
}

- (void)getStreamsWithRequestType:(PYRequestType)reqType
                           filter:(NSDictionary*)filterDic
                   successHandler:(void (^) (NSArray *eventList))onlineStreamList
                     errorHandler:(void (^)(NSError *error))errorHandler
{
    //This method should retrieve always online streams and need to cache (sync) online streams
    
    [self apiRequest:[PYClient getURLPath:kROUTE_STREAMS withParams:filterDic]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSMutableArray *streamList = [[NSMutableArray alloc] init];
                 for(NSDictionary *streamDictionary in JSON){
                     PYStream *streamObject = [PYStream streamFromJSON:streamDictionary];
                     streamObject.connection = self;
                     [streamList addObject:streamObject];
                 }
                 if(onlineStreamList){
                     [PYStreamsCachingUtillity cacheStreams:JSON];
                     onlineStreamList([streamList autorelease]);
                 }
             } failure:^(NSError *error){
                 if(errorHandler){
                     errorHandler(error);
                 }
             }
     ];
    
}

@end
