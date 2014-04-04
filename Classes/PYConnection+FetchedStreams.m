//
//  PYConnection+FetchedStreams.m
//  Pods
//
//  Created by Perki on 04.04.14.
//
//

#import "PYConnection+FetchedStreams.h"
#import "PYStream+Utils.h"

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
    return _fetchedStreams != nil;
}

/** return the stream instance corresponding to this streamId or streamsCLientId **/
- (PYStream*)streamWithStreamId:(NSString*)streamId {
    if (! _fetchedStreams) {
        NSLog(@"<WARNING> fetch streams before being able to use [event stream] or use event.streamId property");
        return nil;
    }
    return [_fetchedStreams objectForKey:streamId];
}

/** update fetched Streams with a list of Streams **/
- (void) updateFetchedStreams:(NSArray*)streams {
    if (! _fetchedStreams) {
        _fetchedStreams = [[NSMutableDictionary alloc] init];
    }
    [PYStream fillNSDictionary:_fetchedStreams withStreamsStructure:streams];
    
}


@end
