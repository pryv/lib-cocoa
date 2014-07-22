//
//  PYConnection+FetchedStreams.m
//  Pods
//
//  Created by Perki on 04.04.14.
//
//

#import "PYConnection+FetchedStreams.h"
#import "PYStream+Utils.h"
#import "PYCachingController+Streams.h"

@implementation PYConnection (FetchedStreams)

/**
 * READING
 *
 * fetched streams dictionnary contains all the streams used in the lifecycle of the app
 * even deleted once.. We may implement some cleanup, but this is mainly to be threadsafe
 * as the content is never reseted.
 *
 */


/** return true if streams have been fetched **/
- (BOOL)hasFetchedStreams {
    return _fetchedStreamsMap != nil;
}

/** return the stream instance corresponding to this streamId or streamsCLientId **/
- (PYStream*)streamWithStreamId:(NSString*)streamId {
    if (! _fetchedStreamsMap) {
        NSLog(@"<WARNING> fetch streams before being able to use [event stream] or use event.streamId property");
        return nil;
    }
    return [_fetchedStreamsMap objectForKey:streamId];
}

/** update fetched Streams with a list of Streams **/
- (void) updateFetchedStreamsMap {
    NSMutableDictionary* newMap = [[NSMutableDictionary alloc] init];
    [PYStream fillNSDictionary:newMap withStreamsStructure:self.fetchedStreamsRoots];
    self.fetchedStreamsMap = newMap;
    [newMap autorelease];
}

/** cache fetched Streams **/
- (void) addToFetchedStreams:(PYStream*)stream {
    if (! _fetchedStreamsRoots) {
        NSLog(@"<WARNING> cannot add stream to an empty fetched Stream List");
        return;
    }
    if (stream.parentId == nil) {
        NSMutableArray* newRoots = [[[NSMutableArray alloc] initWithArray:self.fetchedStreamsRoots] autorelease];
        [newRoots addObject:stream];
        self.fetchedStreamsRoots = newRoots;
        
    } else { // fin the parent and attach
        PYStream* parent = [self streamWithStreamId:stream.parentId];
        if (! parent) {
            NSLog(@"<WARNING> failed to find parent stream with id: %@", stream.parentId);
        } else {
            [parent addChildren:stream];
        }
    }
    [self updateFetchedStreamsMap];
}


/** cache fetched Streams **/
- (void) cacheFetchedStreams {
    if (! _fetchedStreamsRoots) {
        NSLog(@"<WARNING> cannot save an empty fetched Stream List");
        return;
    }
    return [self.cache cachePYStreams:self.fetchedStreamsRoots];
}


@end
