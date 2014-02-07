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

static NSMutableDictionary* _eventsDic;


+ (NSMutableDictionary*) eventsDic {
    if (! _eventsDic) {
        _eventsDic = [[NSMutableDictionary alloc] init];
    }
    return _eventsDic;
}

+ (PYEvent*) liveEventForClientId:(NSString*)clientId {
    return [[PYEvent eventsDic] objectForKey:clientId];
}


- (void) superviseOut {
    [[PYEvent eventsDic] removeObjectForKey:self.clientId];
}

- (void) superviseIn {
    [[PYEvent eventsDic] setObject:self forKey:self.clientId];
}


@end
