//
//  PYStream+Utils.m
//  Pods
//
//  Created by Perki on 04.04.14.
//
//

#import "PYStream+Utils.h"



@implementation PYStream (Utils)



/**
 * StreamIds of all children, including this stream
 */
- (NSArray*)descendantsIds{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [PYStream fillNSMutableArray:result withIdAndChildrensIdsOf:self];
    return [result autorelease];
}


- (void)addChildren:(PYStream*)stream {
    NSMutableArray* newChildren = [[[NSMutableArray alloc] init] autorelease];
    if (self.children) {
        [newChildren addObjectsFromArray:self.children];
    }
    [newChildren addObject:stream];
    self.children = newChildren;
}

+ (void)fillNSMutableArray:(NSMutableArray*)array withIdAndChildrensIdsOf:(PYStream*)stream {
    [array addObject:stream.streamId];
    if (stream.children) {
        for (PYStream *child in stream.children) {
         [self fillNSMutableArray:array withIdAndChildrensIdsOf:child];
        }
    }
}


// --- static utils

+ (void)fillNSDictionary:(NSMutableDictionary*)dict withStreamsStructure:(NSArray*)rootStreams
{
    for (PYStream* stream in rootStreams) {
        if (stream.streamId == nil) {
            NSLog(@"<WARNING> PYStream.fillNSDictionary trying to set a stream with no id");
        } else {
            if ([dict objectForKey:stream.streamId] == nil) {
                [dict setValue:stream forKey:stream.streamId];
            }
            if (stream.children) {
                [self fillNSDictionary:dict withStreamsStructure:stream.children];
            }
        }
    }
}

+ (PYStream*)findStreamMatchingId:(NSString*)streamId orNames:(NSArray*)namesList onList:(NSArray*)streamsList
{
    // look for id
    for (PYStream* stream in streamsList) {
        if ([streamId isEqualToString:stream.streamId]) {
            return stream;
        }
    }
    // look for names
    for (NSString* name in namesList) {
        for (PYStream* stream in streamsList) {
            if (stream.name && NSOrderedSame == [name caseInsensitiveCompare:stream.name]) {
                return stream;
            }
        }
    }
    return nil;
}




@end
