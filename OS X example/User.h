//
//  User.h
//  PryvApiKit
//
//  Created by Victor Kristof on 13.08.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject {
    NSString *_username;
    NSString *_token;
}

@property (retain, readwrite) NSString *username;
@property (retain,readwrite) NSString *token;


-(User*)initWithUsername:(NSString*)u andToken:(NSString*)t;

@end
