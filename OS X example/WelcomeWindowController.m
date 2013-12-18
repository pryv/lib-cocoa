//
//  WelcomeWindowWindowController.m
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "WelcomeWindowController.h"
#import "SigninWindowController.h"
#import "PryvApiKit.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "AppDelegate.h"
#import "User.h"
#import "PYStreamsCachingUtillity.h"


@interface WelcomeWindowController ()

@end

@implementation WelcomeWindowController
@synthesize signinButton;
@synthesize event, runningEvent;

-(void)dealloc{
    [event release];
    event = nil;
    [super dealloc];
}

-(id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self){
        testStream = [[PYStreamsCachingUtillity getStreamFromCacheWithStreamId:@"osx_example_test_stream"] retain];
    }
    
    return self;
}

- (IBAction)signinButtonPressed:(id)sender {
    if(!signinWindowController)
        signinWindowController = [[SigninWindowController alloc] initWithWindowNibName:@"SigninWindowController"];
    [signinWindowController showWindow:self];    
}

- (IBAction)getStreams:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        [connection getAllStreamsWithRequestType:PYRequestTypeAsync
                               gotCachedStreams:^(NSArray *cachedStreamList) {
                                   NSLog(@"CACHED STREAMS : ");
                                   [cachedStreamList enumerateObjectsUsingBlock:^(PYStream *stream, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Cached : %@ (%@)",[stream name], [stream streamId]);
                                   }];
                               } gotOnlineStreams:^(NSArray *onlineStreamList) {
                                   NSLog(@"ONLINE STREAMS : ");
                                   [onlineStreamList enumerateObjectsUsingBlock:^(PYStream *stream, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Online : %@ (%@)",[stream name], [stream streamId]);
                                   }];
                               } errorHandler:^(NSError *error) {
                                   NSLog(@"%@",error);
                               }];
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)createTestStream:(id)sender {
    
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        testStream = [[PYStream alloc] init];
        testStream.name = @"OSX_Example_test";
        testStream.streamId = @"osx_example_test_stream";
        testStream.singleActivity = NO;
        testStream.children = @[];
        testStream.connection = connection;
        [connection createStream:testStream withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdStreamId) {
            NSLog(@"New stream ID : %@",createdStreamId);
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)trashTestStream:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        if (testStream) {
            [PYClient setDefaultDomainStaging];
            PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
            
            [connection trashOrDeleteStream:testStream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                [connection trashOrDeleteStream:testStream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                    [PYStreamsCachingUtillity removeStream:testStream];
                    [testStream release];
                    testStream = nil;
                    NSLog(@"Stream deleted.");
                } errorHandler:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            } errorHandler:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            
            [connection release];
            connection = nil;
        }else{
            NSLog(@"No test stream.");
        }
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)createTestEvent:(id)sender {
    if (testStream) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        
        event = [[PYEvent alloc] init];
        event.streamId = @"osx_example_test_stream";
        event.type = @"note/txt";
        event.eventContent = @"This is a note from the OS X Example app.";
        event.time = NSTimeIntervalSince1970;
        
        NSLog(@"%@",event);
        [connection createEvent:event
                    requestType:PYRequestTypeAsync
                 successHandler:^(NSString *newEventId, NSString *stoppedId) {
                     event.eventId = [NSString stringWithString:newEventId];
            NSLog(@"New event id : %@",newEventId);
        } 
                   errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No test stream. Create one first.");
    }

    
}

- (IBAction)deleteTestEvent:(id)sender {
    if (testStream) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        if (event) {
            [connection trashOrDeleteEvent:event withRequestType:PYRequestTypeAsync successHandler:^{
              [connection trashOrDeleteEvent:event withRequestType:PYRequestTypeAsync successHandler:^{
                  [PYEventsCachingUtillity removeEvent:event];
                   NSLog(@"Event deleted.");
                }errorHandler:^(NSError *error) {
                    NSLog(@"Error while deleting : %@",error);
               }];
            } errorHandler:^(NSError *error) {
                NSLog(@"Error while trashing : %@",error);
            }];
        }else{
            NSLog(@"You must first create an event !");
        }
        
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No test stream. Create one first.");
    }   
}

- (IBAction)deleteEvent:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        PYEvent *customEvent = [PYEventsCachingUtillity getEventFromCacheWithEventId:[eventID stringValue]];
        
        //If not found in cache (removed manually, error, ...)
        if (!customEvent) {
            [connection getOnlineEventWithId:[eventID stringValue] requestType:PYRequestTypeAsync successHandler:^(PYEvent *customEvent) {
                [connection trashOrDeleteEvent:customEvent withRequestType:PYRequestTypeAsync successHandler:^{
                    [connection trashOrDeleteEvent:customEvent withRequestType:PYRequestTypeAsync successHandler:^{
                        NSLog(@"Event deleted.");
                    }errorHandler:^(NSError *error) {
                        NSLog(@"Error while deleting : %@",error);
                    }];
                } errorHandler:^(NSError *error) {
                    NSLog(@"Error while trashing : %@",error);
                }];

            } errorHandler:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }else{
            [PYEventsCachingUtillity removeEvent:customEvent];
            [connection trashOrDeleteEvent:customEvent withRequestType:PYRequestTypeAsync successHandler:^{
                [connection trashOrDeleteEvent:customEvent withRequestType:PYRequestTypeAsync successHandler:^{
                    NSLog(@"Event deleted.");
                }errorHandler:^(NSError *error) {
                    NSLog(@"Error while deleting : %@",error);
                }];
            } errorHandler:^(NSError *error) {
                NSLog(@"Error while trashing : %@",error);
            }];
        }
    
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)startRunningEvent:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        runningEvent = [[PYEvent alloc] init];
        runningEvent.streamId = @"osx_example_test_stream";
        runningEvent.type = @"activity/pryv";
        runningEvent.time = NSTimeIntervalSince1970;
        
        [connection startPeriodEvent:runningEvent requestType:PYRequestTypeAsync successHandler:^(NSString *startedEventId) {
            NSLog(@"Started event ID : %@",startedEventId);
            runningEvent.eventId = [NSString stringWithString:startedEventId];
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)stopRunningEvent:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        if(runningEvent){
            [PYClient setDefaultDomainStaging];
            PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
            
            [connection stopPeriodEventWithId:runningEvent.eventId onDate:[NSDate date] requestType:PYRequestTypeAsync successHandler:^(NSString *stoppedEventId) {
                NSLog(@"Stopped event ID : %@",stoppedEventId);
            } errorHandler:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            [connection release];
            connection = nil;
        }else{
            NSLog(@"You must start a period event first.");
        }
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)getRunningEvent:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        if(runningEvent){
            [PYClient setDefaultDomainStaging];
            PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
            NSArray *stream = [NSArray arrayWithObject:@"osx_example_test_stream"];
            NSDictionary *filter = [NSDictionary dictionaryWithObject:stream forKey:@"streams"];
            [connection getRunningPeriodEventsWithRequestType:PYRequestTypeAsync
                                                   parameters:filter
                                               successHandler:^(NSArray *arrayOfEvents) {
                                                   if ([arrayOfEvents count] > 0) {
                                                       [arrayOfEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                           NSLog(@"Running event : %@",[obj eventId]);
                                                       }];
                                                   }else{
                                                       NSLog(@"No running event.");
                                                   }
             
            } errorHandler:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            [connection release];
            connection = nil;
        }else{
            NSLog(@"You must start a period event first.");
        }
    }else{
        NSLog(@"No user connected.");
    }
}

- (IBAction)addAttachment:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];

        NSOpenPanel *openDialog = [NSOpenPanel openPanel];
        [openDialog setCanChooseDirectories:NO];
        [openDialog setCanChooseFiles:YES];
        [openDialog setAllowsMultipleSelection:YES];
        [openDialog retain]; //Mac OS X 10.6 fix
        [openDialog beginWithCompletionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSArray *files = [openDialog URLs];
                NSMutableArray *attachments = [[NSMutableArray alloc] init];
                for(NSURL *f in files){
                    NSString *file = [f path];
                    NSString *filename = [file lastPathComponent];
                    NSString *name = [filename stringByDeletingPathExtension];
                    NSData *fileData = [[NSData alloc] initWithContentsOfFile:file];
                    NSLog(@"Length : %lu", (unsigned long)[fileData length]);
                    PYAttachment *attachment = [[PYAttachment alloc] initWithFileData:fileData
                                                                   name:name
                                                               fileName:filename];
                    [attachments addObject:attachment];
                }
                
                eventWithAttachment = [[PYEvent alloc] init];
                eventWithAttachment.streamId = @"osx_example_test_stream";
                eventWithAttachment.type = @"file/attached-multiple";
                eventWithAttachment.time = NSTimeIntervalSince1970;
                eventWithAttachment.attachments = [NSMutableArray arrayWithArray:attachments];
                NSLog(@"Attached : %@",eventWithAttachment.attachments);
                [PYClient setDefaultDomainStaging];
                PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
                [connection createEvent:eventWithAttachment requestType:PYRequestTypeAsync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                    NSLog(@"New event ID : %@",newEventId);
                } errorHandler:^(NSError *error) {
                    NSLog(@"%@",error);
                    NSLog(@"UserInfo: %@",[error userInfo]);
                }];
            }
            [openDialog release];
        }];
    }else{
        NSLog(@"No user connected.");
    }

    
}

- (IBAction)deleteStream:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        PYStream *customStream = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:[streamID stringValue]];
        
        //If not found in cache (removed manually, error, ...)
        if (!customStream) {
            NSLog(@"Custom stream id : %@",customStream.streamId);
                [connection getOnlineStreamWithId:customStream.streamId requestType:PYRequestTypeAsync successHandler:^(PYStream *stream) {
                    [connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                        [connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                            [PYStreamsCachingUtillity removeStream:stream];
                            NSLog(@"Stream deleted.");
                        } errorHandler:^(NSError *error) {
                            NSLog(@"Error while deleting stream : %@",error);
                        }];
                    } errorHandler:^(NSError *error) {
                        NSLog(@"Error while trashing stream : %@",error);
                    }];
                } errorHandler:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
        }else{
            NSLog(@"Custom stream id : %@",customStream.streamId);
            [connection trashOrDeleteStream:customStream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                [connection trashOrDeleteStream:customStream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                    [PYStreamsCachingUtillity removeStream:customStream];
                    NSLog(@"Stream deleted.");
                }errorHandler:^(NSError *error) {
                    NSLog(@"Error while deleting : %@",error);
                }];
            } errorHandler:^(NSError *error) {
                NSLog(@"Error while trashing : %@",error);
            }];
        }
        
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected.");
    }    
}

- (IBAction)getEvents:(id)sender {
    if (testStream) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        NSArray *streams = [NSArray arrayWithObjects:@"osx_example_test_stream", nil];
        NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObject:streams forKey:@"streams"];
        
//        NSNumber *skip = [NSNumber numberWithInt:10];
//        [filter setValue:skip forKey:@"skip"];
//        NSNumber *limit = [NSNumber numberWithInt:5];
//        [filter setValue:limit forKey:@"limit"];
//        [filter setValue:@"trashed" forKey:@"state"];

        
        [connection getEventsWithRequestType:PYRequestTypeAsync parameters:filter gotCachedEvents:^(NSArray *cachedEventList) {
            NSLog(@"CACHED EVENTS :");
//            [cachedEventList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSLog(@"Cached : %@ => %@ in stream %@",[obj eventId],[obj eventContent],[obj streamId]);
//            }];
        } gotOnlineEvents:^(NSArray *onlineEventList) {
            if ([onlineEventList count] > 0) {
                NSLog(@"ONLINE EVENTS : ");
                [onlineEventList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([[obj attachments] count] > 0) {
                        NSLog(@"Online : %@ => %@ in stream %@",[obj eventId],[obj eventContent],[obj streamId]);
                        NSLog(@"With attachments :");
                        NSLog(@"%@", [obj attachments]);
                    }else{
                        NSLog(@"Online : %@ => %@ in stream %@",[obj eventId],[obj eventContent],[obj streamId]);
                    }
                }];

            }else{
                NSLog(@"No online events.");
            }
        } onlineDiffWithCached:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
//        [connection release];
//        connection = nil;
    }else{
        NSLog(@"No test stream. Create one first.");
    }    
}


@end
