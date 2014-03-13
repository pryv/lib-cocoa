//
//  PYStream+Supervisor.h
//  Pods
//
//  Created by Konstantin Dorodov on 13.03.2014.
//
//

#import "PYStream.h"

@interface PYStream (Supervisor)

+ (NSMutableDictionary *)streamsDic;

+ (PYStream *)liveStreamForClientId:(NSString *)clientId;

- (void)superviseOut;

- (void)superviseIn;

@end
