//
//  PYOnlineController+Events.m
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import "PYConnection.h"
#import "PYConnection+Events.h"
#import "PYAPIConstants.h"
#import "PYkNotifications.h"
#import "PYEvent.h"
#import "PYFilter.h"
#import "PYClient+Utils.h"
#import "PYEventFilterUtility.h"
#import "PYOnlineController+Events.h"
#import "PYCachingController+Events.h"

@implementation PYOnlineController (Events)

- (void) eventsGetWithFilter:(PYFilter*)filter
                 successHandler:(void (^) (NSArray *eventList, NSNumber *serverTime, NSDictionary *details))successBlock
                   errorHandler:(void (^) (NSError *error))errorHandler {
    
    // shush if filter.onlyStreamIds = []
    if (filter && filter.onlyStreamsIDs && ([filter.onlyStreamsIDs count] == 0)) {
        if (successBlock) {
            successBlock(@[], nil, @{kPYNotificationKeyAdd: @[],
                                     kPYNotificationKeyModify: @[],
                                     kPYNotificationKeyUnchanged: @[]});
        }
        return;
    }
    
    
    [self.connection apiRequest:[PYClient getURLPath:kROUTE_EVENTS
                                          withParams:[PYEventFilterUtility apiParametersForEventsRequestFromFilter:filter]]
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                 
                 NSDate* afx2 = [NSDate date];
                 
                 NSArray *JSON = responseDict[kPYAPIResponseEvents];
                 
                 NSMutableArray *eventsArray = [[[NSMutableArray alloc] init] autorelease];
                 __block NSMutableArray* addArray = [[[NSMutableArray alloc] init] autorelease];
                 __block NSMutableArray* modifyArray = [[[NSMutableArray alloc] init] autorelease];
                 __block NSMutableArray* sameArray = [[[NSMutableArray alloc] init] autorelease];
                 
                 for (int i = 0; i < [JSON count]; i++) {
                     NSDictionary *eventDic = [JSON objectAtIndex:i];
                     
                     __block PYEvent* myEvent;
                     [self.connection eventCreateOrReuseFromDictionary:eventDic
                                                create:^(PYEvent *event) {
                                                    myEvent = event;
                                                    [addArray addObject:event];
                                                } update:^(PYEvent *event) {
                                                    myEvent = event;
                                                    [modifyArray addObject:event];
                                                } same:^(PYEvent *event) {
                                                    myEvent = event;
                                                    [sameArray addObject:event];
                                                }];
                     
                     [eventsArray addObject:myEvent];
                 }
                 [self.connection.cache saveAllEvents];
                 
                 NSLog(@"*afx2 A %f", [afx2 timeIntervalSinceNow]);
                 
                 //cacheEvents method will overwrite contents of currently cached file
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:eventsArray sortAscending:YES];
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:addArray sortAscending:YES];
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:modifyArray sortAscending:YES];
                 [PYEventFilterUtility sortNSMutableArrayOfPYEvents:sameArray sortAscending:YES];
                 
                 NSDictionary* details = @{kPYNotificationKeyAdd: addArray,
                                           kPYNotificationKeyModify: modifyArray,
                                           kPYNotificationKeyUnchanged: sameArray};
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPYNotificationEvents
                                                                     object:self.connection
                                                                   userInfo:@{kPYNotificationKeyAdd: addArray,
                                                                              kPYNotificationKeyModify: modifyArray,
                                                                              kPYNotificationKeyUnchanged: sameArray,
                                                                              kPYNotificationWithFilter: filter}];
                 if (successBlock) {
                     NSDictionary* meta = [responseDict objectForKey:@"meta"];
                     NSNumber* serverTime = [meta objectForKey:@"serverTime"];
                     successBlock(eventsArray, serverTime, details);
                     
                 }
                 NSLog(@"*afx2 B %f", [afx2 timeIntervalSinceNow]);
                 
             } failure:^(NSError *error) {
                 if (errorHandler) {
                     errorHandler (error);
                 }
             }];
}

/**
 * Records a new event. Events recorded this way must be completed events, i.e. either period events with a known duration or mark events. To start a running period event, post a events/start request. In addition to the usual JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.
 */
- (void)eventCreate:(PYEvent *)event
     successHandler:(void (^)(NSString *newEventId, NSString *stoppedId, PYEvent *event))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler {
    
}

/**
 @discussion
 DELETE /events/{event-id}
 Trashes or deletes the specified event, depending on its current state:
 If the event is not already in the trash, it will be moved to the trash (i.e. flagged as trashed)
 If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).
 */
- (void)eventTrashOrDelete:(PYEvent *)event
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler {
    
}

//PUT /events/{event-id}
/*Modifies the event's attributes
 All event fields are optional, and only modified properties must be included, for other properties put nil
 @successHandler stoppedId indicates the id of the previously running period event that was stopped as a consequence of modifying the event (if set)
 */
- (void)eventSaveModifications:(PYEvent *)eventObject
                successHandler:(void (^)(NSString *stoppedId))successHandler
                  errorHandler:(void (^)(NSError *error))errorHandler {
    
}


//POST /events/start
- (void)eventStartPeriod:(PYEvent *)event
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler {
    
}

//POST /events/stop
/*Stops a previously running period event
 @param eventId The id of the event to stop
 @param specifiedTime The stop time. Default: now.
 */
- (void)eventStopPeriodWithEventId:(NSString *)eventId
                            onDate:(NSDate *)specificTime
                    successHandler:(void (^)(NSString *stoppedEventId))successHandler
                      errorHandler:(void (^)(NSError *error))errorHandler {
    
}



/**
 Get attachment NSData for file name and event id
 */
- (void)dataForAttachment:(PYAttachment *)attachment
                  onEvent:(PYEvent *)event
           successHandler:(void (^) (NSData * filedata))success
             errorHandler:(void (^) (NSError *error))errorHandler {
    
}

/**
 Get preview NSData (jpg image) for event id
 */
- (void)previewForEvent:(PYEvent *)event
         successHandler:(void (^) (NSData * content))success
           errorHandler:(void (^) (NSError *error))errorHandler {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@?w=512",kROUTE_EVENTS, event.eventId];
    NSString *urlPath = [path stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    
    NSString* fullPath = [NSString stringWithFormat:@"%@://%@%@:%i/%@",
                          self.connection.apiScheme,
                          self.connection.userID,
                          self.connection.apiDomain, 3443, urlPath];
    
    NSURL *url = [NSURL URLWithString:fullPath];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setValue:self.connection.accessToken forHTTPHeaderField:@"Authorization"];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 60.0f;
    
    [PYClient apiRawRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSMutableData *result) {
        if (success) {
            success(result);
            
        }
    } failure:^(NSError *error) {
        errorHandler(error);
        
    }];

    
}

@end
