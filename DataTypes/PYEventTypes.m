//
//  EventTypes.m
//  PryvApiKit
//
//  Created by Perki on 28.11.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventTypes.h"
#import "PYEventTypesPackagedData.h"
#import "PYEvent.h"


#define kMeasurementSetsUrl @"http://pryv.github.io/event-types/extras.json"

@interface PYEventTypes ()


- (void)initObject;
- (void)executeCompletionBlockOnMainQueue:(PYEventTypesCompletionBlock)completionBlock withObject:(id)object andError:(NSError*)error;

@end


@implementation PYEventTypes {
    NSDictionary* _hierarchical;
    NSMutableDictionary* _flat;
    NSDictionary* _extras;
}


+ (PYEventTypes*)sharedInstance
{
    static PYEventTypes *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PYEventTypes alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}


- (void)initObject
{
    _flat = [[NSMutableDictionary alloc] init];
    _hierarchical = [[NSDictionary alloc] init];
    [self changeNSDictionary:&_hierarchical withContentOfJSONString:PYEventTypesPackagedData.hierarchical];
    _extras = [[NSDictionary alloc] init];
    [self updateFlat];
    [self changeNSDictionary:&_extras withContentOfJSONString:PYEventTypesPackagedData.extras];
}

/**
 * Update _flat reference table from hierachical data
 */
- (void)updateFlat
{
    [_flat removeAllObjects];
    
    NSDictionary *classes = [_hierarchical objectForKey:@"classes"];
    for(NSString *classKey in [classes allKeys])
    {
        NSDictionary *formats = [[classes objectForKey:classKey] objectForKey:@"formats"];
        for(NSString *formatKey in [formats allKeys])
        {
            [_flat setObject:[formats objectForKey:formatKey]
                      forKey:[NSString stringWithFormat:@"%@/%@", classKey, formatKey]];
        }
    }
}

-(void) changeNSDictionary:(NSDictionary**) dict withContentOfJSONString:(id) jsonString
{
    [*dict release];
    NSError *e = nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    *dict = [NSJSONSerialization JSONObjectWithData: data options:kNilOptions error: &e];
    if (! *dict) {
        NSLog(@"Failed parsing JSON string to NSDictionary %@", e);
    }
    [*dict retain];
}


- (void)reloadWithCompletionBlock:(PYEventTypesCompletionBlock)completionBlock
{
    
    // TODO if connection reload if not online use pakaged set..
    
    /**
     NSURL *measurementSetsURL = [NSURL URLWithString:kMeasurementSetsUrl];
     NSURLRequest *request = [[NSURLRequest alloc] initWithURL:measurementSetsURL];
    [PYClient sendRequest:request withReqType:PYRequestTypeSync success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
    }
      [self executeCompletionBlockOnMainQueue:completionBlock withObject:result andError:nil];
     } failure:^(NSError *error) {
         [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
     }];
     **/
    
    [self executeCompletionBlockOnMainQueue:completionBlock withObject:self andError:nil];
}


- (NSDictionary*) hierarchical
{
    return _hierarchical;
}

- (NSDictionary*) extras
{
    return _extras;
}


- (NSDictionary*) definitionForPYEvent:(PYEvent*)event
{
    //TODO either generate an error if unkown or return an "uknown event structure"
    return [_flat objectForKey:event.type];
}

- (BOOL)isNumerical:(PYEvent*)event
{
    NSDictionary* def = [self definitionForPYEvent:event];
    return [@"number" isEqualToString:[def objectForKey:@"type"]];
}





- (void)executeCompletionBlockOnMainQueue:(PYEventTypesCompletionBlock)completionBlock withObject:(id)object andError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock)
        {
            completionBlock(object, error);
        }
    });
}

@end
