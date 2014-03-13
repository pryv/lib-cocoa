//
//  PYStream+Supervisor.m
//  Pods
//
//  Created by Konstantin Dorodov on 13.03.2014.
//
//

#import "PYStream+Supervisor.h"

@implementation PYStream (Supervisor)

static NSMutableDictionary *s_streamsDic;


+ (NSMutableDictionary *)streamsDic {
    if (! s_streamsDic) {
        s_streamsDic = [[NSMutableDictionary alloc] init];
    }
    return s_streamsDic;
}

+ (PYStream *)liveStreamForClientId:(NSString *)clientId {
    return [(NSValue *)[[PYStream streamsDic] objectForKey:clientId] nonretainedObjectValue];
}


- (void) superviseOut {
    [[PYStream streamsDic] removeObjectForKey:self.clientId];
}

- (void) superviseIn {
    [[PYStream streamsDic] setObject:[NSValue valueWithNonretainedObject:self] forKey:self.clientId];
}
@end
