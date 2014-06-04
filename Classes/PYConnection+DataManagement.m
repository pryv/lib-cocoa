//
//  PYConnection+DataManagement.m
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYConnection+DataManagement.h"
#import "PYConnection+TimeManagement.h"
#import "PYConnection+FetchedStreams.h"
#import "PYStream+JSON.h"
#import "PYEventFilterUtility.h"
#import "PYEvent.h"
#import "PYEvent+Sync.h"
#import "PYEvent+JSON.h"
#import "PYAttachment.h"
#import "PYCachingController+Event.h"
#import "PYCachingController+Stream.h"



@interface PYConnection ()

- (void) eventFromReceivedDictionary:(NSDictionary*) eventDic
                              create:(void(^) (PYEvent*event))create
                              update:(void(^) (PYEvent*event))update
                                same:(void(^) (PYEvent*event))same;

@end


@implementation PYConnection (DataManagement)

#pragma mark - Pryv API Streams


- (NSArray*)streamsFromCache {
    NSArray *allStreamsFromCache = [self.cache allStreamsFromCache];
    for (PYStream* stream in  allStreamsFromCache) {
        [self streamAndChildrenSetConnection:stream];
    }
    return allStreamsFromCache;
}


- (void)streamsFromCache:(void (^) (NSArray *cachedStreamsList))cachedStreams
               andOnline:(void (^) (NSArray *onlineStreamList))onlineStreams
            errorHandler:(void (^)(NSError *error))errorHandler
{
    //Return current cached streams
    
    
    NSArray* allStreamsFromCache = [self streamsFromCache];
    
    if (cachedStreams) {
        NSUInteger currentNumberOfStreamsInCache = allStreamsFromCache.count;
        if (currentNumberOfStreamsInCache > 0) {
            //if there are cached streams return it, when get response return in onlineList
            cachedStreams(allStreamsFromCache);
        }
    }
    
    [self streamsOnlineWithFilterParams:nil successHandler:^(NSArray *streamsList) {
        if (onlineStreams) {
            onlineStreams(streamsList);
        }
    }
                           errorHandler:errorHandler];
}



- (void)streamsOnlineWithFilterParams:(NSDictionary *)filter
                       successHandler:(void (^) (NSArray *streamsList))onlineStreamsList
                         errorHandler:(void (^) (NSError *error))errorHandler
{
    /*
     This method musn't be called directly (it's api support method). This method works ONLY in ONLINE mode
     This method doesn't care about current cache, it's interested in online streams only
     It should retrieve always online streams and need to cache (sync) online streams (before caching sync unsyched stream, because we don't want to lose unsync changes)
     */
    
    
    BOOL syncAndCache = (filter == nil);
    /*if there are streams that are not synched with server, they need to be synched first and after that cached
     This method must be SYNC not ASYNC and this method sync streams with server and cache them
     */
    if (syncAndCache == YES) {
        [self syncNotSynchedStreamsIfAny];
    }
    
    [self apiRequest:[PYClient getURLPath:kROUTE_STREAMS withParams:filter]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *resultDict) {
                 NSArray *JSON = resultDict[kPYAPIResponseStreams];
                 
                 NSMutableArray *streamList = [[[NSMutableArray alloc] init] autorelease];
                 for (NSDictionary *streamDictionary in JSON) {
                     PYStream *stream = [PYStream streamFromJSON:streamDictionary];
                     [self streamAndChildrenSetConnection:stream];
                     [streamList addObject:stream];
                 }
                 
                 
                 //---- save the streams in the fetchedStream object
                 if (filter == nil) { // It is a new version of RootStreams
                     self.fetchedStreamsRoots = streamList;
                 }
                 [self updateFetchedStreamsMap];
                 [self cacheFetchedStreams];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationStreams
                                                                     object:self
                                                                   userInfo:nil];
                 
                 if (onlineStreamsList) {
                     //cacheEvents method will overwrite contents of currently cached file
                     onlineStreamsList(streamList);
                     
                 }
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

- (void)streamOnlineWithId:(NSString *)streamId
            successHandler:(void (^) (PYStream *stream))onlineStreamHandler
              errorHandler:(void (^) (NSError *error))errorHandler
{
    //Method below automatically cache (overwrite) all streams, so this is bad
    //When API support separate method of getting only one stream by its id this will be implemented here
    
    //This method should get particular stream and return it, not to cache it
    [self streamsOnlineWithFilterParams:nil successHandler:^(NSArray *streamsList) {
        __block BOOL found = NO;
        for (PYStream *currentStream in streamsList) {
            if ([currentStream.streamId isEqualToString:streamId]) {
                found = YES;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationStreams
                                                                    object:self
                                                                  userInfo:nil];
                
                if (onlineStreamHandler) {
                    onlineStreamHandler(currentStream);
                }
                break;
            }
        }
        if (!found) {
            if (onlineStreamHandler) {
                onlineStreamHandler(nil);
            }
        }
    } errorHandler:errorHandler];
}

/**
 * Utility to set connection to all Streams
 * @private
 */
- (void)streamAndChildrenSetConnection:(PYStream *)stream
{
    [stream setConnection:self];
    if (stream.children != nil) {
        for (int i = 0; i < stream.children.count; i++) {
            [self streamAndChildrenSetConnection:[stream.children objectAtIndex:i]];
        }
    }
}

- (void)streamCreate:(PYStream *)stream
      successHandler:(void (^)(NSString *createdStreamId))successHandler
        errorHandler:(void (^)(NSError *error))errorHandler;
{
    /**
     if (stream.streamId != nil) {
     @throw [NSException exceptionWithName:@"SDKCannotcreateStream"
     reason:@"Stream has already a StreamId" userInfo:nil];
     }**/
    
    if (stream.connection == nil) {
        stream.connection = self;
    } else if (stream.connection != self) {
        @throw [NSException exceptionWithName:@"SDKCannotcreateStream"
                                       reason:@"Cannot create stream on a different connection" userInfo:nil];
    }
    
    
    stream.connection = self;
    
    [self apiRequest:kROUTE_STREAMS
         requestType:PYRequestTypeAsync
              method:PYRequestMethodPOST
            postData:[stream dictionary]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 NSDictionary* streamDict = responseDict[kPYAPIResponseStream];
                 NSString *createdStreamId = [streamDict objectForKey:@"id"];
                 
                 stream.streamId = createdStreamId;
                 [stream resetFromDictionary:streamDict];
                 
                 // attach to parent
                 [self addToFetchedStreams:stream];
                 [self cacheFetchedStreams];
                 
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationStreams
                                                                     object:self
                                                                   userInfo:nil];
                 if (successHandler) {
                     successHandler(createdStreamId);
                 }
             } failure:^(NSError *error) {
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     return errorHandler([NSError errorWithDomain:@"pryv" code:500 userInfo:@{@"message" : @"Offline creation of streams not yet supported"}]);
                     
#pragma warning stream caching has to be reviewed
                     
                     if (stream.isSyncTriedNow == NO) {
                         //If we didn't try to sync stream from unsync list that means that we have to cache that stream, otherwise leave it as is
                         //stream.Id = self.Id; SHOULD NOT BE COMMENTED, should use parentId ?
                         stream.notSyncAdd = YES;
                         //When we try to create stream and we came here it has tmpId
                         stream.hasTmpId = YES;
                         //this is random id
                         stream.streamId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                         //return that created id so it can work offline. Stream will be cached when added to unsync list
                         
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

-(void)streamTrashOrDelete:(PYStream *)stream
     mergeEventsWithParent:(BOOL)mergeEventsWithParents
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *))errorHandler
{
    [self apiRequest:[PYClient getURLPath:[NSString stringWithFormat:@"%@/%@",kROUTE_STREAMS, stream.streamId] withParams:@{@"mergeEventsWithParents":  [NSNumber numberWithBool:mergeEventsWithParents]}]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodDELETE
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseValue) {
                 if (successHandler) {
                     successHandler();
                 }
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

- (void)streamSaveModifiedAttributeFor:(PYStream *)stream
                           forStreamId:(NSString *)streamId
                        successHandler:(void (^)())successHandler
                          errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_STREAMS,streamId]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodPUT
            postData:[stream dictionary]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseValue) {
                 
                 
                 [self cacheFetchedStreams];
                 
                 if (successHandler) {
                     successHandler();
                 }
                 
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     
                     if (stream.isSyncTriedNow == NO) {
                         
                         
                         //We have to know what properties are modified in order to make succesfull request
                         stream.modifiedStreamPropertiesAndValues = [stream dictionary];
                         //We must have cached modified properties of stream in cache
                         
                         [self cacheFetchedStreams];
                         
                         if (successHandler) {
                             successHandler();
                         }
                     } else {
                         NSLog(@"Stream with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
                 
             }];
}



#pragma mark - Pryv API Events



- (void)eventsWithFilter:(PYFilter *)filter
               fromCache:(void (^) (NSArray *cachedEventList))cachedEvents
               andOnline:(void (^) (NSArray *onlineEventList, NSNumber *serverTime))onlineEvents
    onlineDiffWithCached:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
            errorHandler:(void (^)(NSError *error))errorHandler
{
    
    
    //Return current cached events and eventsToAdd, modyfiy, remove (for visual details)
    
#warning - we should remove the dispatch as soon as event is faster
    dispatch_async(dispatch_get_main_queue(), ^{
        
       
        NSArray *eventsFromCache = [self allEventsFromCache];
       
        
        
        __block NSArray *filteredCachedEventList = [PYEventFilterUtility filterEventsList:eventsFromCache
                                                                               withFilter:filter];
        
        
        
#warning - check that retain ... without it was crashing in the subblock ..
        [filteredCachedEventList retain];
        
       
        if (cachedEvents) {
            if ([eventsFromCache count] > 0) {
                //if there are cached events return it, when get response return in onlineList
                cachedEvents(filteredCachedEventList);
            }
        }
        
        //This method should retrieve always online events
        //In this method we should synchronize events from cache with ones online and to return current online list
        [self eventsOnlineWithFilter:filter
                      successHandler:^(NSArray *onlineEventList, NSNumber *serverTime, NSDictionary *details) {
                          NSDate *afx3 = [NSDate date];
                          if (onlineEvents) {
                              onlineEvents(onlineEventList, serverTime);
                          }
                          NSLog(@"*afx3 A %f", [afx3 timeIntervalSinceNow]);

                          if (syncDetails) {
                              // give differences between cachedEvents and received events
                              
                              NSMutableSet *intersection = [NSMutableSet setWithArray:filteredCachedEventList];
                              [intersection intersectSet:[NSSet setWithArray:onlineEventList]];
                              NSMutableArray *removeArray = [NSMutableArray arrayWithArray:[intersection allObjects]];
                              
                              [PYEventFilterUtility sortNSMutableArrayOfPYEvents:removeArray sortAscending:YES];
                              
                              syncDetails([details objectForKey:kPYNotificationKeyAdd], removeArray,
                                          [details objectForKey:kPYNotificationKeyModify]);
                              filteredCachedEventList = nil;
                          }
                           NSLog(@"*afx3 B %f", [afx3 timeIntervalSinceNow]);
                      }
                        errorHandler:errorHandler
                  shouldSyncAndCache:YES];
    });
}



//GET /events

- (void)eventsOnlineWithFilter:(PYFilter*)filter
                successHandler:(void (^) (NSArray *eventList, NSNumber *serverTime, NSDictionary *details))successBlock
                  errorHandler:(void (^) (NSError *error))errorHandler
            shouldSyncAndCache:(BOOL)syncAndCache
{
    /*
     This method musn't be called directly (it's api support method). This method works ONLY in ONLINE mode
     This method doesn't care about current cache, it's interested in online events only
     It should retrieve always online events and need to cache (sync) online events (before caching sync unsyched, because we don't want to loose unsuc changes)
     */
    
    /*if there are events that are not synched with server, they need to be synched first and after that cached
     This method must be SYNC not ASYNC and this method sync events with server and cache them
     */
    if (syncAndCache == YES) {
# warning - change logic
        //  [self syncNotSynchedEventsIfAny];
    }
    
    // shush if filter.onlyStreamIds = []
    if (filter && filter.onlyStreamsIDs && ([filter.onlyStreamsIDs count] == 0)) {
        NSLog(@"<WARNING> skipping online request filter.onlyStreamsIDs is empty");
        if (successBlock) {
            successBlock(@[], nil, @{kPYNotificationKeyAdd: @[],
                                     kPYNotificationKeyModify: @[],
                                     kPYNotificationKeyUnchanged: @[]});
        }
        return;
    }
    
    [self apiRequest:[PYClient getURLPath:kROUTE_EVENTS
                               withParams:[PYEventFilterUtility apiParametersForEventsRequestFromFilter:filter]]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 
                 NSDate* afx2 = [NSDate date];
                 
                 NSArray *JSON = responseDict[kPYAPIResponseEvents];
                 
                 NSMutableArray *eventsArray = [[[NSMutableArray alloc] init] autorelease];
                 __block NSMutableArray* addArray = [[[NSMutableArray alloc] init] autorelease];
                 __block NSMutableArray* modifyArray = [[[NSMutableArray alloc] init] autorelease];
                 __block NSMutableArray* sameArray = [[[NSMutableArray alloc] init] autorelease];
                 
                 for (int i = 0; i < [JSON count]; i++) {
                     NSDictionary *eventDic = [JSON objectAtIndex:i];
                     
                     __block PYEvent* myEvent;
                     [self eventFromReceivedDictionary:eventDic
                                                create:^(PYEvent *event) {
                                                    myEvent = event;
                                                    [addArray addObject:event];
                                                } update:^(PYEvent *event) {
                                                    myEvent = event;
                                                    [modifyArray addObject:event];
                                                } same:^(PYEvent *event) {
                                                    myEvent = event;
                                                    [sameArray addObject:event];
                                                }];
                     
                     [eventsArray addObject:myEvent];
                 }
                 
                 NSLog(@"*afx2 A %f", [afx2 timeIntervalSinceNow]);
                 
                 [self.cache saveAllEvents];
                 //cacheEvents method will overwrite contents of currently cached file
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:eventsArray sortAscending:YES];
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:addArray sortAscending:YES];
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:modifyArray sortAscending:YES];
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:sameArray sortAscending:YES];
                 
                 NSDictionary* details = @{kPYNotificationKeyAdd: addArray,
                                           kPYNotificationKeyModify: modifyArray,
                                           kPYNotificationKeyUnchanged: sameArray};
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                     object:self
                                                                   userInfo:@{kPYNotificationKeyAdd: addArray,
                                                                              kPYNotificationKeyModify: modifyArray,
                                                                              kPYNotificationKeyUnchanged: sameArray,
                                                                              kPYNotificationWithFilter: filter}];
                 if (successBlock) {
                     NSDictionary* meta = [responseDict objectForKey:@"meta"];
                     NSNumber* serverTime = [meta objectForKey:@"serverTime"];
                     successBlock(eventsArray, serverTime, details);
                     
                 }
                  NSLog(@"*afx2 B %f", [afx2 timeIntervalSinceNow]);
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void) eventFromReceivedDictionary:(NSDictionary*) eventDic
                              create:(void(^) (PYEvent*event))create
                              update:(void(^) (PYEvent*event))update
                                same:(void(^) (PYEvent*event))same
{
    PYEvent* cachedEvent = [self.cache eventWithEventId:[eventDic objectForKey:@"id"]];
    if (cachedEvent == nil) // cache event
    {
        PYEvent *event = [PYEvent eventFromDictionary:eventDic onConnection:self];
        [self.cache cacheEvent:event addSaveCache:NO];
        // notify of event creation
        create(event);
        return;
    }
    cachedEvent.connection = self;
    
    // eventId is already known.. same event or modified ?
    NSNumber *modified = [eventDic objectForKey:@"modified"];
    if ([modified doubleValue] <= cachedEvent.modified) { // cached win
        same(cachedEvent);
        return;
    }
    [cachedEvent resetFromDictionary:eventDic];
    // notify of event update
    [self.cache cacheEvent:cachedEvent addSaveCache:NO];
    
    update(cachedEvent);
}

#pragma clang diagnostic pop
//POST /events
- (void)eventCreate:(PYEvent *)event
     successHandler:(void (^) (NSString *newEventId, NSString *stoppedId, PYEvent *event))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler
{
    
    if (event.connection == nil) {
        event.connection = self;
    }
    if (event.connection != self)
    {
        return errorHandler([NSError
                             errorWithDomain:@"Cannot create PYEvent on API with an different connection"
                             code:500 userInfo:nil]);
    }
    
    
    
    // load filedata in attachment from cache if needed
    if (event.attachments) {
        for (PYAttachment* att in event.attachments) {
            if (! att.fileData || att.fileData.length == 0) {
                [self.cache dataForAttachment:att onEvent:event];
            }
        }
    }
    
    
    
    [self apiRequest:kROUTE_EVENTS
         requestType:PYRequestTypeAsync
              method:PYRequestMethodPOST
            postData:[event dictionary]
         attachments:event.attachments
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 NSDictionary* JSON = responseDict[kPYAPIResponseEvent];
                 
                 NSString *createdEventId = [JSON objectForKey:@"id"];
                 NSString *stoppedId = [JSON objectForKey:@"stoppedId"];
                 
#warning Hack until we get server time for untimed envent
                 if (event.eventDate == nil) {
                     [event setEventDate:[NSDate date]]; // now
                 }
                 
                 //--
                 [event resetFromDictionary:JSON];
                 
                 
                 event.synchedAt = [[NSDate date] timeIntervalSince1970];
                 event.eventId = createdEventId;
                 [event clearModifiedProperties]; // clear modified properties
                 [self.cache cacheEvent:event andCleanTempData:YES]; //-- remove eventual
                 
                 // notification
                 
                 // event is synchonized.. this mean it is already known .. so we advertise a modification..
                 NSString* notificationKey = event.isSyncTriedNow ? kPYNotificationKeyModify : kPYNotificationKeyAdd;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                     object:self
                                                                   userInfo:@{notificationKey: @[event]}];
                 
                 if (successHandler) {
                     successHandler(createdEventId, stoppedId, event);
                 }
                 
                 
             } failure:^(NSError *error) {
                 if (event.isSyncTriedNow == YES) {
                     NSLog(@"Event wants to be synchronized on server from unsync list but there is no internet %@", error);
                     
                     if (successHandler) {
                         successHandler (nil, @"", event);
                     }
                     
                     return ;
                 }
                 
                 //If we didn't try to sync event from unsync list that means that we have to cache that event, otherwise leave it as is
                 
                 if ([event eventDate] == nil) {
                     [event setEventDate:[NSDate date]]; // now
                 }
                 
                 //When we try to create event and we came here it have tmpId
                 
                 //return that created id so it can work offline. Event will be cached when added to unsync list
                 if (event.attachments.count > 0) {
                     for (PYAttachment *attachment in event.attachments) {
                         //  attachment.mimeType = @"mimeType";
                         attachment.size = [NSNumber numberWithUnsignedInteger:attachment.fileData.length];
                     }
                 }
                 [self.cache cacheEvent:event];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                     object:self
                                                                   userInfo:@{kPYNotificationKeyAdd: @[event]}];
                 
                 if (successHandler) {
                     successHandler (nil, @"", event);
                 }
             }
     
     ];
}

- (void)eventTrashOrDelete:(PYEvent *)event
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler
{
    
    
    
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS, event.eventId]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodDELETE
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseValue) {
                 
                 if (event.trashed == YES) {
                     [self.cache removeEvent:event];
                 } else {
                     event.trashed = YES;
                     [self.cache cacheEvent:event];
                 }
                 
                 NSLog(@"It's event with server id because we'll never try to call this method if event has tempId");
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                     object:self
                                                                   userInfo:@{kPYNotificationKeyDelete: @[event]}];
                 
                 if (successHandler) {
                     successHandler();
                 }
                 
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     if (event.isSyncTriedNow == NO) {
                         
                         if (event.trashed == NO) {
                             event.trashed = YES;
                             [self.cache cacheEvent:event];
                         }else{
                             //if event has trashed = yes flag it needs to be deleted from cache
                             [self.cache removeEvent:event];
                         }
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                             object:self
                                                                           userInfo:@{kPYNotificationKeyDelete: @[event]}];
                         if (successHandler) {
                             successHandler();
                         }
                         return;
                         
                     } else {
                         NSLog(@"Event with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                 }
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

//PUT /events/{event-id}

- (void)eventSaveModifications:(PYEvent *)eventObject
                successHandler:(void (^)(NSString *stoppedId))successHandler
                  errorHandler:(void (^)(NSError *error))errorHandler
{
    
    
    [eventObject compareAndSetModifiedPropertiesFromCache];
    
#warning - attachments should be updated asside..
    
    [self apiRequest:[NSString stringWithFormat:@"%@/%@", kROUTE_EVENTS, eventObject.eventId]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodPUT
            postData:[eventObject dictionaryForUpdate]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 NSDictionary *JSON = responseDict[kPYAPIResponseEvent];
                 NSString *stoppedId = [JSON objectForKey:@"stoppedId"];
                 
                 eventObject.synchedAt = [[NSDate date] timeIntervalSince1970];
                 [eventObject clearModifiedProperties];
                 [self.cache cacheEvent:eventObject ];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                     object:self
                                                                   userInfo:@{kPYNotificationKeyModify: @[eventObject]}];
                 
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
                 
                 
                 if (eventObject.isSyncTriedNow == NO) {
                     //Get current event with id from cache
                     [self.cache cacheEvent:eventObject];
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                         object:self
                                                                       userInfo:@{kPYNotificationKeyModify: @[eventObject]}];
                     
                     if (successHandler) {
                         NSString *stoppedIdToReturn = @"";
                         successHandler(stoppedIdToReturn);
                         return ;
                     }
                     
                 }
                 
                 
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }
     
     ];
}

//POST /events/start
- (void)eventStartPeriod:(PYEvent *)event
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"start"]
         requestType:PYRequestTypeAsync
              method:PYRequestMethodPOST
            postData:[event dictionary]
         attachments:event.attachments
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 NSDictionary* JSON = responseDict[kPYAPIResponseEvent];
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

//POST /events/stop
- (void)eventStopPeriodWithEventId:(NSString *)eventId
                            onDate:(NSDate *)specificTime
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
         requestType:PYRequestTypeAsync
              method:PYRequestMethodPOST
            postData:[postData autorelease]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 NSString *stoppedEventId = responseDict[@"stoppedId"];
                 
                 if (successHandler) {
                     successHandler(stoppedEventId);
                 }
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
    
}

# pragma mark - event attachment


- (void)dataForAttachment:(PYAttachment *)attachment
                  onEvent:(PYEvent *)event
           successHandler:(void (^) (NSData * filedata))success
             errorHandler:(void (^) (NSError *error))errorHandler
{
    
    //---- got it from cache
    
    NSData *cachedData = [self.cache dataForAttachment:attachment onEvent:event];
    if (cachedData && cachedData.length > 0) {
        success(cachedData);
        return;
    }
    
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kROUTE_EVENTS, event.eventId, attachment.attachmentId];
    NSString *urlPath = [path stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    
    NSString* fullPath = [NSString stringWithFormat:@"%@://%@%@:%@/%@", self.apiScheme, self.userID, self.apiDomain, @(self.apiPort), urlPath];
    
    NSURL *url = [NSURL URLWithString:fullPath];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setValue:self.accessToken forHTTPHeaderField:@"Authorization"];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 60.0f;
    
    [PYClient sendRAWRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSMutableData *result) {
        if (success) {
            NSLog(@"*66 %@ %@", @([result length]), url);
            success(result);
            
            attachment.fileData = result;
            [self.cache saveDataForAttachment:attachment onEvent:event];
        }
    } failure:errorHandler];
}

- (void)previewForEvent:(PYEvent *)event
         successHandler:(void (^) (NSData * content))success
           errorHandler:(void (^) (NSError *error))errorHandler
{
    
    
    //---- got it from cache
    
    NSData *cachedData = [self.cache previewForEvent:event];
    if (cachedData) {
        if (success) { success(cachedData);}
        return;
    }
    
    if (! event.eventId) {
        if (success) { success(nil);}
        return;
    }
    
    
    
    NSString *path = [NSString stringWithFormat:@"%@/%@?w=512",kROUTE_EVENTS, event.eventId];
    NSString *urlPath = [path stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    
    
    NSString* fullPath = [NSString stringWithFormat:@"%@://%@%@:%i/%@", self.apiScheme, self.userID, self.apiDomain, 3443, urlPath];
    
    NSURL *url = [NSURL URLWithString:fullPath];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setValue:self.accessToken forHTTPHeaderField:@"Authorization"];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 60.0f;
    
    [PYClient sendRAWRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSMutableData *result) {
        if (success) {
            NSLog(@"*77 %@ %@", @([result length]), url);
            [self.cache savePreview:result forEvent:event];
            success(result);
            
        }
    } failure:^(NSError *error) {
        errorHandler(error);
        
    }];
}


@end
