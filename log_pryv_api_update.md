#Log : Pryv API update
**This file contains the changes that must be applied in order to get your code up-to-date (API v.0.5.4). You can refer to the OS X Example code in the Objective-C SDK to get concrete examples about how to use the new methods.**

##Main changes in v.0.5.4
###PYAccess renamed into PYConnection
*To update :* rename all PYAccess instances into PYConnection.

###Removed PYChannels
We don't use channels anymore. All method for data management, like `createEvent` or `getAllStreams` are now called from a PYConnection instance.

*To update :* see the **Main methods** section below.

###PYFolder renamed into PYStream
*To update :* remove all PYFolder instances and use PYStream and sub-stream instead.

##Main methods
All the main methods to deal with streams and events are now found as PYConnection instance methods.

###Get all streams

```
- (void)getAllStreamsWithRequestType:(PYRequestType)reqType
                    gotCachedStreams:(void (^) (NSArray *cachedStreamList))cachedStreams
                    gotOnlineStreams:(void (^) (NSArray *onlineStreamList))onlineStreams
                         errorHandler:(void (^)(NSError *error))errorHandler;
```

###Get streams with parameters
The parameters are passed via the filter parameter, i.e. `NSDictionary *filterDic`. You can find a list of all parameters on the [API webpage](http://api.pryv.com/reference.html#activity-streams).

```
- (void)getStreamsWithRequestType:(PYRequestType)reqType
                            filter:(NSDictionary*)filterDic
                    successHandler:(void (^) (NSArray *streamsList))onlineStreamList
                      errorHandler:(void (^)(NSError *error))errorHandler;
```

###Create stream
Use the PYConnection instance method

```
- (void)createStream:(PYStream *)stream
     withRequestType:(PYRequestType)reqType
      successHandler:(void (^)(NSString *createdStreamId))successHandler
        errorHandler:(void (^)(NSError *error))errorHandler;
```

###Trash or delete stream

```
- (void)trashOrDeleteStream:(PYStream *)stream
                     filterParams:(NSDictionary *)filter
                  withRequestType:(PYRequestType)reqType
                   successHandler:(void (^)())successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler;
```

###Get all events

```
- (void)getAllEventsWithRequestType:(PYRequestType)reqType
                    gotCachedEvents:(void (^) (NSArray *cachedEventList))cachedEvents
                    gotOnlineEvents:(void (^) (NSArray *onlineEventList))onlineEvents
                     successHandler:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray 												*eventModified))syncDetails
                       errorHandler:(void (^)(NSError *error))errorHandler;
```
###Get events with parameters
```
- (void)getEventsWithRequestType:(PYRequestType)reqType
                      parameters:(NSDictionary *)filter
                    gotCachedEvents:(void (^) (NSArray *cachedEventList))cachedEvents
                    gotOnlineEvents:(void (^) (NSArray *onlineEventList))onlineEvents
                     successHandler:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
                       errorHandler:(void (^)(NSError *error))errorHandler;x
```
###Create event
You must *always* specify the **stream ID**, the **type** and the **time**. To better remember this, you can think of **where, what, when**. Like this, you will never get errors with events.
 
```
- (void)createEvent:(PYEvent *)event
        requestType:(PYRequestType)reqType
     successHandler:(void (^) (NSString *newEventId, NSString *stoppedId))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler;
```
###Trash or delete event

```
- (void)trashOrDeleteEvent:(PYEvent *)event
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler;
```

###Start period event

```
- (void)startPeriodEvent:(PYEvent *)event
             requestType:(PYRequestType)reqType
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler;
```

###Stop period event

```
- (void)stopPeriodEventWithId:(NSString *)eventId
                       onDate:(NSDate *)specificTime
                  requestType:(PYRequestType)reqType
               successHandler:(void (^)(NSString *stoppedEventId))successHandler
                 errorHandler:(void (^)(NSError *error))errorHandler;
```

###Get running event

```
- (void)getRunningPeriodEventsWithRequestType:(PYRequestType)reqType
                               successHandler:(void (^)(NSArray *arrayOfEvents))successHandler
                                 errorHandler:(void (^)(NSError *error))errorHandler;
```