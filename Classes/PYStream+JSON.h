//
//  PYStream+JSON.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYStream.h"

@interface PYStream (JSON)

/**
 Get PYStream object from json dictionary representation (JSON representation can include additioanl helper properties for stream). It means that this method 'read' stream from disk and from server
 */
+ (PYStream *)streamFromJSON:(id)json;

/**
 * reset content of this stream with this dictionary (not clientId nor streamId)
 */
- (void)resetFromDictionary:(NSDictionary *)jsonDictionary;

@end
