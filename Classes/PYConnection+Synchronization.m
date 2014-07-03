//
//  PYConnection+Synchronization.m
//  Pods
//
//  Created by Perki on 06.06.14.
//
//

#import "PYEvent+Sync.h"
#import "PYConnection+Synchronization.h"
#import "PYConnection+DataManagement.h"

@implementation PYConnection (Synchronization)


- (void)syncNotSynchedStreamsIfAny
{
    NSMutableArray *nonSyncStreams = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncStreams addObjectsFromArray:[self.streamsNotSync allObjects]];
    for (PYStream *stream in nonSyncStreams) {
        
        //the condition is not correct : set self.Id to shut error up, should be parentId
        //        if ([stream.parentId compare:self.Id] == NSOrderedSame) {
        
        
        //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
        stream.isSyncTriedNow = YES;
        
        if (stream.hasTmpId) {
            if (stream.notSyncModify) {
                NSLog(@"stream has tmpId and it's mofified -> do nothing. If stream doesn't have server id it needs to be added to server and that is all what is matter. Modified object will update PYStream object in cache and in unsyncList");
                
            }
            NSLog(@"stream has tmpId and it's added");
            if (stream.notSyncAdd) {
                NSString *tempId = [NSString stringWithString:stream.streamId];
                stream.streamId = @"";
                [self streamCreate:stream
                    successHandler:^(NSString *createdStreamId) {
                        //If succedded remove from unsyncSet and add call syncStreamWithServer
                        //In that method we were search for stream with <createdStreamId> and we should done mapping between server and temp id in cache
                        stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                        stream.streamId = [NSString stringWithString:tempId];
                        
                        
                        
                        
                        [self.streamsNotSync removeObject:stream];
                        //We have success here. Stream is cached in streamCreate: method, remove old stream with tmpId from cache
                        //He will always have tmpId here but just in case for testing (defensive programing)
                        
                    } errorHandler:^(NSError *error) {
                        stream.isSyncTriedNow = NO;
                        NSLog(@"SYNC error: creating stream failed.");
                        NSLog(@"%@",error);
                    }];
            }
            
        }else{
            NSLog(@"In this case stream has server id");
            
            if (stream.notSyncModify) {
                NSLog(@"for modifified unsync streams with serverId we have to provide only modified values, not full event object");
                
                NSDictionary *modifiedPropertiesDic = stream.modifiedStreamPropertiesAndValues;
                PYStream *modifiedStream = [[PYStream alloc] init];
                modifiedStream.isSyncTriedNow = YES;
                
                [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                    [modifiedStream setValue:value forKey:property];
                }];
                
                [self streamSaveModifiedAttributeFor:modifiedStream forStreamId:stream.streamId successHandler:^{
                    
                    //We have success here. Stream is cached in streamSaveModifiedAttributeFor:forStreamId method
                    stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                    [self.streamsNotSync removeObject:stream];
                    
                } errorHandler:^(NSError *error) {
                    modifiedStream.isSyncTriedNow = NO;
                    stream.isSyncTriedNow = NO;
                }];
            }
        }
    }
    // }
}


// to be batched
BOOL allreadySynchingEvents = NO;
- (void)syncNotSynchedEventsIfAny:(void(^)(int successCount, int overEventCount))done
{
    if (allreadySynchingEvents) return;
    allreadySynchingEvents = YES;
    
    NSArray* eventNotSync = self.eventsNotSync;
    
    int eventCounter = (int)eventNotSync.count;
    __block int successCounter = 0;
    
    
    dispatch_group_t group = dispatch_group_create();
    
    for (PYEvent *event in eventNotSync) {
        dispatch_group_enter(group);
        //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
        event.isSyncTriedNow = YES;
        
        if ([event toBeDeleteOnSync]) {
            [self eventTrashOrDelete:event
                      successHandler:^{
                          event.isSyncTriedNow = NO;
                          successCounter++;
                          dispatch_group_leave(group);
                      } errorHandler:^(NSError *error) {
                          event.isSyncTriedNow = NO;
                          dispatch_group_leave(group);
                      }];
        } else if (event.hasTmpId) { // create
            
            [self eventCreate:event
               successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdEvent) {
                   event.isSyncTriedNow = NO;
                   successCounter++;
                   dispatch_group_leave(group);
               } errorHandler:^(NSError *error) {
                   //if we arrive there, it means that the created event is invalid.
                   //it has been removed from cache!!
                   //reset flag if fail, very IMPORTANT
                   event.isSyncTriedNow = NO;
                   NSLog(@"SYNC error: creating event failed");
                   NSLog(@"%@",error);
                   dispatch_group_leave(group);
               }];
        } else { // update
            NSLog(@"In this case event has server id");
            [self eventSaveModifications:event
                          successHandler:^(NSString *stoppedId) {
                              event.isSyncTriedNow = NO;
                              successCounter++;
                              dispatch_group_leave(group);
                          } errorHandler:^(NSError *error) {
                              event.isSyncTriedNow = NO;
                              dispatch_group_leave(group);
                          }];
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        allreadySynchingEvents = NO;
        if (done) {
            done(successCounter, eventCounter);
            
        }
    });
    dispatch_release(group);
}


/**
 * probably useless as now all requests synchronize
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTimeInterval))successHandler
                             errorHandler:(void(^)(NSError *error))errorHandler{
    
    [self apiRequest:@"/profile/app" //TODO: handle app profiles for improved user experience
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseValue) {
                 NSLog(@"Successfully authorized and synchronized with server time: %f ", _serverTimeInterval);
                 if (successHandler)
                     successHandler(_serverTimeInterval);
                 
             } failure:^(NSError *error) {
                 if (errorHandler)
                     errorHandler(error);
                 
                 
             }];
}


- (NSArray*)eventsNotSync
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    PYEvent* event;
    for (event in [self allEvents]) {
        if ([event toBeSyncSkipCacheTest]) {
            [result addObject:event];
        }
    }
    return [result autorelease];
}

@end
