//
//  PYStreamManagerProtocol.h
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import <Foundation/Foundation.h>

@class PYStream;

@protocol PYStreamManagerProtocol <NSObject>

- (void)streamSaveModifications:(PYStream *)streamObject
                successHandler:(void (^)(PYStream *stream))successHandler
                  errorHandler:(void (^)(NSError *error))errorHandler;

@end
