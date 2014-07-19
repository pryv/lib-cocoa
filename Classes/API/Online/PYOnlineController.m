//
//  PYOnlineController.m
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import "PYOnlineController.h"

@implementation PYOnlineController

@synthesize connection = _connection;

- (id) initWithConnection:(PYConnection*) connection {
    self = [super init];
    if (self) {
        self.connection = connection;
    }
    return self;
}

@end
