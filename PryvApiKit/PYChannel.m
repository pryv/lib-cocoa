//
//  Channel.m
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYChannel.h"
#import "PYStream+JSON.h"
#import "PYEvent.h"
#import "PYEventsCachingUtillity.h"
#import "PYConstants.h"
#import "PYEventFilterUtility.h"
#import "PYStreamsCachingUtillity.h"

@implementation PYChannel

@synthesize connection = _connection;
@synthesize channelId = _channelId;
@synthesize name = _name;
@synthesize timeCount = _timeCount;
@synthesize clientData = _clientData;
@synthesize enforceNoEventsOverlap = _enforceNoEventsOverlap;
@synthesize trashed = _trashed;

- (void)dealloc
{
    [_connection release];
    [_channelId release];
    [_name release];
    [_clientData release];
    [super dealloc];
}

- (void)syncNotSynchedStreamsIfAny
{
    NSMutableArray *nonSyncFolders = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncFolders addObjectsFromArray:[self.connection.streamsNotSync allObjects]];
    for (PYStream *folder in nonSyncFolders) {
        
        //the condition is not correct : set self.channelId to shut error up, should be parentId
        if ([folder.parentId compare:self.channelId] == NSOrderedSame) {
            //We sync only events for particular channel at time
            
            //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
            folder.isSyncTriedNow = YES;
            
            if (folder.hasTmpId) {
                
                if (folder.notSyncModify) {
                    NSLog(@"folder has tmpId and it's mofified -> do nothing. If folder doesn't have server id it needs to be added to server and that is all what is matter. Modified object will update PYFolder object in cache and in unsyncList");
                    
                }
                NSLog(@"folder has tmpId and it's added");
                if (folder.notSyncAdd) {
                    
                    [self createFolder:folder
                       withRequestType:PYRequestTypeSync
                        successHandler:^(NSString *createdFolderId) {
                            //If succedded remove from unsyncSet and add call syncFolderWithServer
                            //In that method we were search for folder with <createdFolderId> and we should done mapping between server and temp id in cache
                            folder.synchedAt = [[NSDate date] timeIntervalSince1970];
                            [self.connection.streamsNotSync removeObject:folder];
                            //We have success here. Folder is cached in createFolder:withRequestType: method, remove old folder with tmpId from cache
                            //He will always have tmpId here but just in case for testing (defensive programing)
                            [PYStreamsCachingUtillity removeStream:folder];

                        } errorHandler:^(NSError *error) {
                            folder.isSyncTriedNow = NO;
                            NSLog(@"SYNC error: creating folder failed");
                        }];                    
                }
                
            }else{
                NSLog(@"In this case folder has server id");
                
                if (folder.notSyncModify) {
                    NSLog(@"for modifified unsync folders with serverId we have to provide only modified values, not full event object");
                    
                    NSDictionary *modifiedPropertiesDic = folder.modifiedStreamPropertiesAndValues;
                    PYStream *modifiedFolder = [[PYStream alloc] init];
                    modifiedFolder.isSyncTriedNow = YES;
                    
                    [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                        [modifiedFolder setValue:value forKey:property];
                    }];
                    
                    [self setModifiedFolderAttributesObject:modifiedFolder forFolderId:folder.streamId requestType:PYRequestTypeSync successHandler:^{
                        
                        //We have success here. Folder is cached in setModifiedFolderAttributesObject:forFolderId method
                        folder.synchedAt = [[NSDate date] timeIntervalSince1970];
                        [self.connection.streamsNotSync removeObject:folder];
                        
                    } errorHandler:^(NSError *error) {
                        modifiedFolder.isSyncTriedNow = NO;
                        folder.isSyncTriedNow = NO;
                    }];
                }
            }
        }        
    }
}

- (void)syncNotSynchedEventsIfAny
{
    NSMutableArray *nonSyncEvents = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncEvents addObjectsFromArray:[self.connection.eventsNotSync allObjects]];
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
                           [self.connection.eventsNotSync removeObject:event];
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
                        [self.connection.eventsNotSync removeObject:event];
                        
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
        // }
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
    [self.connection apiRequest:newPath requestType:reqType method:method postData:postData attachments:attachments success:successHandler failure:failureHandler];
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

- (void)getOnlineFolderWithId:(NSString *)folderId
                 requestType:(PYRequestType)reqType
              successHandler:(void (^) (PYStream *folder))onlineFolder
                errorHandler:(void (^) (NSError *error))errorHandler
{
    //Method below automatically cache (overwrite) all folders from this channel, so this is bad
    //When API support separate method of getting only one folder by its id this will be implemneted here
    
    //This method should get particular folder and return it, not to cache it
    
    [self getFoldersWithRequestType:reqType
                       filterParams:nil
                     successHandler:^(NSArray *foldersList) {
                         for (PYStream *currentFolder in foldersList) {
                             if ([currentFolder.streamId compare:folderId] == NSOrderedSame) {
                                 onlineFolder(currentFolder);
                                 break;
                             }
                         }

    } errorHandler:errorHandler
                 shouldSyncAndCache:NO];
    
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
//                     [PYEventFilterUtility getAndCacheEventWithServerId:createdEventId
//                                                              inChannel:self
//                                                            requestType:reqType];
                     
                     if (successHandler) {
                         successHandler(createdEventId, stoppedId);
                     }
                                          
                 } failure:^(NSError *error) {
                     if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                         
                         if (event.isSyncTriedNow == NO) {
                             //If we didn't try to sync event from unsync list that means that we have to cache that event, otherwise leave it as is
                             //event.channelId = self.channelId;
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
                             [self.connection addEvent:event toUnsyncList:error];

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
//                 [PYEventFilterUtility getAndCacheEventWithServerId:eventId
//                                                          inChannel:self
//                                                        requestType:reqType];
                 
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
                             [self.connection.eventsNotSync removeObject:event];
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

#pragma mark - PrYv API Folder get all (GET /{channel-id}/folders/)


- (void)getFoldersWithRequestType:(PYRequestType)reqType
                     filterParams:(NSDictionary *)filter
                   successHandler:(void (^) (NSArray *foldersList))onlineFoldersList
                     errorHandler:(void (^) (NSError *error))errorHandler
               shouldSyncAndCache:(BOOL)syncAndCache
{
    /*
     This method musn't be called directly (it's api support method). This method works ONLY in ONLINE mode
     This method doesn't care about current cache, it's interested in online folders only
     It should retrieve always online folders for this channel and need to cache (sync) online folders (before caching sync unsyched folders, because we don't want to loose unsync changes)
     */
    
    /*if there are folders that are not synched with server, they need to be synched first and after that cached
     This method must be SYNC not ASYNC and this method sync folders with server and cache them
     */
    if (syncAndCache == YES) {
        [self syncNotSynchedStreamsIfAny];
    }
    
    [self apiRequest:[PYClient getURLPath:kROUTE_FOLDERS withParams:filter]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 NSMutableArray *folderList = [[NSMutableArray alloc] init];
                 for (NSDictionary *folderDictionary in JSON) {
                     [folderList addObject:[PYStream streamFromJSON:folderDictionary]];
                 }
                 
                 if (syncAndCache == YES) {
                     [PYStreamsCachingUtillity cacheStreams:JSON];
                 }

                 if (onlineFoldersList) {
                     //cacheEvents method will overwrite contents of currently cached file
                     onlineFoldersList([folderList autorelease]);
                 }
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
    

}

- (void)getAllFoldersWithRequestType:(PYRequestType)reqType
                        filterParams:(NSDictionary *)filter
                    gotCachedFolders:(void (^) (NSArray *cachedFoldersList))cachedFolders
                    gotOnlineFolders:(void (^) (NSArray *onlineFolderList))onlineFolders
                        errorHandler:(void (^)(NSError *error))errorHandler
{
    
    //Return current cached folders
    NSArray *allFoldersFromCache = [PYStreamsCachingUtillity getStreamsFromCache];
//    [allFoldersFromCache makeObjectsPerformSelector:@selector(setAccess:) withObject:self.access];
    if (cachedFolders) {
        NSUInteger currentNumberOfFoldersInCache = allFoldersFromCache.count;
        if (currentNumberOfFoldersInCache > 0) {
            //if there are cached folders return it, when get response return in onlineList
            cachedFolders(allFoldersFromCache);
        }
    }
    
    [self getFoldersWithRequestType:reqType filterParams:filter successHandler:^(NSArray *foldersList) {
        if (onlineFolders) {
            onlineFolders(foldersList);
        }
    }
                       errorHandler:errorHandler
                 shouldSyncAndCache:YES];
}


#pragma mark - PrYv API Folder create (POST /{channel-id}/folders/)

- (void)createFolder:(PYStream *)folder
     withRequestType:(PYRequestType)reqType
      successHandler:(void (^)(NSString *createdFolderId))successHandler
        errorHandler:(void (^)(NSError *error))errorHandler;
{
    [self apiRequest:kROUTE_FOLDERS
             requestType:reqType
                  method:PYRequestMethodPOST
                postData:[folder dictionary]
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSString *createdFolderId = [JSON objectForKey:@"id"];
                         if (successHandler) {
                             successHandler(createdFolderId);
                         }
                     
//                     [PYStreamsCachingUtillity getAndCacheStreamWithServerId:createdFolderId
//                                                                   inParent:self
//                                                                 requestType:reqType];
                     [PYStreamsCachingUtillity getAndCacheStream:folder withServerId:createdFolderId requestType:reqType];

                     
                     } failure:^(NSError *error) {
                         if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                             if (folder.isSyncTriedNow == NO) {
                                 //If we didn't try to sync folder from unsync list that means that we have to cache that folder, otherwise leave it as is
                                 //folder.channelId = self.channelId; SHOULD NOT BE COMMENTED, should use parentId
                                 folder.notSyncAdd = YES;
                                 //When we try to create folder and we came here it has tmpId
                                 folder.hasTmpId = YES;
                                 //this is random id
                                 folder.streamId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                                 //return that created id so it can work offline. Folder will be cached when added to unsync list
                                 
                                 [PYStreamsCachingUtillity cacheStream:folder];
                                 [self.connection addStream:folder toUnsyncList:error];
                                 
                                 successHandler (folder.streamId);
                                 
                             }else{
                                 NSLog(@"Folder wants to be synchronized on server from unsync list but there is no internet");
                             }

                         }else{
                             if (errorHandler) {
                                 errorHandler (error);
                             }
                         }
                     }];
    
}


#pragma mark - PrYv API Folder modify (PUT /{channel-id}/folders/{folder-id})

- (void)setModifiedFolderAttributesObject:(PYStream *)folderObject
                              forFolderId:(NSString *)folderId
                              requestType:(PYRequestType)reqType
                           successHandler:(void (^)())successHandler
                             errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_FOLDERS,folderId]
         requestType:reqType
              method:PYRequestMethodPUT
            postData:[folderObject dictionary]
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                  
                 //Cache modified folder - We cache folder
                 NSLog(@"It's folder with server id because we'll never try to call this method if folder has tempId");
                 //If folderId isn't temporary cache folder (it will be overwritten in cache)
//                 [PYStreamsCachingUtillity getAndCacheStreamWithServerId:folderId
//                                                               inParent:self
//                                                             requestType:reqType];
                 
                 if (successHandler) {
                     successHandler();
                 }
                 
             } failure:^(NSError *error) {
                 
                 if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                     
                     if (folderObject.isSyncTriedNow == NO) {
                         
                         //Get current folder with id from cache
                         PYStream *currentFolderFromCache = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:folderId];
                         
                         currentFolderFromCache.notSyncModify = YES;
                         
                         NSDictionary *modifiedPropertiesDic = [folderObject dictionary];
                         [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                             [currentFolderFromCache setValue:value forKey:property];
                         }];
                         
                         //We have to know what properties are modified in order to make succesfull request
                         currentFolderFromCache.modifiedStreamPropertiesAndValues = [folderObject dictionary];
                         //We must have cached modified properties of folder in cache
                         [PYStreamsCachingUtillity cacheStream:currentFolderFromCache];
                         
                         if (successHandler) {
                             successHandler();
                         }
                         
                     }else{
                         NSLog(@"Folder with server id wants to be synchronized on server from unsync list but there is no internet");
                     }
                 }else{
                     if (errorHandler) {
                         errorHandler (error);
                     }
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
