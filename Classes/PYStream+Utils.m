//
//  PYStream+Utils.m
//  Pods
//
//  Created by Perki on 04.04.14.
//
//

#import "PYStream+Utils.h"

@implementation PYStream (Utils)



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


@end
