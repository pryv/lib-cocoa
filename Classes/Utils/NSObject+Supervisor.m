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

+ (NSMutableDictionary *)liveObjectDictionary {
    if (! s_liveObjectDictionary) {
        s_liveObjectDictionary = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
    }
    return s_liveObjectDictionary;
}

+ (id)liveObjectForSupervisableKey:(NSString *)supervisableKey {
    NSDictionary *liveObjDict = [self liveObjectDictionary];
    [lock lock];
    NSValue *liveObj = [(NSValue *)[liveObjDict objectForKey:supervisableKey] nonretainedObjectValue];
    [lock unlock];
    return liveObj;
}

- (void)superviseOut {
    id<PYSupervisable> supervisableSelf = (id<PYSupervisable>)self;
    NSMutableDictionary *liveObjDict = [[self class] liveObjectDictionary];
    [liveObjDict removeObjectForKey:[supervisableSelf supervisableKey]];
}

- (void)superviseIn {
    id<PYSupervisable> supervisableSelf = (id<PYSupervisable>)self;
    NSMutableDictionary *liveObjDict = [[self class] liveObjectDictionary];
    id zeroed = [NSValue valueWithNonretainedObject:self];
    NSString* key = [supervisableSelf supervisableKey];
    [lock lock];
    [liveObjDict setObject:zeroed forKey:key];
    [lock unlock];
}

@end
