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
#import "PYEventFilterUtility.h"


@implementation PYConnection (DataManagement)

#pragma mark - Pryv API Streams

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

-(void)trashOrDeleteStream:(PYStream *)stream
                    filterParams:(NSDictionary *)filter
                 withRequestType:(PYRequestType)reqType
                  successHandler:(void (^)())successHandler
                    errorHandler:(void (^)(NSError *))errorHandler
{
    [self apiRequest:[PYClient getURLPath:[NSString stringWithFormat:@"%@/%@",kROUTE_STREAMS, stream.streamId] withParams:filter]
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

#pragma mark - Pryv API Events

- (void)getOnlineEventWithId:(NSString *)eventId
                 requestType:(PYRequestType)reqType
              successHandler:(void (^) (PYEvent *event))onlineEvent
                errorHandler:(void (^) (NSError *error))errorHandler
{
    //Method below automatically cache (overwrite) all events from this channel, so this is bad
    //When API support separate method of getting only one event by its id this will be implemneted here
    
    //This method should get particular event and return it, not to cache it
    
    [self getEventsWithRequestType:reqType
                            filter:nil
                    successHandler:^(NSArray *eventList) {
                        for (PYEvent *currentEvent in eventList) {
                            if ([currentEvent.eventId compare:eventId] == NSOrderedSame) {
                                onlineEvent(currentEvent);
                                break;
                            }
                        }
                    }
                      errorHandler:errorHandler
                shouldSyncAndCache:NO];
}

//GET /{channel-id}/events

- (void)getEventsWithRequestType:(PYRequestType)reqType
                          filter:(NSDictionary*)filterDic
                  successHandler:(void (^) (NSArray *eventList))onlineEventsList
                    errorHandler:(void (^) (NSError *error))errorHandler
              shouldSyncAndCache:(BOOL)syncAndCache
{
    /*
     This method musn't be called directly (it's api support method). This method works ONLY in ONLINE mode
     This method doesn't care about current cache, it's interested in online events only
     It should retrieve always online events for this channel and need to cache (sync) online events (before caching sync unsyched, because we don't want to loose unsuc changes)
     */
    
    /*if there are events that are not synched with server, they need to be synched first and after that cached
     This method must be SYNC not ASYNC and this method sync events with server and cache them
     */
    if (syncAndCache == YES) {
        [self syncNotSynchedEventsIfAny];
    }
    
    [self apiRequest:[PYClient getURLPath:kROUTE_EVENTS withParams:filterDic]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
                 NSMutableArray *eventsCachingArray = [[NSMutableArray alloc] init];
                 [eventsCachingArray addObjectsFromArray:JSON];
                 
                 for (int i = 0; i < [JSON count]; i++) {
                     
                     NSDictionary *eventDic = [JSON objectAtIndex:i];
                     
                     PYEvent *event = [PYEvent getEventFromDictionary:eventDic];
                     [eventsArray addObject:event];
                     if (event.attachments.count > 0) {
                         for (int i = 0; i < event.attachments.count; i++) {
                             PYAttachment *attachment = [event.attachments objectAtIndex:i];
                             NSString *fileName = attachment.fileName;
                             [self getAttachmentDataForFileName:fileName
                                                        eventId:event.eventId
                                                    requestType:PYRequestTypeSync
                                                 successHandler:^(NSData *filedata) {
                                                     
                                                     attachment.fileData = filedata;
                                                     [eventsCachingArray replaceObjectAtIndex:i withObject:[event cachingDictionary]];
                                                     
                                                     
                                                 } errorHandler:errorHandler];
                         }
                     }
                 }
                 
                 if (syncAndCache == YES) {
                     [PYEventsCachingUtillity cacheEvents:eventsCachingArray];
                 }
                 if (onlineEventsList) {
                     //cacheEvents method will overwrite contents of currently cached file
                     onlineEventsList([eventsArray autorelease]);
                 }
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

- (void)getAllEventsWithRequestType:(PYRequestType)reqType
                    gotCachedEvents:(void (^) (NSArray *cachedEventList))cachedEvents
                    gotOnlineEvents:(void (^) (NSArray *onlineEventList))onlineEvents
                     successHandler:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
                       errorHandler:(void (^)(NSError *error))errorHandler
{
    //Return current cached events and eventsToAdd, modyfiy, remove (for visual details)
    NSArray *allEventsFromCacheBeforeCacheUpdate = [PYEventsCachingUtillity getEventsFromCache];
    
    if (cachedEvents) {
        NSUInteger currentNumberOfEventsInCache = [PYEventsCachingUtillity getEventsFromCache].count;
        if (currentNumberOfEventsInCache > 0) {
            //if there are cached events return it, when get response return in onlineList
            cachedEvents(allEventsFromCacheBeforeCacheUpdate);
        }
    }
    //This method should retrieve always online events
    //In this method we should synchronize events from cache with ones online and to return current online list
    [self getEventsWithRequestType:reqType
                            filter:nil
                    successHandler:^(NSArray *onlineEventList) {
                        //Cache is updated here with online events
                        //When come here all events(onlineEventList) are already cached
                        //Here some events should be removed from cache (if any)
                        //It doesn't need to be cached because they are already cached just before successHandler is called
                        // TODO UPDATE self.lastRefresh
                        //                            self.lastRefresh = [[NSDate date] timeIntervalSince1970];
                        
                        NSMutableArray *eventsToAdd = [[[NSMutableArray alloc] init] autorelease];
                        NSMutableArray *eventsToRemove = [[[NSMutableArray alloc] init] autorelease];
                        NSMutableArray *eventsModified = [[[NSMutableArray alloc] init] autorelease];
                        
                        [PYEventFilterUtility createEventsSyncDetails:onlineEventList
                                                        offlineEvents:allEventsFromCacheBeforeCacheUpdate
                                                          eventsToAdd:eventsToAdd
                                                       eventsToRemove:eventsToRemove
                                                       eventsModified:eventsModified];
                        if (onlineEvents) {
                            onlineEvents(onlineEventList);
                        }
                        
                        if (syncDetails) {
                            syncDetails(eventsToAdd, eventsToRemove, eventsModified);
                        }
                    }
                      errorHandler:errorHandler
                shouldSyncAndCache:YES];
}

- (void)syncNotSynchedEventsIfAny
{
    NSMutableArray *nonSyncEvents = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncEvents addObjectsFromArray:[self.eventsNotSync allObjects]];
    for (PYEvent *event in nonSyncEvents) {
        
        //if ([event.channelId compare:self.channelId] == NSOrderedSame) {
            //We sync only events for particular channel at time
            
            //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
            event.isSyncTriedNow = YES;
            
            if (event.hasTmpId == YES) {
                
                if (event.notSyncModify || event.notSyncTrashOrDelete) {
                    NSLog(@"event has tmpId and it's mofified or trashed do nothing. If event doesn't have server id it needs to be added to server and that is all what is matter. Modified or trashed or deleted object will update PYEvent object in cache and in unsyncList");
                    
                }
                NSLog(@"event has tmpId and it's added");
                if (event.notSyncAdd) {
                    [self createEvent:event
                          requestType:PYRequestTypeSync
                       successHandler:^(NSString *newEventId, NSString *stoppedId) {
                           
                           //If succedded remove from unsyncSet and add call syncEventWithServer(PTEventFilterUtitliy)
                           //In that method we were search for event with <newEventId> and we should done mapping between server and temp id in cache
                           event.synchedAt = [[NSDate date] timeIntervalSince1970];
                           [self.eventsNotSync removeObject:event];
                           //We have success here. Event is cached in createEvent:requestType: method, remove old event with tmpId from cache
                           //He will always have tmpId here but just in case for testing (defensive programing)
                           [PYEventsCachingUtillity removeEvent:event];
                           
                       } errorHandler:^(NSError *error) {
                           //reset flag if fail, very IMPORTANT
                           event.isSyncTriedNow = NO;
                           NSLog(@"SYNC error: creating event failed");
                       }];
                }
                
            }else{
                NSLog(@"In this case event has server id");
                
                if (event.notSyncModify) {
                    NSLog(@"for modifified unsync events with serverId we have to provide only modified values, not full event object");
                    
                    NSDictionary *modifiedPropertiesDic = event.modifiedEventPropertiesAndValues;
                    PYEvent *modifiedEvent = [[PYEvent alloc] init];
                    modifiedEvent.isSyncTriedNow = YES;
                    
                    [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                        [modifiedEvent setValue:value forKey:property];
                    }];
                    
                    [self setModifiedEventAttributesObject:modifiedEvent
                                                forEventId:event.eventId
                                               requestType:PYRequestTypeSync
                                            successHandler:^(NSString *stoppedId) {
                                                
                                                //We have success here. Event is cached in setModifiedEventAttributesObject:forEventId method
                                                
                                                event.synchedAt = [[NSDate date] timeIntervalSince1970];
                                                [self.eventsNotSync removeObject:event];
                                                
                                            } errorHandler:^(NSError *error) {
                                                modifiedEvent.isSyncTriedNow = NO;
                                                event.isSyncTriedNow = NO;
                                                
                                            }];
                }
                
                if (event.notSyncTrashOrDelete) {
                    [self trashOrDeleteEvent:event
                             withRequestType:PYRequestTypeSync
                              successHandler:^{
                                  
                              } errorHandler:^(NSError *error) {
                                  event.isSyncTriedNow = NO;
                              }];
                }
            }
        //}
    }
}

//POST /{channel-id}/events
- (void)createEvent:(PYEvent *)event
        requestType:(PYRequestType)reqType
     successHandler:(void (^) (NSString *newEventId, NSString *stoppedId))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler
{
    //    event.timeIntervalWhenCreationTried = [[NSDate date] timeIntervalSince1970];
    [self apiRequest:kROUTE_EVENTS
         requestType:reqType
              method:PYRequestMethodPOST
            postData:[event dictionary]
         attachments:event.attachments
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSString *createdEventId = [JSON objectForKey:@"id"];
                 NSString *stoppedId = [JSON objectForKey:@"stoppedId"];
                 
                 //Cache particular event in cache
                 [PYEventsCachingUtillity getAndCacheEventWithServerId:createdEventId
                                                          usingConnection:self
                                                        requestType:reqType];
                 
                 if (successHandler) {
                     successHandler(createdEventId, stoppedId);
                 }
                 
             } failure:^(NSError *error) {
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     
                     if (event.isSyncTriedNow == NO) {
                         //If we didn't try to sync event from unsync list that means that we have to cache that event, otherwise leave it as is
                         event.notSyncAdd = YES;
                         event.time = [[NSDate date] timeIntervalSince1970];
                         event.modified = [NSDate date];
                         //When we try to create event and we came here it have tmpId
                         event.hasTmpId = YES;
                         //this is random id
                         event.eventId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                         //return that created id so it can work offline. Event will be cached when added to unsync list
                         if (event.attachments.count > 0) {
                             for (PYAttachment *attachment in event.attachments) {
                                 //                                     attachment.mimeType = @"mimeType";
                                 attachment.size = [NSNumber numberWithInt:attachment.fileData.length];
                             }
                         }
                         [PYEventsCachingUtillity cacheEvent:event];
                         [self addEvent:event toUnsyncList:error];
                         
                         successHandler (event.eventId, @"");
                         
                     }else{
                         NSLog(@"Event wants to be synchronized on server from unsync list but there is no internet");
                     }
                     
                     
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
                 
             }];
}

- (void)trashOrDeleteEvent:(PYEvent *)event
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS, event.eventId]
         requestType:reqType
              method:PYRequestMethodDELETE
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSLog(@"It's event with server id because we'll never try to call this method if event has tempId");
                 if (successHandler) {
                     successHandler();
                 }
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     if (event.isSyncTriedNow == NO) {
                         
                         event.notSyncTrashOrDelete = YES;
                         event.modified = [NSDate date];
                         
                         if (event.trashed == NO) {
                             event.trashed = YES;
                             [PYEventsCachingUtillity cacheEvent:event];
                         }else{
                             //if event has trashed = yes flag it needs to be deleted from cache
                             [PYEventsCachingUtillity removeEvent:event];
                             [self.eventsNotSync removeObject:event];
                         }
                         
                         
                     }else{
                         NSLog(@"Event with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                     
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
             }];
}

//PUT /{channel-id}/events/{event-id}
- (void)setModifiedEventAttributesObject:(PYEvent *)eventObject
                              forEventId:(NSString *)eventId
                             requestType:(PYRequestType)reqType
                          successHandler:(void (^)(NSString *stoppedId))successHandler
                            errorHandler:(void (^)(NSError *error))errorHandler
{
    
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,eventId]
         requestType:reqType
              method:PYRequestMethodPUT
            postData:[eventObject dictionary]
         attachments:eventObject.attachments
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSString *stoppedId = [JSON objectForKey:@"stoppedId"];
                 
                 //Cache modified event - We cache event
                 NSLog(@"It's event with server id because we'll never try to call this method if event has tempId");
                 //If eventId isn't temporary cache event (it will be overwritten in cache)
                 [PYEventsCachingUtillity getAndCacheEventWithServerId:eventId
                                                       usingConnection:self
                                                           requestType:reqType];
                 
                 if (successHandler) {
                     NSString *stoppedIdToReturn;
                     if (stoppedId.length > 0) {
                         stoppedIdToReturn = stoppedId;
                     }else{
                         stoppedIdToReturn = @"";
                     }
                     successHandler(stoppedIdToReturn);
                 }
                 
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     
                     if (eventObject.isSyncTriedNow == NO) {
                         
                         //Get current event with id from cache
                         PYEvent *currentEventFromCache = [PYEventsCachingUtillity getEventFromCacheWithEventId:eventId];
                         
                         NSLog(@"It's event with server id because we'll never try to call this method if event has tempId");
                         currentEventFromCache.notSyncModify = YES;
                         currentEventFromCache.modified = [NSDate date];
                         
                         NSDictionary *modifiedPropertiesDic = [eventObject dictionary];
                         [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                             [currentEventFromCache setValue:value forKey:property];
                         }];
                         
                         //We have to know what properties are modified in order to make succesfull request
                         currentEventFromCache.modifiedEventPropertiesAndValues = [eventObject dictionary];
                         //We must have cached modified properties of event in cache
                         [PYEventsCachingUtillity cacheEvent:currentEventFromCache];
                         
                         if (successHandler) {
                             NSString *stoppedIdToReturn = @"";
                             successHandler(stoppedIdToReturn);
                         }
                         
                     }else{
                         NSLog(@"Event with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
                 
             }];
}

//POST /{channel-id}/events/start
- (void)startPeriodEvent:(PYEvent *)event
             requestType:(PYRequestType)reqType
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"start"]
         requestType:reqType
              method:PYRequestMethodPOST
            postData:[event dictionary]
         attachments:event.attachments
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSString *startedEventId = [JSON objectForKey:@"id"];
                 
                 if (successHandler) {
                     successHandler(startedEventId);
                 }
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
    
}

//POST /{channel-id}/events/stop
- (void)stopPeriodEventWithId:(NSString *)eventId
                       onDate:(NSDate *)specificTime
                  requestType:(PYRequestType)reqType
               successHandler:(void (^)(NSString *stoppedEventId))successHandler
                 errorHandler:(void (^)(NSError *error))errorHandler
{
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    
    [postData setObject:eventId forKey:@"id"];
    if (specificTime) {
        NSTimeInterval timeInterval = [specificTime timeIntervalSince1970];
        [postData setObject:[NSNumber numberWithDouble:timeInterval] forKey:@"time"];
        
    }
    
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"stop"]
         requestType:reqType
              method:PYRequestMethodPOST
            postData:[postData autorelease]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSString *stoppedEventId = [JSON objectForKey:@"id"];
                 
                 if (successHandler) {
                     successHandler(stoppedEventId);
                 }
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
    
}

//GET /{channel-id}/events/running
- (void)getRunningPeriodEventsWithRequestType:(PYRequestType)reqType
                               successHandler:(void (^)(NSArray *arrayOfEvents))successHandler
                                 errorHandler:(void (^)(NSError *error))errorHandler

{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"running"]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
                 for (NSDictionary *eventDic in JSON) {
                     [eventsArray addObject:[PYEvent getEventFromDictionary:eventDic]];
                 }
                 if (successHandler) {
                     successHandler([eventsArray autorelease]);
                 }
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }
     ];
    
}

- (void)getAttachmentDataForFileName:(NSString *)fileName
                             eventId:(NSString *)eventId
                         requestType:(PYRequestType)reqType
                      successHandler:(void (^) (NSData * filedata))success
                        errorHandler:(void (^) (NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@/%@",kROUTE_EVENTS, eventId ,fileName]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 //In this case this is not JSON object, it's file's NSData
                 success(JSON);
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
    
}

@end
