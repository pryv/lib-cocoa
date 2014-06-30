//
//  PYFollowedSlicesTests.m
//  PrYv-iOS-Example
//
//  Created by Perki on 16.06.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYConnection+FollowedSlices.h"
#import "PYTestConstants.h"

@interface PYFollowedSlicesTests : PYBaseConnectionTests


@property (nonatomic, retain) PYConnection *connectionTrusted;

@end



@implementation PYFollowedSlicesTests


- (void)setUp
{
    [super setUp];
    self.connectionTrusted = [PYClient createConnectionWithUsername:kPYAPITestAccount
                                                     andAccessToken:kPYAPITestAccessTrustedToken];
    STAssertNotNil(self.connectionTrusted, @"Connection not created.");
    
    
    
}

- (void)testFollowedSlices
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    NOT_DONE(done);
    
    [self.connectionTrusted followedSlicesWithSuccessHandler:^(NSDate *cachedAt, NSArray *slicesList) {
        DONE(done);
    } refreshCacheIfOlderThan:0 failure:^(NSError *error) {
        STFail(@"Error occured when getting followedSlices. %@", error);
        DONE(done);
    }];
 
    
    WAIT_FOR_DONE(done);
    
    
}


@end
