//
//  PYEAppTests.m
//  PryvApiKit
//
//  Created by Perki on 05.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PryvApiKit.h"
#import "PYEAppTests.h"
#import "PYTestsUtils.h"

@interface PYEAppTests ()

@property (nonatomic, retain) PYConnection *connection;

@end


@implementation PYEAppTests

NSString *const kPYAPITestAccount = @"perkikiki";
NSString *const kPYAPITestAccessToken = @"Ve-U8SCASM";

@synthesize connection;

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) startTests
{
    [PYClient setDefaultDomainStaging];
    self.connection = [PYClient createConnectionWithUsername:kPYAPITestAccount
                                              andAccessToken:kPYAPITestAccessToken];
    //STAssertNotNil(self.connection, @"Connection not created.");
    
    
    //STAssertNotNil(self.connection, @"Connection isn't created");
    
  //  [self testGettingStreams];
    
    
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    //STAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    
    __block BOOL finished1 = NO;
    __block BOOL finished2 = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"EVENTS"
                                                      object:pyFilter
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         NSDictionary *message = (NSDictionary*) note.userInfo;
         NSArray* toAdd = [message objectForKey:@"ADD"];
         if (toAdd && toAdd.count > 0) {
             NSLog(@"*162 ADD %i", toAdd.count);
             
             if (! finished1) {
                 //STAssertEquals(20u, toAdd.count, @"Got wrong number of events");
                 finished1 = YES;
                 pyFilter.limit = 30;
                 [pyFilter update];
                 
             } else {
                 //STAssertEquals(10u, toAdd.count, @"Got wrong number of events");
                 finished2 = YES;
             }
             
         }
         NSArray* toRemove = [message objectForKey:@"REMOVE"];
         if (toRemove) {
             NSLog(@"*162 REMOVE %i", toRemove.count);
         }
         NSArray* modify = [message objectForKey:@"MODIFY"];
         if (modify) {
             NSLog(@"*162 MODIFY %i", modify.count);
         }
         
         
         NSLog(@"*162");
         
     }];
    [pyFilter update];
    
    
    [PYTestsUtils execute:^{
        //STFail(@"Failed after waiting 10 seconds");
    } ifNotTrue:&finished2 afterSeconds:10];
    
}





@end
