//
//  PYConnection+DataManagement.m
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYConnection+DataManagement.h"
#import "PYStream+JSON.h"
#import "PYStreamsCachingUtillity.h"


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

- (void)syncNotSynchedStreamsIfAny
{
    NSMutableArray *nonSyncStreams = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncStreams addObjectsFromArray:[self.streamsNotSync allObjects]];
    for (PYStream *stream in nonSyncStreams) {
        
        //the condition is not correct : set self.channelId to shut error up, should be parentId
//        if ([stream.parentId compare:self.channelId] == NSOrderedSame) {
            //We sync only events for particular channel at time
            
            //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
            stream.isSyncTriedNow = YES;
            
            if (stream.hasTmpId) {
                
                if (stream.notSyncModify) {
                    NSLog(@"stream has tmpId and it's mofified -> do nothing. If stream doesn't have server id it needs to be added to server and that is all what is matter. Modified object will update PYStream object in cache and in unsyncList");
                    
                }
                NSLog(@"stream has tmpId and it's added");
                if (stream.notSyncAdd) {
                    
                    [self createStream:stream
                       withRequestType:PYRequestTypeSync
                        successHandler:^(NSString *createdStreamId) {
                            //If succedded remove from unsyncSet and add call syncStreamWithServer
                            //In that method we were search for stream with <createdStreamId> and we should done mapping between server and temp id in cache
                            stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                            [self.streamsNotSync removeObject:stream];
                            //We have success here. Stream is cached in createStream:withRequestType: method, remove old stream with tmpId from cache
                            //He will always have tmpId here but just in case for testing (defensive programing)
                            [PYStreamsCachingUtillity removeStream:stream];
                            
                        } errorHandler:^(NSError *error) {
                            stream.isSyncTriedNow = NO;
                            NSLog(@"SYNC error: creating stream failed");
                        }];
                }
                
            }else{
                NSLog(@"In this case stream has server id");
                
                if (stream.notSyncModify) {
                    NSLog(@"for modifified unsync streams with serverId we have to provide only modified values, not full event object");
                    
                    NSDictionary *modifiedPropertiesDic = stream.modifiedStreamPropertiesAndValues;
                    PYStream *modifiedStream = [[PYStream alloc] init];
                    modifiedStream.isSyncTriedNow = YES;
                    
                    [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                        [modifiedStream setValue:value forKey:property];
                    }];
                    
                    [self setModifiedStreamAttributesObject:modifiedStream forStreamId:stream.streamId requestType:PYRequestTypeSync successHandler:^{
                        
                        //We have success here. Stream is cached in setModifiedStreamAttributesObject:forStreamId method
                        stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                        [self.streamsNotSync removeObject:stream];
                        
                    } errorHandler:^(NSError *error) {
                        modifiedStream.isSyncTriedNow = NO;
                        stream.isSyncTriedNow = NO;
                    }];
                }
            }
        }        
    // }
}


- (void)createStream:(PYStream *)stream
     withRequestType:(PYRequestType)reqType
      successHandler:(void (^)(NSString *createdStreamId))successHandler
        errorHandler:(void (^)(NSError *error))errorHandler;
{
    [self apiRequest:kROUTE_STREAMS
         requestType:reqType
              method:PYRequestMethodPOST
            postData:[stream dictionary]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 NSString *createdStreamId = [JSON objectForKey:@"id"];
                 if (successHandler) {
                     successHandler(createdStreamId);
                 }
                 
                 [PYStreamsCachingUtillity getAndCacheStream:stream
                                                withServerId:createdStreamId
                                                 requestType:reqType];
                 
                 
             } failure:^(NSError *error) {
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     if (stream.isSyncTriedNow == NO) {
                         //If we didn't try to sync stream from unsync list that means that we have to cache that stream, otherwise leave it as is
                         //stream.channelId = self.channelId; SHOULD NOT BE COMMENTED, should use parentId ?
                         stream.notSyncAdd = YES;
                         //When we try to create stream and we came here it has tmpId
                         stream.hasTmpId = YES;
                         //this is random id
                         stream.streamId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                         //return that created id so it can work offline. Stream will be cached when added to unsync list
                         
                         [PYStreamsCachingUtillity cacheStream:stream];
                         [self addStream:stream toUnsyncList:error];
                         
                         successHandler (stream.streamId);
                         
                     }else{
                         NSLog(@"Stream wants to be synchronized on server from unsync list but there is no internet");
                     }
                     
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
             }];
}

-(void)trashOrDeleteStreamWithId:(NSString *)streamId
                    filterParams:(NSDictionary *)filter
                 withRequestType:(PYRequestType)reqType
                  successHandler:(void (^)())successHandler
                    errorHandler:(void (^)(NSError *))errorHandler
{
    [self apiRequest:[PYClient getURLPath:[NSString stringWithFormat:@"%@/%@",kROUTE_STREAMS, streamId] withParams:filter]
         requestType:reqType
              method:PYRequestMethodDELETE
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 if (successHandler) {
                     successHandler();
                 }
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

- (void)setModifiedStreamAttributesObject:(PYStream *)stream
                              forStreamId:(NSString *)streamId
                              requestType:(PYRequestType)reqType
                           successHandler:(void (^)())successHandler
                             errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_STREAMS,streamId]
         requestType:reqType
              method:PYRequestMethodPUT
            postData:[stream dictionary]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 //Cache modified stream - We cache stream
                 NSLog(@"It's stream with server id because we'll never try to call this method if stream has tempId");
                 //If streamId isn't temporary cache stream (it will be overwritten in cache)
                 [PYStreamsCachingUtillity getAndCacheStream:stream withServerId:streamId requestType:reqType];
                 
                 if (successHandler) {
                     successHandler();
                 }
                 
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     
                     if (stream.isSyncTriedNow == NO) {
                         
                         //Get current stream with id from cache
                         PYStream *currentStreamFromCache = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:streamId];
                         
                         currentStreamFromCache.notSyncModify = YES;
                         
                         NSDictionary *modifiedPropertiesDic = [stream dictionary];
                         [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                             [currentStreamFromCache setValue:value forKey:property];
                         }];
                         
                         //We have to know what properties are modified in order to make succesfull request
                         currentStreamFromCache.modifiedStreamPropertiesAndValues = [stream dictionary];
                         //We must have cached modified properties of stream in cache
                         [PYStreamsCachingUtillity cacheStream:currentStreamFromCache];
                         
                         if (successHandler) {
                             successHandler();
                         }
                         
                     }else{
                         NSLog(@"Stream with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
                 
             }];
    
}


- (void)getOnlineStreamWithId:(NSString *)streamId
                  requestType:(PYRequestType)reqType
               successHandler:(void (^) (PYStream *stream))onlineStream
                 errorHandler:(void (^) (NSError *error))errorHandler
{
    //Method below automatically cache (overwrite) all streams, so this is bad
    //When API support separate method of getting only one stream by its id this will be implemneted here
    
    //This method should get particular stream and return it, not to cache it
    [self getStreamsWithRequestType:reqType filter:nil successHandler:^(NSArray *streamsList) {
        for (PYStream *currentStream in streamsList) {
            if ([currentStream.streamId compare:streamId] == NSOrderedSame) {
                onlineStream(currentStream);
                break;
            }
        }
    } errorHandler:errorHandler];
}

@end
