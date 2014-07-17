//
//  PYConnection+Streams.m
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import "PYConnection+Streams.h"
#import "PYConnection+TimeManagement.h"
#import "PYConnection+FetchedStreams.h"
#import "PYConnection+Synchronization.h"
#import "PYStream+JSON.h"
#import "PYCachingController+Stream.h"
#import "PYClient+Utils.h"
#import "PYErrorUtility.h"
#import "PYConstants.h"

@implementation PYConnection (Streams)

#pragma mark - Pryv API Streams


- (NSArray*)streamsFromCache {
    NSArray *allStreamsFromCache = [self.cache allStreams];
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



@end
