//
//  PryvJSONUtils.h
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/4/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

@interface PryvJSONUtils : NSObject{
    
}
-(NSArray*)parseEvents:(NSString*)jsonString;

-(NSArray*)parseEventsWithParser:(NSString*)jsonString :(SBJsonParser *)jsonParser;
@end
