//
//  PYConnection+DataManagement.h
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYClient.h"
#import "PYConnection.h"
#import "PYEventFilter.h"

@class PYAttachment;

@interface PYConnection (DataManagement)

#pragma mark - Pryv API Streams


- (NSArray*)streamsFromCache;

/**
 @discussion
 Get list of all streams
 
 GET /streams/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYstream objects
 @param filterParams - > Query string parameters (parentId, includeHidden, state ...) They are optional. If you don't filter put nil
 
 */

- (void)streamsFromCache:(void (^) (NSArray *cachedStreamsList))cachedStreams
                    andOnline:(void (^) (NSArray *onlineStreamList))onlineStreams
                        errorHandler:(void (^)(NSError *error))errorHandler;

//This is not supposed to be called directly by client app
/**
 @param shouldSyncAndCache is temporary because web service lack of possibility to get events by id from server
 */

- (void)streamsOnlineWithFilterParams:(NSDictionary *)filter
                         successHandler:(void (^) (NSArray *streamsList))onlineStreamsList
                           errorHandler:(void (^) (NSError *error))errorHandler;

/**
 @discussion
 Create a new stream
 streams have one unique Id AND one unique name. Both must be unique
 
 POST /streams/
 
 */
- (void)streamCreate:(PYStream *)stream
      successHandler:(void (^)(NSString *createdStreamId))successHandler
        errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Trashes or deletes the specified stream, depending on its current state:
 If the stream is not already in the trash, it will be moved to the trash
 If the stream is already in the trash, it will be irreversibly deleted with its possible descendants
 If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter mergeEventsWithParent
 
 @param mergeEventsWithParent:
 mergeEventsWithParent (true or false): Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If true, the linked events will be assigned to the parent of the deleted item; if false, the linked events will be deleted
 
 DELETE /streams/{stream-id}
 */

- (void)streamTrashOrDelete:(PYStream *)stream
        mergeEventsWithParent:(BOOL)mergeEventsWithParents
             successHandler:(void (^)())successHandler
               errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Modify an existing stream Id
 
 PUT /streams/{id}
 
 */
- (void)streamSaveModifiedAttributeFor:(PYStream *)stream
                              forStreamId:(NSString *)streamId
                           successHandler:(void (^)())successHandler
                             errorHandler:(void (^)(NSError *error))errorHandler;

/**
 Get online stream with id from server. This methos mustn't cache stream
 */
- (void)streamOnlineWithId:(NSString *)streamId
               successHandler:(void (^) (PYStream *stream))onlineStream
                 errorHandler:(void (^) (NSError *error))errorHandler;

#pragma mark - Pryv API Events


//This is not supposed to be called directly by client app
/**
 @param shouldSyncAndCache is temporary because web service lack of possibility to get events by id from server
 */
- (void)eventsOnlineWithFilterParameters:(NSDictionary*)filterDic
                        successHandler:(void (^) (NSArray *eventList, NSNumber *serverTime, NSDictionary *details))onlineEventsList
                          errorHandler:(void (^) (NSError *error))errorHandler
                    shouldSyncAndCache:(BOOL)syncAndCache;


- (void)eventsWithFilter:(PYEventFilter *)filter
                 fromCache:(void (^) (NSArray *cachedEventList))cachedEvents
                 andOnline:(void (^) (NSArray *onlineEventList, NSNumber *serverTime))onlineEvents
            onlineDiffWithCached:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
                    errorHandler:(void (^)(NSError *error))errorHandler;

#warning - TODO success should return PYEvent references or clientIds or assume "nil" when not synch online
//POST /events
/** 
  * Records a new event. Events recorded this way must be completed events, i.e. either period events with a known duration or mark events. To start a running period event, post a events/start request. In addition to the usual JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.
  */
- (void)eventCreate:(PYEvent *)event
     successHandler:(void (^)(NSString *newEventId, NSString *stoppedId, PYEvent *event))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 DELETE /events/{event-id}
 Trashes or deletes the specified event, depending on its current state:
 If the event is not already in the trash, it will be moved to the trash (i.e. flagged as trashed)
 If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).
 */
- (void)eventTrashOrDelete:(PYEvent *)event
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler;

//PUT /events/{event-id}
/*Modifies the event's attributes
 All event fields are optional, and only modified properties must be included, for other properties put nil
 @successHandler stoppedId indicates the id of the previously running period event that was stopped as a consequence of modifying the event (if set)
 */
- (void)eventSaveModifications:(PYEvent *)eventObject
     successHandler:(void (^)(NSString *stoppedId))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler;


//POST /events/start
- (void)eventStartPeriod:(PYEvent *)event
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler;

//POST /events/stop
/*Stops a previously running period event
 @param eventId The id of the event to stop
 @param specifiedTime The stop time. Default: now.
 */
- (void)eventStopPeriodWithEventId:(NSString *)eventId
                       onDate:(NSDate *)specificTime
               successHandler:(void (^)(NSString *stoppedEventId))successHandler
                 errorHandler:(void (^)(NSError *error))errorHandler;



/**
 Get attachment NSData for file name and event id
 */
- (void)dataForAttachment:(PYAttachment *)attachment
                  onEvent:(PYEvent *)event
           successHandler:(void (^) (NSData * filedata))success
             errorHandler:(void (^) (NSError *error))errorHandler;

/**
 Get preview NSData (jpg image) for event id
 */
- (void)previewForEvent:(PYEvent *)event
         successHandler:(void (^) (NSData * content))success
            errorHandler:(void (^) (NSError *error))errorHandler;


@end
