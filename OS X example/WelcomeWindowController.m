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
    [streams release];
    streams = nil;
    [super dealloc];
}

-(id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self){
    
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
        streams = [[NSMutableArray alloc] init];
        [connection getAllStreamsWithRequestType:PYRequestTypeAsync
                               gotCachedStreams:^(NSArray *cachedStreamList) {
                                   NSLog(@"CACHED STREAMS : ");
                                   [cachedStreamList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Cached : %@ (%@)",[obj name], [obj streamId]);
                                   }];
                               } gotOnlineStreams:^(NSArray *onlineStreamList) {
                                   NSLog(@"ONLINE STREAMS : ");
                                   [onlineStreamList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Online : %@ (%@)",[obj name], [obj streamId]);
                                       [streams addObject:[obj streamId]];
                                   }];
                               } errorHandler:^(NSError *error) {
                                   NSLog(@"%@",error);
                               }];
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected !");
    }
}

- (IBAction)createTestStream:(id)sender {
    
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        PYStream *stream = [[PYStream alloc] init];
        stream.name = @"OSX_Example_test";
        stream.streamId = @"osx_example_test_stream";
        stream.singleActivity = NO;
        stream.children = @[];
        stream.connection = connection;
        [connection createStream:stream withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdStreamId) {
            NSLog(@"New stream ID : %@",createdStreamId);
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        [stream release];
        stream = nil;
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected !");
    }
}

- (IBAction)trashTestStream:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        PYStream *stream = [PYStreamsCachingUtillity
                            getStreamFromCacheWithStreamId:@"osx_example_test_stream"];
        [connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
            [connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                [PYStreamsCachingUtillity removeStream:stream];
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
        NSLog(@"No user connected !");
    }
}

- (IBAction)createTestEvent:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        
        event = [[PYEvent alloc] init];
        event.streamId = @"*";
        event.type = @"note/txt";
        event.eventContent = @"This is a note from the OS X Example app.";
        event.time = NSTimeIntervalSince1970;
        
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
        NSLog(@"No user connected !");
    }

    
}

- (IBAction)deleteTestEvent:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
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
        NSLog(@"No user connected !");
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
        
        [connection release];
        connection = nil;
    }else{
        NSLog(@"No user connected !");
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
        runningEvent.streamId = @"TVWwwYo-mJ";
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
        NSLog(@"No user connected !");
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
        NSLog(@"No user connected !");
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
            NSArray *activityStream = [NSArray arrayWithObject:@"TVWwwYo-mJ"];
            NSDictionary *filter = [NSDictionary dictionaryWithObject:activityStream forKey:@"streams"];
            [connection getRunningPeriodEventsWithRequestType:PYRequestTypeAsync
                                                   parameters:filter
                                               successHandler:^(NSArray *arrayOfEvents) {
                [arrayOfEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSLog(@"Running event : %@",[obj eventId]);
                }];
            } errorHandler:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            [connection release];
            connection = nil;
        }else{
            NSLog(@"You must start a period event first.");
        }
    }else{
        NSLog(@"No user connected !");
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
        [openDialog setAllowsMultipleSelection:NO];
        [openDialog retain]; //Mac OS X 10.6 fix
        [openDialog beginWithCompletionHandler:^(NSInteger result){
            NSLog(@"Result ; %ld",(long)result);
            if (result == NSFileHandlingPanelOKButton) {
                NSArray *files = [openDialog URLs];
                NSString *file = [[files objectAtIndex:0] path];
                NSString *filename = [file lastPathComponent];
//                NSString *name = [[filename stringByDeletingPathExtension] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                NSString *name = @"TestName";
                NSData *fileData = [[NSData alloc] initWithContentsOfFile:file];
                NSLog(@"Length : %lu", (unsigned long)[fileData length]);
                PYAttachment *attachment = [[PYAttachment alloc] initWithFileData:fileData
                                                                             name:name
                                                                        fileName:filename];
        
                eventWithAttachment = [[PYEvent alloc] init];
                eventWithAttachment.streamId = @"*";
                eventWithAttachment.type = @"file/attached";
                eventWithAttachment.time = NSTimeIntervalSince1970;
                eventWithAttachment.attachments = [NSMutableArray arrayWithObject:attachment];
                NSLog(@"Attached : %@",eventWithAttachment.attachments);
                [PYClient setDefaultDomainStaging];
                PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
                [connection createEvent:eventWithAttachment requestType:PYRequestTypeAsync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                    NSLog(@"New event ID : %@",newEventId);
                } errorHandler:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            }
            [openDialog release];
        }];
    }else{
        NSLog(@"No user connected !");
    }

    
}

- (IBAction)getEvents:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        NSMutableDictionary *filter = [[NSMutableDictionary alloc] init];
        if (streams) {
            [filter setValue:streams forKey:@"streams"];
        }else{
            streams = [NSArray arrayWithObjects:@"*",nil];
            [filter setValue:streams forKey:@"streams"];
        }
        
        
//        NSNumber *skip = [NSNumber numberWithInt:10];
//        [filter setValue:skip forKey:@"skip"];
//        NSNumber *limit = [NSNumber numberWithInt:5];
//        [filter setValue:limit forKey:@"limit"];
//        [filter setValue:@"trashed" forKey:@"state"];

        
        [connection getEventsWithRequestType:PYRequestTypeAsync parameters:filter gotCachedEvents:^(NSArray *cachedEventList) {
            NSLog(@"CACHED EVENTS :");
            [cachedEventList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Cached : %@ => %@ in stream %@",[obj eventId],[obj eventContent],[obj streamId]);
            }];
        } gotOnlineEvents:^(NSArray *onlineEventList) {
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
        } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
//        [connection release];
//        connection = nil;
    }else{
        NSLog(@"No user connected !");
    }    
}


@end
