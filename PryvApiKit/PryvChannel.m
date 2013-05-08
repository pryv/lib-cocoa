//
//  Channel.m
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//


#import "PryvChannel.h"
#import "PryvFolder+JSON.h"
#import "PryvEvent.h"
#import "PryvEventNote.h"

#import "PryvConstants.h"

@implementation PryvChannel

@synthesize access = _access;
@synthesize channelId = _channelId;
@synthesize name = _name;
@synthesize timeCount = _timeCount;
@synthesize clientData = _clientData;
@synthesize enforceNoEventsOverlap = _enforceNoEventsOverlap;
@synthesize trashed = _trashed;

- (void)dealloc
{
    [_access release];
    [_channelId release];
    [_name release];
    [_clientData release];
    [super dealloc];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.id=%@", self.channelId];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.clientData=%@", self.clientData];
    [description appendFormat:@", self.enforceNoEventsOverlap=%d", self.enforceNoEventsOverlap];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendString:@">"];
    return description;
}


- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler {
    
    if (path == nil) path = @"";
    NSString* newPath = [NSString stringWithFormat:@"%@/%@", self.channelId, path];
    [self.access apiRequest:newPath requestType:reqType method:method postData:postData attachments:attachments success:successHandler failure:failureHandler];
}


#pragma mark - Events manipulation

//GET /{channel-id}/events

- (void)getAllEventsWithRequestType:(PYRequestType)reqType
                     successHandler:(void (^) (NSArray *eventList))successHandler
                       errorHandler:(void (^)(NSError *error))errorHandler
{
   
    [self apiRequest:kROUTE_EVENTS
             requestType:reqType
                  method:PYRequestMethodGET
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
                     for (NSDictionary *eventDic in JSON) {
                         [eventsArray addObject:[PryvEvent getEventFromDictionary:eventDic]];
                     }
                     if (successHandler) {
                         successHandler([eventsArray autorelease]);
                     }
                                          
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}

//POST /{channel-id}/events
- (void)createEvent:(PryvEvent *)event
        requestType:(PYRequestType)reqType
     successHandler:(void (^) (NSString *newEventId, NSString *stoppedId))successHandler
       errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:kROUTE_EVENTS
             requestType:reqType
                  method:PYRequestMethodPOST
                postData:[event dictionary]
             attachments:event.attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     
                     NSString *createdEventId = [JSON objectForKey:@"id"];
                     NSString *stoppedId = [JSON objectForKey:@"stoppedId"];
                     
                     if (successHandler) {
                         successHandler(createdEventId, stoppedId);
                     }
                                          
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}


//POST /{channel-id}/events/start
- (void)startPeriodEvent:(PryvEvent *)event
             requestType:(PYRequestType)reqType
          successHandler:(void (^)(NSString *startedEventId))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"start"]
             requestType:reqType
                  method:PYRequestMethodPOST
                postData:[event dictionary]
             attachments:event.attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     
                     NSString *startedEventId = [JSON objectForKey:@"id"];
                     
                     if (successHandler) {
                         successHandler(startedEventId);
                     }
                     
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}

//POST /{channel-id}/events/stop
- (void)stopPeriodEventWithId:(NSString *)eventId
                       onDate:(NSDate *)specificTime
                  requestType:(PYRequestType)reqType
               successHandler:(void (^)(NSString *stoppedEventId))successHandler
                 errorHandler:(void (^)(NSError *error))errorHandler
{
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    
    [postData setObject:eventId forKey:@"id"];
    if (specificTime) {
        NSTimeInterval timeInterval = [specificTime timeIntervalSince1970];
        [postData setObject:[NSNumber numberWithDouble:timeInterval] forKey:@"time"];

    }
    
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"stop"]
             requestType:reqType
                  method:PYRequestMethodPOST
                postData:[postData autorelease]
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     
                     NSString *stoppedEventId = [JSON objectForKey:@"id"];
                     
                     if (successHandler) {
                         successHandler(stoppedEventId);
                     }
                     
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}

//GET /{channel-id}/events/running
- (void)getRunningPeriodEventsWithRequestType:(PYRequestType)reqType
                                    successHandler:(void (^)(NSArray *arrayOfEvents))successHandler
                                      errorHandler:(void (^)(NSError *error))errorHandler

{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,@"running"]
             requestType:reqType
                  method:PYRequestMethodGET
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     
                     NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
                     for (NSDictionary *eventDic in JSON) {
                         [eventsArray addObject:[PryvEvent getEventFromDictionary:eventDic]];
                     }
                     if (successHandler) {
                         successHandler([eventsArray autorelease]);
                     }

                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }
     ];

}

//PUT /{channel-id}/events/{event-id}
- (void)setModifiedEventAttributesObject:(PryvEvent *)eventObject
                              forEventId:(NSString *)eventId
                             requestType:(PYRequestType)reqType
                          successHandler:(void (^)(NSString *stoppedId))successHandler
                            errorHandler:(void (^)(NSError *error))errorHandler
{

    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_EVENTS,eventId]
             requestType:reqType
                  method:PYRequestMethodPUT
                postData:[eventObject dictionary]
             attachments:eventObject.attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     
                     NSString *stoppedId = [JSON objectForKey:@"stoppedId"];
                     
                     if (successHandler) {
                         successHandler(stoppedId);
                     }
                     
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}


#pragma mark - PrYv API Folder get all (GET /{channel-id}/folders/)

- (void)getFoldersWithRequestType:(PYRequestType)reqType
                     filterParams:(NSDictionary *)filter
                   successHandler:(void (^)(NSArray *folderList))successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler;
{
 
    [self apiRequest:[PryvClient urlPath:kROUTE_FOLDERS withParams:filter]
             requestType:reqType
                  method:PYRequestMethodGET
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSMutableArray *folderList = [[NSMutableArray alloc] init];
                         for (NSDictionary *folderDictionary in JSON) {
                             PryvFolder *folderObject = [PryvFolder folderFromJSON:folderDictionary];
                             [folderList addObject:folderObject];
                         }
                         if (successHandler) {
                             successHandler([folderList autorelease]);
                         }
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
}


#pragma mark - PrYv API Folder create (POST /{channel-id}/folders/)

- (void)createFolderWithId:(NSString *)folderId
                      name:(NSString *)folderName
                  parentId:(NSString *)parentId
                  isHidden:(BOOL)hidden
          customClientData:(NSDictionary *)clientData
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)(NSString *createdFolderId))successHandler
              errorHandler:(void (^)(NSError *error))errorHandler
{
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:folderId forKey:@"id"];
    [postData setObject:folderName forKey:@"name"];
    [postData setObject:self.channelId forKey:@"channelId"];
        
    if (parentId) {
        [postData setObject:parentId forKey:@"parentId"];
    }
    
    if (clientData) {
        [postData setObject:clientData forKey:@"clientData"];
    }
    
    [postData setObject:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
    
    [self apiRequest:kROUTE_FOLDERS
             requestType:reqType
                  method:PYRequestMethodPOST
                postData:[postData autorelease]
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSString *createdFolderId = [JSON objectForKey:@"id"];
                         if (successHandler) {
                             successHandler(createdFolderId);
                         }
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
    
}


#pragma mark - PrYv API Folder modify (PUT /{channel-id}/folders/{folder-id})

- (void)modifyFolderWithId:(NSString *)folderId
                      name:(NSString *)newfolderName
                  parentId:(NSString *)newparentId
                  isHidden:(BOOL)hidden
          customClientData:(NSDictionary *)clientData
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler
{
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    if (newfolderName) {
        [postData setObject:newfolderName forKey:@"name"];
    }
        
    if (newparentId) {
        [postData setObject:newparentId forKey:@"parentId"];
    }
    
    if (clientData) {
        [postData setObject:clientData forKey:@"clientData"];
    }
    
    [postData setObject:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
        
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_FOLDERS,  folderId]
             requestType:reqType
                  method:PYRequestMethodPUT
                postData:[postData autorelease]
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     if (successHandler) {
                         successHandler();
                     }
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}

#pragma mark - PrYv API Folder delet (DELETE /{channel-id}/folders/{folder-id})

- (void)trashOrDeleteFolderWithId:(NSString *)folderId
                     filterParams:(NSDictionary *)filter
                  withRequestType:(PYRequestType)reqType
                   successHandler:(void (^)())successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[PryvClient urlPath:[NSString stringWithFormat:@"%@/%@",kROUTE_FOLDERS, folderId] withParams:filter]
             requestType:reqType
                  method:PYRequestMethodDELETE
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     if (successHandler) {
                         successHandler();
                     }
                 } failure:^(NSError *error) {
                     if (errorHandler) {
                         errorHandler (error);
                     }
                 }];

}


@end
