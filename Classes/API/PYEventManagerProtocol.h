//

//
//  Created by Perki on 14.07.14.
//
//

#import <Foundation/Foundation.h>

@class PYAttachment;

struct PartialEventResult
{
    NSArray *eventToAdd;
    NSArray *eventToRemove;
    long totalDone;
    long totalTodo;
};

@protocol PYEventManagerProtocol <NSObject>

/**
- (void) eventsGetWithFilter:(PYFilter*)filter
              successHandler:(void (^) (NSArray *eventList))sucessHandler
               partialResult:(void (^) (struct PartialEventResult *part))partialResult
                errorHandler:(void (^) (NSError *error))errorHandler;
 
**/


/**
 * Records a new event. Events recorded this way must be completed events, i.e. either period events with a known duration or mark events. To start a running period event, post a events/start request. In addition to the usual JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.
 */
- (void)eventCreate:(PYEvent *)event
     successHandler:(void (^)(NSString *newEventId, NSString *stoppedId, PYEvent *event))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 DELETE /events/{event-id}
 Trashes or deletes the specified event, depending on its current state:
 If the event is not already in the trash, it will be moved to the trash (i.e. flagged as trashed)
 If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).
 */
- (void)eventTrashOrDelete:(PYEvent *)event
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler;

//PUT /events/{event-id}
/*Modifies the event's attributes
 All event fields are optional, and only modified properties must be included, for other properties put nil
 @successHandler stoppedId indicates the id of the previously running period event that was stopped as a consequence of modifying the event (if set)
 */
- (void)eventSaveModifications:(PYEvent *)eventObject
                successHandler:(void (^)(NSString *stoppedId))successHandler
                  errorHandler:(void (^)(NSError *error))errorHandler;


//POST /events/start
- (void)eventStartPeriod:(PYEvent *)event
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler;

//POST /events/stop
/*Stops a previously running period event
 @param eventId The id of the event to stop
 @param specifiedTime The stop time. Default: now.
 */
- (void)eventStopPeriodWithEventId:(NSString *)eventId
                            onDate:(NSDate *)specificTime
                    successHandler:(void (^)(NSString *stoppedEventId))successHandler
                      errorHandler:(void (^)(NSError *error))errorHandler;



/**
 Get attachment NSData for file name and event id
 */
- (void)dataForAttachment:(PYAttachment *)attachment
                  onEvent:(PYEvent *)event
           successHandler:(void (^) (NSData * filedata))success
             errorHandler:(void (^) (NSError *error))errorHandler;

/**
 Get preview NSData (jpg image) for event id
 */
- (void)previewForEvent:(PYEvent *)event
         successHandler:(void (^) (NSData * content))success
           errorHandler:(void (^) (NSError *error))errorHandler;

@end
