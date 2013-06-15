//
//  Channel.m
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYChannel.h"
#import "PYFolder+JSON.h"
#import "PYEvent.h"
#import "PYEventsCachingUtillity.h"
#import "PYConstants.h"
#import "PYEventFilterUtility.h"

@implementation PYChannel

@synthesize access = _access;
@synthesize channelId = _channelId;
@synthesize name = _name;
@synthesize timeCount = _timeCount;
@synthesize clientData = _clientData;
@synthesize enforceNoEventsOverlap = _enforceNoEventsOverlap;
@synthesize trashed = _trashed;

- (void)dealloc
{
    [_access release];
    [_channelId release];
    [_name release];
    [_clientData release];
    [super dealloc];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.id=%@", self.channelId];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.clientData=%@", self.clientData];
    [description appendFormat:@", self.enforceNoEventsOverlap=%d", self.enforceNoEventsOverlap];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendString:@">"];
    return description;
}

- (void)syncNotSynchedEventsIfAny
{
    NSMutableArray *nonSyncEvents = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncEvents addObjectsFromArray:[self.access.eventsNotSync allObjects]];
    for (PYEvent *event in nonSyncEvents) {
        
        if ([event.channelId compare:self.channelId] == NSOrderedSame) {
            //We sync only events for particular channel at time
            
            //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
            event.isSyncTriedNow = YES;
            
            /*Ako event ima tmpId i ako je modified ili trashedOrDeleted prvo to izvrsi nad trenutnim kesiranim objektima pa uradi create*/
            if (event.hasTmpId == YES) {
                
                if (event.notSyncModify || event.notSyncTrashOrDelete) {
                    NSLog(@"event has tmpId and it's mofified or trashed do nothing. If event doesn't have server id it needs to be added to server and that is all what is matter. Modified or trashed or deleted object will update PYEvent object in cache and in unsyncList");
                    
                }else{
                    NSLog(@"event has tmpId and it's added");
                    if (event.notSyncAdd) {
                        [self createEvent:event
                              requestType:PYRequestTypeSync
                           successHandler:^(NSString *newEventId, NSString *stoppedId) {
                               
                               //If succedded remove from unsyncSet and add call syncEventWithServer(PTEventFilterUtitliy)
                               //In that method we were search for event with <newEventId> and we should done mapping between server and temp id in cache
                               event.synchedAt = [[NSDate date] timeIntervalSince1970];
                               [self.access.eventsNotSync removeObject:event];
                               //We have success here. Event is cached in createEvent:requestType: method, remove old event with tmpId from cache
                                //He will always have tmpId here but just in case for testing (defensive programing)
                                [PYEventsCachingUtillity removeEvent:event];
                               
                           } errorHandler:^(NSError *error) {
                               //reset flag if fail, very IMPORTANT
                               event.isSyncTriedNow = NO;
                               NSLog(@"SYNC error: creating event failed");
                           }];
                    }
                }
                
            }else{
                NSLog(@"In this case event has server id");
                
                if (event.notSyncModify) {
                    [self setModifiedEventAttributesObject:event
                                                forEventId:event.eventId
                                               requestType:PYRequestTypeSync
                                            successHandler:^(NSString *stoppedId) {
                                                
                        event.synchedAt = [[NSDate date] timeIntervalSince1970];
                        [self.access.eventsNotSync removeObject:event];
                        
                        //We have success here. Event is cached in setModifiedEventAttributesObject:forEventId method
                        
                        if (event.hasTmpId == NO) {
                            NSLog(@"do nothing, it is server id and event is overwritten in cache");
                            //If event has server id do nothing because it's already overwritten in cache with new modified event data in setModifiedEventAttributesObject:forEventId method
                        }                       
                        
                    } errorHandler:^(NSError *error) {
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
        }        
    }
}

- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler {
    
    if (path == nil) path = @"";
    NSString* newPath = [NSString stringWithFormat:@"%@/%@", self.channelId, path];
    [self.access apiRequest:newPath requestType:reqType method:method postData:postData attachments:attachments success:successHandler failure:failureHandler];
}

#pragma mark - Events manipulation

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
        It should retrieve always online events for this channel and need to cache (sync) online events (before caching sync unsyched, because we don't want to loose ynsuc changes)
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
                 for (NSDictionary *eventDic in JSON) {
                     [eventsArray addObject:[PYEvent getEventFromDictionary:eventDic]];
                 }
                 if (onlineEventsList) {
                     //cacheEvents method will overwrite contents of currently cached file
                     if (syncAndCache == YES) {
                         [PYEventsCachingUtillity cacheEvents:JSON];
                     }
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
                            onlineEvents(onlineEventList);
                            syncDetails(eventsToAdd, eventsToRemove, eventsModified);
                        }
                          errorHandler:errorHandler shouldSyncAndCache:YES];
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
                     [PYEventFilterUtility getAndCacheEventWithServerId:createdEventId
                                                              inChannel:self
                                                            requestType:reqType];
                     
                     if (successHandler) {
                         successHandler(createdEventId, stoppedId);
                     }
                                          
                 } failure:^(NSError *error) {
                     if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                         
                         if (event.isSyncTriedNow == NO) {
                             //If we didn't try to sync event from unsync list that means that we have to cache that event, otherwise leave it as is
                             event.channelId = self.channelId;
                             event.notSyncAdd = YES;
                             event.time = [[NSDate date] timeIntervalSince1970];
                             event.modified = [NSDate date];
                             //When we try to create event and we came here it have tmpId
                             event.hasTmpId = YES;
                             //this is random id
                             event.eventId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                             //return that created id so it can work offline. Event will be cached when added to unsync list
                             
                             [self.access addEvent:event toUnsyncList:error];
                             [PYEventsCachingUtillity cacheEvent:event];
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
                 [PYEventFilterUtility getAndCacheEventWithServerId:eventId
                                                          inChannel:self
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
                         NSLog(@"It's event with server id because we'll never try to call this method if event has tempId");
                         eventObject.notSyncModify = YES;
                         eventObject.modified = [NSDate date];
                         eventObject.channelId = self.channelId;
                         //When we try to modify event and we came here there can be two possibilities
                         if (eventObject.hasTmpId == NO) {
                             //We have cached online event and we try to modify it
                             eventObject.hasTmpId = NO;
                         }else{
                             //We didn't cache online event and we try to modify it (unsync one)
                             eventObject.hasTmpId = YES;
                         }
                         
                             
                         [PYEventsCachingUtillity cacheEvent:eventObject];
                         [self.access addEvent:eventObject toUnsyncList:error];

                     }else{
                         NSLog(@"Event with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                 }

                 if (errorHandler) {
                     errorHandler (error);
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
                 
                 //Here we delete event on server
                 //If we deleted event when we were offline he's in unsync list i.e. we got net and we call this method in batchSyncEventsWithoutAttachment
                 //For event to get deleted we sync events with getAllEventsWithRequestType:eventsToAdd:eventsToRemove or getEventsWithRequestType:eventsToAdd:eventsToRemove. This should be done at the end when server is updated
                 //getAllEventsWithRequestType will recognize that event isn't on server and he will remove it from cache (or will set flag trashed=YES)
                 
                 //If we modified event we were online:
                 //call synceventWithServer:(NSString *)eventId (update cache for that event) eventId = eventObject.eventId

                 if (successHandler) {
                     successHandler();
                 }
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     
                     event.notSyncTrashOrDelete = YES;
                     event.modified = [NSDate date];
                     event.channelId = self.channelId;
                     //When we try to trash/delete event and we came here there can be two possibilities
                     if (event.hasTmpId == NO) {
                         //We have cached online event and we try to trash/delete it
                         event.hasTmpId = NO;
                     }else{
                         //We didn't cache online event and we try to trash/delete it (unsync one)
                         event.hasTmpId = YES;
                     }

                     [self.access addEvent:event toUnsyncList:error];

                 }

                 if (errorHandler) {
                     errorHandler (error);
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

#pragma mark - PrYv API Folder get all (GET /{channel-id}/folders/)

- (void)getFoldersWithRequestType:(PYRequestType)reqType
                     filterParams:(NSDictionary *)filter
                   successHandler:(void (^)(NSArray *folderList))successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler;
{
 
    [self apiRequest:[PYClient getURLPath:kROUTE_FOLDERS withParams:filter]
             requestType:reqType
                  method:PYRequestMethodGET
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSMutableArray *folderList = [[NSMutableArray alloc] init];
                         for (NSDictionary *folderDictionary in JSON) {
                             PYFolder *folderObject = [PYFolder folderFromJSON:folderDictionary];
                             [folderList addObject:folderObject];
                         }
                         if (successHandler) {
                             successHandler([folderList autorelease]);
                         }
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
}


#pragma mark - PrYv API Folder create (POST /{channel-id}/folders/)

- (void)createFolderWithId:(NSString *)folderId
                      name:(NSString *)folderName
                  parentId:(NSString *)parentId
                  isHidden:(BOOL)hidden
          customClientData:(NSDictionary *)clientData
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)(NSString *createdFolderId))successHandler
              errorHandler:(void (^)(NSError *error))errorHandler
{
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:folderId forKey:@"id"];
    [postData setObject:folderName forKey:@"name"];
    [postData setObject:self.channelId forKey:@"channelId"];
        
    if (parentId) {
        [postData setObject:parentId forKey:@"parentId"];
    }
    
    if (clientData) {
        [postData setObject:clientData forKey:@"clientData"];
    }
    
    [postData setObject:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
    
    [self apiRequest:kROUTE_FOLDERS
             requestType:reqType
                  method:PYRequestMethodPOST
                postData:[postData autorelease]
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSString *createdFolderId = [JSON objectForKey:@"id"];
                         if (successHandler) {
                             successHandler(createdFolderId);
                         }
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
    
}


#pragma mark - PrYv API Folder modify (PUT /{channel-id}/folders/{folder-id})

- (void)modifyFolderWithId:(NSString *)folderId
                      name:(NSString *)newfolderName
                  parentId:(NSString *)newparentId
                  isHidden:(BOOL)hidden
          customClientData:(NSDictionary *)clientData
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler
{
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    if (newfolderName) {
        [postData setObject:newfolderName forKey:@"name"];
    }
        
    if (newparentId) {
        [postData setObject:newparentId forKey:@"parentId"];
    }
    
    if (clientData) {
        [postData setObject:clientData forKey:@"clientData"];
    }
    
    [postData setObject:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
        
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_FOLDERS,  folderId]
             requestType:reqType
                  method:PYRequestMethodPUT
                postData:[postData autorelease]
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

#pragma mark - PrYv API Folder delet (DELETE /{channel-id}/folders/{folder-id})

- (void)trashOrDeleteFolderWithId:(NSString *)folderId
                     filterParams:(NSDictionary *)filter
                  withRequestType:(PYRequestType)reqType
                   successHandler:(void (^)())successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[PYClient getURLPath:[NSString stringWithFormat:@"%@/%@",kROUTE_FOLDERS, folderId] withParams:filter]
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


@end
