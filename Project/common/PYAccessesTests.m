//
//  PYAccessesTests.m
//  PrYv-iOS-Example
//
//  Created by Perki on 16.06.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYConnection+Accesses.h"

@interface PYAccessesTests : PYBaseConnectionTests
@end

@implementation PYAccessesTests


- (void)setUp
{
    [super setUp];
    
    
    
}

- (void)testAccesses
{
    STAssertNotNil(self.connection, @"Connection isn't created");

    NOT_DONE(done);
    
    [self.connection accessesOnlineWithSuccessHandler:^(NSArray *accessesList) {
        
        
        DONE(done);
    } errorHandler:^(NSError *error) {
          STFail(@"Error occured when geting access. %@", error);
         DONE(done);
    }];
     
         
    WAIT_FOR_DONE(done);


}


@end
