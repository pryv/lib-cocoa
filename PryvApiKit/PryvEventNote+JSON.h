//
//  PYEventNote+JSON.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvEventNote.h"

@interface PryvEventNote (JSON)

+ (id)noteEventFromDictionary:(NSDictionary *)JSON;

@end
