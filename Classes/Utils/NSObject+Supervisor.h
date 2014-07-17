//
//  NSObject+Supervisor.h
//  Pods
//
//  Created by Konstantin Dorodov on 21.03.2014.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Supervisor)

+ (id)liveObjectForSupervisableKey:(NSString *)supervisableKey;

- (void)superviseOut;

- (void)superviseIn;

@end
