//
//  User.m
//  PryvApiKit
//
//  Created by Victor Kristof on 13.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username = _username;
@synthesize token = _token;

-(User *)initWithUsername:(NSString *)u andToken:(NSString *)t{
    self = [super init];
    if (self) {
        self.username = u;
        self.token = t;
    }
    
    return self;
}

@end
