//
//  PYFolder+JSON.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYStream (JSON)

/**
 Get PYFolder object from json dictionary representation (JSON representation can include additioanl helper properties for folder). It means that this method 'read' folder from disk and from server
 */
+ (PYStream *)folderFromJSON:(id)json;

@end
