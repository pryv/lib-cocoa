//
//  PYConnection+DataManagement.h
//  PryvApiKit
//
//  Created by Victor Kristof on 14.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYConnection (DataManagement)

/**
 @discussion
 Gets the accessible streams
 
 GET /streams/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYChannel objects
 @param filterParams  Query string parameters (state ...) Optional. If you don't filter put nil Example : state=all
 @param successHandler A block object to be executed when the operation finishes successfully.
 @param errorHandler   NSError object if some error occurs
 */

- (void)getAllStreamsWithRequestType:(PYRequestType)reqType
                    gotCachedStreams:(void (^) (NSArray *cachedStreamList))cachedStreams
                    gotOnlineStreams:(void (^) (NSArray *onlineStreamList))onlineStreams
                        errorHandler:(void (^)(NSError *error))errorHandler;


- (void)getStreamsWithRequestType:(PYRequestType)reqType
                           filter:(NSDictionary*)filterDic
                   successHandler:(void (^) (NSArray *streamsList))onlineStreamList
                     errorHandler:(void (^)(NSError *error))errorHandler;



@end
