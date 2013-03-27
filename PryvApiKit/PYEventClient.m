//
//  PYEventClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventClient.h"

@implementation PYEventClient

-(id)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

#pragma mark - PrYv API Event create (POST /{channel-id}/events/)

//- (void)sendEvent:(PYEvent *)event withSuccessHandler:(void(^)(void))successHandler errorHandler:(void(^)(NSError *error))errorHandler;
//{
//    if (![self isReady]) {
//        NSLog(@"fail sending event: not initialized");
//        
//        if (errorHandler)
//            errorHandler([self createNotReadyError]);
//        return;
//    }
//    
//    NSArray *attachmentList = [event attachmentList];
//    BOOL containAttachment = NO;
//    
//    if (attachmentList != nil && [attachmentList count] > 0) {
//        for (PYEventAttachment *attachment in attachmentList) {
//            // simple data verification before sending
//            NSData *fileData = attachment.fileData;
//            NSString *fileName = attachment.fileName;
//            NSString *mimeType = attachment.mimeType;
//            
//            if (fileData == nil || fileData.length == 0) {
//                NSError *error = [NSError errorWithDomain:@"an attachment file is empty or missing." code:21 userInfo:nil];
//                
//                if (errorHandler)
//                    errorHandler(error);
//                return;
//            }
//            
//            if (fileName == nil || fileName.length == 0) {
//                NSError *error = [NSError errorWithDomain:@"an attachment file name is empty or missing." code:22 userInfo:nil];
//                
//                if (errorHandler)
//                    errorHandler(error);
//                return;
//            }
//            
//            if (mimeType == nil || mimeType.length == 0) {
//                NSError *error = [NSError errorWithDomain:@"an attachment MIME Type specifier is empty or missing." code:23 userInfo:nil];
//                
//                if (errorHandler)
//                    errorHandler(error);
//                return;
//            }
//        }
//        // data verified, this event should contain valid attachment(s)
//        containAttachment = YES;
//    }
//    
//    // create the RESTful url corresponding the current action
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/events", [self apiBaseUrl], self.channelId]];
//    
//    if (containAttachment) {
//        // send event with attachments
//        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
//        [client setDefaultHeader:@"Authorization" value:self.oAuthToken];
//        
//        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"
//                                                                         path:@""
//                                                                   parameters:nil
//                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                                                        
//                                                        // append the event part
//                                                        [formData appendPartWithFormData:[event dataWithJSONObject] name:@"event"];
//                                                        
//                                                        for (PYEventAttachment *attachment in attachmentList) {
//                                                            // append the attachment(s) parts
//                                                            [formData appendPartWithFileData:attachment.fileData
//                                                                                        name:attachment.name
//                                                                                    fileName:attachment.fileName
//                                                                                    mimeType:attachment.mimeType];
//                                                        }
//                                                    }];
//        
//        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                                NSLog(@"successfully sent event with attachment(s)");
//                                                                                                
//                                                                                                if (successHandler)
//                                                                                                    successHandler();
//                                                                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                                                                                NSLog(@"failed to send an event with attachment(s)");
//                                                                                                // create a dictionary with all the data we can get and pass it as userInfo
//                                                                                                NSDictionary *userInfo = @{
//                                                                                                                           @"connectionError": [self nonNil:error],
//                                                                                                                           @"NSHTTPURLResponse" : [self nonNil:response],
//                                                                                                                           @"event": [self nonNil:event],
//                                                                                                                           @"serverError" : [self nonNil:JSON]
//                                                                                                                           };
//                                                                                                NSError *requestError = [NSError errorWithDomain:@"connection failed" code:100 userInfo:userInfo];
//                                                                                                
//                                                                                                if (errorHandler)
//                                                                                                    errorHandler(requestError);
//                                                                                            }];
//        [operation start];
//    }
//    else {
//        // send an event without attachments
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        [request addValue:self.oAuthToken forHTTPHeaderField:@"Authorization"];
//        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        request.HTTPMethod = @"POST";
//        request.HTTPBody = [event dataWithJSONObject];
//        
//        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//            NSLog(@"successfully sent event");
//            
//            if (successHandler)
//                successHandler();
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//            NSLog(@"failed to send an event");
//            // create a dictionary with all the information we can get and pass it as userInfo
//            NSDictionary *userInfo = @{
//                                       @"connectionError": [self nonNil:error],
//                                       @"NSHTTPURLResponse" : [self nonNil:response],
//                                       @"event": [self nonNil:event],
//                                       @"serverError" : [self nonNil:JSON]
//                                       };
//            NSError *requestError = [NSError errorWithDomain:@"connection failed" code:100 userInfo:userInfo];
//            
//            if (errorHandler)
//                errorHandler(requestError);
//        }];
//        [operation start];
//    }
//}

#pragma mark - PrYv API Event get/list (GET /{channel-id}/events/)

- (void)getEventsFromStartDate:(NSDate *)startDate
                     toEndDate:(NSDate *)endDate
                    inFolderId:(NSString *)folderId
                successHandler:(void (^)(NSArray *eventList))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler
{
//    if (![self isReady]) {
//        NSLog(@"fail getting events: not initialized");
//        
//        if (errorHandler)
//            errorHandler([self createNotReadyError]);
//        return;
//    }
//    
//    NSURL *url =  nil;
//    
//    if (startDate != nil && endDate != nil) {
//        
//        // the user asked for a specific time period
//        NSNumber *timeStampBeginning = [NSNumber numberWithDouble:[startDate timeIntervalSince1970]];
//        NSNumber *timeStampEnd = [NSNumber numberWithDouble:[endDate timeIntervalSince1970]];
//        
//        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/events?fromTime=%@&toTime=%@&onlyFolders[]=%@&limit=1200", [self apiBaseUrl], self.channelId, timeStampBeginning, timeStampEnd, folderId]];
//    }
//    else {
//        // the user asked for the last 24h
//        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/events?onlyFolders[]=%@", [self apiBaseUrl], self.channelId, folderId]];
//    }
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setAllHTTPHeaderFields:@{@"Authorization" : self.oAuthToken}];
//    request.HTTPMethod = @"GET";
//    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"successfully received events");
//        
//        if (successHandler) {
//            //            NSManagedObjectContext *scratchManagedContext = [[PPrYvCoreDataManager sharedInstance] scratchManagedObjectContext];
//            NSMutableArray *eventList = [NSMutableArray array];
//            // TODO think how to destroy the scratchmanagedContext
//            for (NSDictionary *eventDictionary in JSON) {
//                PYEvent *event = [PYEvent eventFromDictionary:eventDictionary];
//                [eventList addObject:event];
//            }
//            successHandler(eventList);
//        }
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
//        NSLog(@"failed to receive events");
//        
//        NSDictionary *userInfo = @{
//                                   @"connectionError": [self nonNil:error],
//                                   @"NSHTTPURLResponse" : [self nonNil:response],
//                                   @"serverError" : [self nonNil:JSON]
//                                   };
//        NSError *requestError = [NSError errorWithDomain:@"connection failed" code:100 userInfo:userInfo];
//        
//        if (errorHandler)
//            errorHandler(requestError);
//    }];
//    [operation start];
}


@end
