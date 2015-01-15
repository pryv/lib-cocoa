//
//  NSObject+Supervisor.m
//  Pods
//
//  Created by Konstantin Dorodov on 21.03.2014.
//
//

#import "NSObject+Supervisor.h"
#import "PYSupervisable.h"

@implementation NSObject (Supervisor)

static NSMutableDictionary *s_liveObjectDictionary;
static NSLock *lock;

+ (void)setup {
    if (! s_liveObjectDictionary) {
        s_liveObjectDictionary = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
    }
}

+ (id)liveObjectForSupervisableKey:(NSString *)supervisableKey {
    [self setup];
    [lock lock];
    NSValue *liveObj = [(NSValue *)[s_liveObjectDictionary objectForKey:supervisableKey] nonretainedObjectValue];
    [lock unlock];
    return liveObj;
}

- (void)superviseOut {
     [[self class] setup];
    [s_liveObjectDictionary removeObjectForKey:[(id<PYSupervisable>)self supervisableKey]];
}

- (void)superviseIn {
    [[self class] setup];
    [self retain];
    id zeroed = [NSValue valueWithNonretainedObject:self];
    [lock lock];
    [s_liveObjectDictionary setObject:zeroed forKey:[(id<PYSupervisable>)self supervisableKey]];
    [lock unlock];
    [self release];
}

@end
