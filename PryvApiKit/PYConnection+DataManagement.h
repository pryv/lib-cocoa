//
//  PYConnection+DataManagement.h
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYConnection (DataManagement)

/**
 @discussion
 Gets the accessible streams
 
 GET /streams/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYChannel objects
 @param filterParams  Query string parameters (state ...) Optional. If you don't filter put nil Example : state=all
 @param successHandler A block object to be executed when the operation finishes successfully.
 @param errorHandler   NSError object if some error occurs
 */

- (void)getAllStreamsWithRequestType:(PYRequestType)reqType
                    gotCachedStreams:(void (^) (NSArray *cachedStreamList))cachedStreams
                    gotOnlineStreams:(void (^) (NSArray *onlineStreamList))onlineStreams
                        errorHandler:(void (^)(NSError *error))errorHandler;


- (void)getStreamsWithRequestType:(PYRequestType)reqType
                           filter:(NSDictionary*)filterDic
                   successHandler:(void (^) (NSArray *streamsList))onlineStreamList
                     errorHandler:(void (^)(NSError *error))errorHandler;

/**
 Sync all streams from list
 */
- (void)syncNotSynchedStreamsIfAny;


/**
 @discussion
 Create a new stream
 streams have one unique Id AND one unique name. Both must be unique
 
 POST /{channel-id}/folders/
 
 */
- (void)createStream:(PYStream *)stream
     withRequestType:(PYRequestType)reqType
      successHandler:(void (^)(NSString *createdStreamId))successHandler
        errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Trashes or deletes the specified stream, depending on its current state:
 If the stream is not already in the trash, it will be moved to the trash
 If the stream is already in the trash, it will be irreversibly deleted with its possible descendants
 If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter mergeEventsWithParent
 
 @param filterParams:
 mergeEventsWithParent (true or false): Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If true, the linked events will be assigned to the parent of the deleted item; if false, the linked events will be deleted
 
 DELETE /{channel-id}/folders/{folder-id}
 */

- (void)trashOrDeleteStream:(PYStream *)stream
                     filterParams:(NSDictionary *)filter
                  withRequestType:(PYRequestType)reqType
                   successHandler:(void (^)())successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Modify an existing stream Id
 
 PUT /{channel-id}/folders/{id}
 
 */
- (void)setModifiedStreamAttributesObject:(PYStream *)stream
                              forStreamId:(NSString *)streamId
                              requestType:(PYRequestType)reqType
                           successHandler:(void (^)())successHandler
                             errorHandler:(void (^)(NSError *error))errorHandler;

/**
 Get online stream with id from server. This methos mustn't cache stream
 */
- (void)getOnlineStreamWithId:(NSString *)streamId
                  requestType:(PYRequestType)reqType
               successHandler:(void (^) (PYStream *stream))onlineStream
                 errorHandler:(void (^) (NSError *error))errorHandler;



@end
