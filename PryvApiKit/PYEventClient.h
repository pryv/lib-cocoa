//
//  PYEventClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEventClient : NSObject


// ---------------------------------------------------------------------------------------------------------------------
// @name Event operations
// ---------------------------------------------------------------------------------------------------------------------


/**
 @discussion
 On PrYv, Events are sent as JSON Data parameters. Single event can have files attached to them.
 Events can be of differents types.
 See http://dev.pryv.com/event-types.html
 http://dev.pryv.com/standard-structure.html

 Send an position event with one or more attachments
 
 POST /{channel-id}/events/
 
 @param event to send attachments to Api set the attachmentList propery of Event: NSArray of EventAttachment
 
 @see Event
 @see EventAttachment
 */
//- (void)sendEvent:(PYEvent *)event
//withSuccessHandler:(void(^)(void))successHandler
//     errorHandler:(void(^)(NSError *error))errorHandler;


/**
 @discussion
 get events between two dates, pass nil to both @param startDate and @param endDate to get the last 24h
 pass nil to @param folderId to get events from all folders in the current channel Id
 
 GET /{channel-id}/events/
 
 */
- (void)getEventsFromStartDate:(NSDate *)startDate
                     toEndDate:(NSDate *)endDate
                    inFolderId:(NSString *)folderId
                successHandler:(void (^)(NSArray *eventList))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler;

@end
