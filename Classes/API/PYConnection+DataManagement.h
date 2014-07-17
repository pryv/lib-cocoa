//
//  PYConnection+DataManagement.h
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYClient.h"
#import "PYConnection.h"
#import "PYFilter.h"


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


@end
