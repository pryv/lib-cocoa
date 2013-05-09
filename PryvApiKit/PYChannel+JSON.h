//
//  PYChannel+JSON.h
//  PryvApiKit
//
//  Created by Nemanja Kovacevic on 3/25/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYChannel (JSON)

+ (PYChannel *) channelFromJson:(id)json;

@end
