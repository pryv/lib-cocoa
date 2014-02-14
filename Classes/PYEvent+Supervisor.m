//
//  PYEvent+Supervisor.m
//  PryvApiKit
//
//  Created by Perki on 07.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYEvent.h"
#import "PYEvent+Supervisor.h"

@implementation PYEvent (Supervisor)

static NSMutableDictionary* s_eventsDic;


+ (NSMutableDictionary*)eventsDic {
    if (! s_eventsDic) {
        s_eventsDic = [[NSMutableDictionary alloc] init];
    }
    return s_eventsDic;
}

+ (PYEvent*) liveEventForClientId:(NSString*)clientId {
    return [(NSValue*)[[PYEvent eventsDic] objectForKey:clientId] nonretainedObjectValue];
}


- (void) superviseOut {
    [[PYEvent eventsDic] removeObjectForKey:self.clientId];
}

- (void) superviseIn {
    [[PYEvent eventsDic] setObject:[NSValue valueWithNonretainedObject:self] forKey:self.clientId];
}


@end
