//
//  PYOnlineController.h
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import <Foundation/Foundation.h>

@class PYConnection;


@interface PYOnlineController : NSObject

// assign to avoid reference counting
@property (nonatomic, assign) PYConnection *connection;

- (id) initWithConnection:(PYConnection*) connection;



@end
