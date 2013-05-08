//
//  PYEventNote.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//


@class PryvEventValueWebclip;
#import <PryvApiKit/PryvApiKit.h>

@interface PryvEventNote : PryvEvent
{
    NSString *_htmlValue;
    NSString *_txtValue;
    PryvEventValueWebclip *_webclipValue;
}

@property (nonatomic, retain) NSString *htmlValue;
@property (nonatomic, retain) NSString *txtValue;
@property (nonatomic, retain) PryvEventValueWebclip *webclipValue;

- (id)initWithType:(PryvEventType *)eventType
         noteValue:(id)noteValue
          folderId:(NSString *)folderId
              tags:(NSArray *)tags
       description:(NSString *)description
        clientData:(NSDictionary *)clientData;

- (NSDictionary *)dictionary;

@end
