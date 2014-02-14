//
//  PYEvent+Supervisor.h
//  PryvApiKit
//
//  Created by Perki on 07.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEvent (Supervisor)

+ (NSMutableDictionary*) eventsDic;

+ (PYEvent*) liveEventForClientId:(NSString*)clientId;

- (void) superviseOut;

- (void) superviseIn;


@end
