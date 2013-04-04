//
//  PYEventValueWebclip.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/1/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEventValueWebclip : NSObject
{
    NSString *_url;
    NSString *_content;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *content;

+ (PYEventValueWebclip *)webclipFromDictionary:(NSDictionary *)JSON;
- (id)initWithUrl:(NSString *)url content:(NSString *)content;

@end
