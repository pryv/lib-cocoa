//
//  PYEventValueWebclip.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/1/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvEventValueWebclip.h"

@implementation PryvEventValueWebclip

@synthesize url = _url;
@synthesize content = _content;

+ (PryvEventValueWebclip *)webclipFromDictionary:(NSDictionary *)JSON
{
    PryvEventValueWebclip *webclipValue = [[PryvEventValueWebclip alloc] init];
    webclipValue.url = [JSON objectForKey:@"url"];
    webclipValue.content = [JSON objectForKey:@"content"];
    return webclipValue;
}

- (id)initWithUrl:(NSString *)url content:(NSString *)content
{
    self = [super init];
    if (self) {
        _url = url;
        _content = content;
    }
    
    return self;
}

@end
