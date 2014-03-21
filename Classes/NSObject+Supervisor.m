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

+ (NSMutableDictionary *)liveObjectDictionary {
    if (! s_liveObjectDictionary) {
        s_liveObjectDictionary = [[NSMutableDictionary alloc] init];
    }
    return s_liveObjectDictionary;
}

+ (id)liveObjectForSupervisableKey:(NSString *)supervisableKey {
    NSDictionary *liveObjDict = [self liveObjectDictionary];
    return [(NSValue *)[liveObjDict objectForKey:supervisableKey] nonretainedObjectValue];
}

- (void)superviseOut {
    id<PYSupervisable> supervisableSelf = (id<PYSupervisable>)self;
    NSMutableDictionary *liveObjDict = [[self class] liveObjectDictionary];
    [liveObjDict removeObjectForKey:[supervisableSelf supervisableKey]];
}

- (void)superviseIn {
    id<PYSupervisable> supervisableSelf = (id<PYSupervisable>)self;
    NSMutableDictionary *liveObjDict = [[self class] liveObjectDictionary];
    [liveObjDict setObject:[NSValue valueWithNonretainedObject:self]
                    forKey:[supervisableSelf supervisableKey]];
}

@end
