//
//  PYConnection.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

NSString const *kUnsyncEventsEventKey       = @"pryv.unsyncevents.Event";
NSString const *kUnsyncEventsRequestKey     = @"pryv.unsyncevents.Request";

#import "PYConstants.h"
#import "PYConnection.h"
#import "PYStream+JSON.h"
#import "PYEvent.h"
#import "PYEvent+Sync.h"
#import "PYAttachment.h"
#import "PYConnection+DataManagement.h"
#import "PYConnection+FetchedStreams.h"
#import "PYConnection+Synchronization.h"
#import "PYCachingController.h"
#import "PYReachability.h"
#import "PYCachingController+Event.h"
#import "PYCachingController+Stream.h"
#import "PYUtils.h"
#import "PYFilter.h"
#import "PYEventFilterUtility.h"
#import "PYError.h"
#import "PYErrorUtility.h"
#import "PYClient.h"

NSString *const kPYConnectionOptionFetchStructure = @"fetchStructure";
NSString *const kPYConnectionOptionFetchAccessInfos = @"fetchAccessInfos";

NSString *const kPYConnectionOptionValueYes = @"yes";
NSString *const kPYConnectionOptionValueNo = @"no";

NSString *const kPYConnectionOfflineUsername = @"_off";

@interface PYConnection ()

@property (nonatomic, readwrite) NSTimeInterval serverTimeInterval;
@property (nonatomic, retain) PYFilter *cacheFilter;
@property (nonatomic, retain) NSTimer *cacheRefreshTimer;
@end

@implementation PYConnection

@synthesize userID = _userID;
@synthesize accessToken = _accessToken;
@synthesize apiDomain = _apiDomain;
@synthesize apiScheme = _apiScheme;
@synthesize apiPort = _apiPort;
@synthesize apiExtraPath = _apiExtraPath;
@synthesize serverTimeInterval = _serverTimeInterval;
@synthesize connectionReachability = _connectionReachability;
@synthesize streamsNotSync = _streamsNotSync;
@synthesize lastTimeServerContact = _lastTimeServerContact;
@synthesize cache = _cache;
@synthesize cacheFilter = _cacheFilter;
@synthesize fetchedStreamsMap = _fetchedStreamsMap;
@synthesize fetchedStreamsRoots = _fetchedStreamsRoots;
@synthesize options = _options;
@synthesize cacheForGetAPIRequests = _cacheForGetAPIRequests;


- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.cacheFilter = [[PYFilter alloc] initWithConnection:self
                                                       fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                         toTime:PYEventFilter_UNDEFINED_TOTIME
                                                          limit:1000000000000
                                                 onlyStreamsIDs:nil
                                                           tags:nil
                                                          types:nil];
        self.cacheFilter.state = PYEventFilter_kStateAll;
        
        self.userID = username;
        self.accessToken = token;
        self.apiDomain = [PYClient defaultDomain];
        self.apiScheme = kPYAPIScheme;
        self.apiExtraPath = @"";
        self.apiPort = 443;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
        self.connectionReachability = [PYReachability reachabilityForInternetConnection];
        [self.connectionReachability startNotifier];
        self.cache = [[[PYCachingController alloc] initWithCachingId:self.idCaching] autorelease];
        [self pyAccessStatus:self.connectionReachability];
        [self setupDeserializeNonSyncList];
        
        self.cacheRefreshTimer= [NSTimer scheduledTimerWithTimeInterval:120.0
                                         target:self
                                       selector:@selector(updateCache:)
                                       userInfo:nil
                                        repeats:YES];
        
        self.cacheForGetAPIRequests = [[NSMutableDictionary alloc] init];
    }
    return self;
}


/**
 * return true if option is activated for key
 */
- (BOOL) optionIsActivatedForKey:(NSString*)optionKey {
    if (! _options) return NO;
    NSString* value = [_options objectForKey:optionKey];
    if (! value) return NO;
    return [kPYConnectionOptionValueYes isEqualToString:value];
}

- (void) setUpWithOptions:(NSDictionary*)optionDict andCallBack:(void(^)(NSError *error))done {
    _options = [NSMutableDictionary dictionaryWithDictionary:optionDict];
    
    dispatch_group_t group = dispatch_group_create();
    
    
    __block NSError* errorFetchStructure;
    if ([self optionIsActivatedForKey:kPYConnectionOptionFetchStructure]) {
        dispatch_group_enter(group);
        [self streamsEnsureFetched:^(NSError *error) {
            errorFetchStructure = error;
            dispatch_group_leave(group);
        }];
        
    }
    
    __block NSError* errorAccessInfos;
    if ([self optionIsActivatedForKey:kPYConnectionOptionFetchAccessInfos]) {
        dispatch_group_enter(group);
        errorAccessInfos = nil;
#warning  TODO fetch accessinfos
            dispatch_group_leave(group);
        
    }
    
    
    // only the first error is sent
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (done) {
            if (errorFetchStructure) return done(errorFetchStructure);
            if (errorAccessInfos) return done(errorAccessInfos);
            done(nil);
        }
    });
    dispatch_release(group);
    
}


- (void) setOnlineModeWithUsername:(NSString *)username andAccessToken:(NSString *)token {
    if (self.userID != kPYConnectionOfflineUsername) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"connection is not an offline connection"] userInfo:nil];
    }
    
    
    self.userID = username;
    self.accessToken = token;
    
    // TODO move cache..
#pragma waring - TODO move cache and others
    
    @throw [NSException exceptionWithName:@"Unimplemented"
                                   reason:[NSString stringWithFormat:@"PYConnection.setOnlineModeWithUsername is not fully implemented"] userInfo:nil];
    
}

- (void)dealloc
{
    [_userID release];
    _userID = nil;
    [_accessToken release];
    _accessToken = nil;
    [_apiDomain release];
    _apiDomain = nil;
    [_apiScheme release];
    _apiScheme = nil;
    [_connectionReachability release];
    _connectionReachability = nil;
    [_streamsNotSync release];
    _streamsNotSync = nil;
    [_cache release];
    _cache = nil;
    [_apiExtraPath release];
    _apiExtraPath = nil;
    [_fetchedStreamsMap release];
    _fetchedStreamsMap = nil;
    [_fetchedStreamsRoots release];
    _fetchedStreamsRoots = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark - streams


- (void)addStream:(PYStream *)stream toUnsyncList:(NSError *)error
{
    /*When we deserialize unsync list (when app starts) we will know what streams are not sync with these informations:
     They have one of these flags or combination of them
     notSyncAdd
     notSyncModify
     */
    [self.streamsNotSync addObject:stream];
    
}


#pragma mark events

- (NSArray*)allEvents
{
    NSArray *allEvents = [self.cache allEvents];
    // set connection property on events
    [allEvents makeObjectsPerformSelector:@selector(setConnection:) withObject:self];
    return allEvents;
}


#warning - refactor
- (void)setupDeserializeNonSyncList
{
    

    NSArray *nonSyncStreamsArray = [self.cache allStreams];
    
    for (PYStream *stream in nonSyncStreamsArray) {
        if (stream.notSyncAdd || stream.notSyncModify) {
            [self.streamsNotSync addObject:stream];
        }
    }
    
    
}


#warning - refactor
- (NSMutableSet *)streamsNotSync
{
    if (!_streamsNotSync) {
        _streamsNotSync = [[NSMutableSet alloc] init];
    }
    
    return _streamsNotSync;
}

#pragma mark - Reachability

//Called by Reachability whenever status changes.

- (void)reachabilityChanged:(NSNotification *)notif
{
	PYReachability* curReach = [notif object];
	NSParameterAssert([curReach isKindOfClass:[PYReachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //No internet
        NSLog(@"No internet");
        _online = NO;
    }else{
        //HAVE Internet
        NSLog(@"HAVE internet");
        _online = YES;
        //[self syncNotSynchedStreamsIfAny];
        [self syncNotSynchedEventsIfAny:^(int successCount, int overEventCount) {
            NSLog(@"synched %i events", successCount);
        }];
    }
}

- (void)pyAccessStatus:(PYReachability *)currReach
{
    if (currReach == self.connectionReachability) {
        if (currReach.currentReachabilityStatus == NotReachable) {
            NSLog(@"No internet, cannot create access");
            _online = NO;
        }else{
            NSLog(@"HAVE internet access created");
            _online = YES;
        }
    }
}

- (NSString *)apiBaseUrl;
{
    return [NSString stringWithFormat:@"%@://%@%@:%@/%@", self.apiScheme, self.userID, self.apiDomain, @(self.apiPort), self.apiExtraPath];
}


- (void) apiRequest:(NSString *)path
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler {
    
    if (self.userID == kPYConnectionOfflineUsername) { // offline mode
        if (failureHandler) {
            failureHandler([PYErrorUtility getAPIUnreachableWithUserInfos:nil]);
        }
        return;
    }
    
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    if (!self.accessToken) {
        NSLog(@"<WARNING> NO Authorization token");
    } else {
        [headers setObject:self.accessToken forKey:@"Authorization"];
    }
    if (path == nil) path = @"";
    NSString* fullPath = [NSString stringWithFormat:@"%@%@",[self apiBaseUrl],path];
    
    [PYClient apiRequest:fullPath
                 headers:headers
                  method:method
                postData:postData
             attachments:attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                     NSDictionary* metas = responseDict[kPYAPIResponseMeta];
                     NSNumber* serverTime = nil;
                     if (metas) {
                         serverTime = [NSNumber numberWithDouble:[metas[kPYAPIResponseMetaServerTime] doubleValue]] ;
                     }
                     
                     if (! serverTime) {
                         NSLog(@"Error cannot find Server-Time in meta path: %@", fullPath);
                     } else {
                         _lastTimeServerContact = [[NSDate date] timeIntervalSince1970];
                         _serverTimeInterval = _lastTimeServerContact - [serverTime doubleValue];
                     }
                     
                     if (successHandler) {
                         successHandler(request, response, responseDict);
                     }
                     
                 }
                 failure:failureHandler];
    
}

- (NSString*) idURL
{
    return [NSString stringWithFormat:@"%@?auth=%@", [self apiBaseUrl], self.accessToken];
}



# pragma mark - cache


- (NSString*) idCaching
{
    return [NSString
            stringWithFormat:@"%@_%@%@_%@_%@",
            [PYUtils md5FromString:self.idURL],
            self.userID, self.apiDomain, self.apiExtraPath, self.accessToken];
}


-(void) streamsEnsureFetched:(void(^)(NSError *error))done {
    if (_fetchedStreamsMap) {
        return done(nil);
    }
    //Return current cached streams
    NSArray *allStreamsFromCache = [self streamsFromCache];
    if (allStreamsFromCache.count > 0) {
        self.fetchedStreamsRoots = allStreamsFromCache;
        [self updateFetchedStreamsMap];
    }
    [self streamsOnlineWithFilterParams:nil successHandler:^(NSArray *streamsList) {
        done(nil);
    } errorHandler:^(NSError *error) {
        done(error);
    }];
}


/**
 Update cached data in the scope of the cache filter
 */
-(void) updateCache:(void(^)(NSError *error))done {
    [self eventsOnlineWithFilter:self.cacheFilter successHandler:^(NSArray *eventList, NSNumber *serverTime, NSDictionary *details) {
        NSLog(@"Synchronized cache with %lu events", [eventList count]);
        self.cacheFilter.modifiedSince = [serverTime doubleValue];
    } errorHandler:^(NSError *error) {
        
    } shouldSyncAndCache:YES];
}

/**
 * Update cached data in the scope of the cache filter is greater than the passed filter
 * @return NO is the cache.filter does not cover this filter
 */
-(BOOL) updateCache:(void(^)(NSError *error))done ifCacheIncludes:(PYFilter*)filter {
    if (! self.cacheFilter) return NO;
    if (! [PYEventFilterUtility filter:filter isIncludedInFilter:self.cacheFilter]) return NO;
    [self updateCache:done];
    return YES;
}


#pragma mark - connectivity


- (BOOL)isOnline
{
    return _online;
}




@end
