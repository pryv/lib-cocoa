//
//  EventTypes.m
//  PryvApiKit
//
//  Created by Perki on 28.11.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventTypes.h"
#import "PYEventType.h"
#import "PYEventClass.h"
#import "PYEventTypesPackagedData.h"
#import "PYEvent.h"
#import "PYMeasurementSet.h"
#import "PYAsyncService.h"

// for staging:
// static NSString *const  kMeasurementSetsUrl = @"https://sw.pryv/dist/data-types/";
static NSString *const  kMeasurementSetsUrl = @"https://d1kp76srklnnah.cloudfront.net/dist/data-types/";
static NSString *const  kMeasurementSetsHierarchical = @"hierarchical.json";
static NSString *const  kMeasurementSetsExtras = @"extras.json";

@interface PYEventTypes ()


- (void)setup;
- (void)updateFlatAndKlasses;
- (void)changeNSDictionary:(NSDictionary**) dict withContentOfJSONString:(id) jsonString;

- (void)loadFile:(NSString*) filename withSuccess:(void (^)(NSDictionary* jsonDict))successHandler;

@end

@implementation PYEventTypes

@synthesize hierarchical = _hierarchical;
@synthesize extras = _extras;

@synthesize flat = _flat;
@synthesize klasses = _klasses;
@synthesize measurementSets = _measurementSets;


+ (PYEventTypes*)sharedInstance
{
    static PYEventTypes *s_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[PYEventTypes alloc] init];
        [s_sharedInstance setup];
    });
    return s_sharedInstance;
}


- (void)setup
{
    
    _hierarchical = [[NSDictionary alloc] init];
    [self changeNSDictionary:&_hierarchical withContentOfJSONString:PYEventTypesPackagedData.hierarchical];
    
    
    _extras = [[NSDictionary alloc] init];
    [self changeNSDictionary:&_extras withContentOfJSONString:PYEventTypesPackagedData.extras];
    
    _flat = [[NSMutableDictionary alloc] init];
    _klasses = [[NSMutableDictionary alloc] init];
    [self updateFlatAndKlasses];
    
    
    _measurementSets = [[NSMutableArray alloc] init];
    [self updateMeasurementSets];
    
    
    // try to get online measurement sets
    [self updateFromOnlineSourceWithSuccess:nil];
}



/**
 * Update _flat reference table from hierachical data
 */
- (void)updateFlatAndKlasses
{
    [_flat removeAllObjects];
    [_klasses removeAllObjects];
    
    NSDictionary *classes = [_hierarchical objectForKey:@"classes"];
    for(NSString *classKey in [classes allKeys])
    {
        
        PYEventClass *klass = [[PYEventClass alloc] initWithClassKey:classKey
                                             andDefinitionDictionary:[classes objectForKey:classKey]];
        [_klasses setObject:klass forKey:classKey];
        
        NSDictionary *formats = [[classes objectForKey:classKey] objectForKey:@"formats"];
        for(NSString *formatKey in [formats allKeys])
        {
            PYEventType* eventType = [[PYEventType alloc] initWithClass:klass
                                                           andFormatKey:formatKey
                                                andDefinitionDictionary:[formats objectForKey:formatKey]];
            
            [_flat setObject:eventType forKey:eventType.key];
            [eventType release];
        }
        
        [klass release];
    }
    
    // --- add extras
    NSDictionary *extras = [_extras objectForKey:@"extras"];
    for(NSString *classKey in [extras allKeys])
    {
        NSDictionary *klassExtras = [extras objectForKey:classKey];
        
        PYEventClass *klass = [_klasses objectForKey:classKey];
        if (! klass) {
            NSLog(@"WARNING .. PYEventTypes.updateFlat+extras cannot find %@ in _klasses", classKey);
        } else {
            [klass addExtrasDefinitionsFromDictionary:klassExtras];
        }
        
        NSDictionary *formats = [klassExtras objectForKey:@"formats"];
        for(NSString *formatKey in [formats allKeys])
        {
            PYEventType* eventType = [_flat objectForKey:[NSString stringWithFormat:@"%@/%@",
                                                          classKey, formatKey]];
            if (! eventType) {
                NSLog(@"WARNING .. PYEventTypes.updateFlat+extras cannot find %@/%@ in _flat",
                      classKey, formatKey);
            } else {
                [eventType addExtrasDefinitionsFromDictionary:[formats objectForKey:formatKey]];
            }
        }
    }
    
}

/**
 * Update _measurementSets reference table from extras data
 */
- (void)updateMeasurementSets
{
    [self.measurementSets removeAllObjects];

    NSDictionary *setsJSON = [_extras objectForKey:@"sets"];
    for(NSString *setKey in [setsJSON allKeys])
    {
        PYMeasurementSet *measurement = [[PYMeasurementSet alloc] initWithKey:setKey
                                                                andDictionary:[setsJSON objectForKey:setKey]
                                                             andPYEventsTypes:self];
        [self.measurementSets addObject:measurement];
        [measurement release];
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


- (void)updateFromOnlineSourceWithSuccess:(void (^)(NSDictionary* hierarchical, NSDictionary* extras))successHandler
{
    __block NSDictionary* hierarchical;
    __block NSDictionary* extras;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self loadFile:kMeasurementSetsHierarchical withSuccess:^(NSDictionary *jsonDict) {
        hierarchical = jsonDict;
#warning check that reatin is wisely used..
        [hierarchical retain];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self loadFile:kMeasurementSetsExtras withSuccess:^(NSDictionary *jsonDict) {
        extras = jsonDict;
        [extras retain];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (hierarchical && extras) {
            NSLog(@"<INFO> Loaded dataypes files hierachical: %@, extras: %@",
                  [hierarchical objectForKey:@"version"], [extras objectForKey:@"version"]);
            
            self.hierarchical = hierarchical;
            self.extras = extras;
            
            [self updateFlatAndKlasses];
            [self updateMeasurementSets];
            
        }
        if (successHandler) successHandler(hierarchical, extras);
    });
    dispatch_release(group);
}

/**
 * DO not throw errors just nil on any failure
 */
- (void)loadFile:(NSString*) filename withSuccess:(void (^)(NSDictionary* jsonDict))successHandler
{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kMeasurementSetsUrl,filename]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [PYAsyncService JSONRequestServiceWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, id JSON) {
        if([JSON isKindOfClass:[NSDictionary class]]) {
            NSDictionary* jsonDict = (NSDictionary*) JSON;
            if ([jsonDict objectForKey:@"version"]) {
                if (successHandler) {
                    successHandler(jsonDict);
                    return;
                }
            }
            NSLog(@"<WARNING> PYEventTypes: Failed to load %@, cannot find version", filename);
        } else {
            NSLog(@"<WARNING> PYEventTypes: Failed to load %@, is not a dictionary", filename);
        }
        if (successHandler) successHandler(nil);
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, NSMutableData *responseData) {
        NSLog(@"<WARNING> PYEventTypes: Failed to load %@ with error %@", filename, error);
        if (successHandler) successHandler(nil);
    }];
}




- (PYEventType *)pyTypeForEvent:(PYEvent*)event
{
    return [self pyTypeForString:event.type];
}

- (PYEventType *)pyTypeForString:(NSString *)typeKey
{
    //TODO either generate an error if unkown or return an "uknown event structure"
    return [_flat objectForKey:typeKey];
}

- (PYEventClass *)pyClassForString:(NSString *)classKey
{
    //TODO either generate an error if unkown or return an "uknown event structure"
    PYEventClass* result = [_klasses objectForKey:classKey];
    if (! result) {
        NSLog(@"WARNING: pyClassForString cannot find class with key %@", classKey);
    }
    
    return result;
}



- (void)dealloc
{
    [_hierarchical release];
    [_extras release];
    [_flat release];
    [_klasses release];
    [_measurementSets release];

    [super dealloc];
}

@end
