//
//  PYEventFilterTest.m
//  PryvApiKit
//
//  Created by Perki on 13.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterTest.h"

#import "PYEventFilter.h"
#import "PYTestsUtils.h"

@implementation PYEventFilterTest


- (void)setUp
{
    [super setUp];
    
}

- (void)testEventFilter
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    [self testGettingStreams];
    
    
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    STAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    

     __block BOOL finished = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"EVENTS"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         NSDictionary *message = (NSDictionary*) note.userInfo;
         NSArray* toAdd = [message objectForKey:@"ADD"];
         if (toAdd) {
           NSLog(@"*62 ADD %i", toAdd.count);
             finished = YES;
         }
         NSArray* toRemove = [message objectForKey:@"REMOVE"];
         if (toRemove) {
             NSLog(@"*62 REMOVE %i", toRemove.count);
         }
         NSArray* modify = [message objectForKey:@"MODIFY"];
         if (modify) {
             NSLog(@"*62 MODIFY %i", modify.count);
         }
         
         
         NSLog(@"*61");
         
     }];
    [pyFilter update];
    
    pyFilter.limit = 30;
    [pyFilter update];
    
    
    
    
    
    [PYTestsUtils execute:^{
        STFail(@"Failed after waiting 10 seconds");
    } ifNotTrue:&finished afterSeconds:10];
    
    
}

@end
