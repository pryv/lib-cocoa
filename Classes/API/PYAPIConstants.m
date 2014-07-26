//
//  Constants.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/19/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYAPIConstants.h"



#pragma mark - API

NSString *const kPYAPIScheme = @"https";
NSString *const kPYAPIDomain = @".pryv.io";
NSString *const kPYAPIDomainStaging = @".pryv.in";

NSString *const kROUTE_EVENTS = @"events";
NSString *const kROUTE_STREAMS = @"streams";
NSString *const kROUTE_ACCESSES = @"accesses";
NSString *const kROUTE_ACCESSINFOS = @"access-info";
NSString *const kROUTE_PROFILEPUBLIC = @"profile/public";
NSString *const kROUTE_PROFILEAPP = @"profile/app";
NSString *const kROUTE_FOLLOWEDSLICES = @"followed-slices";

NSString *const kPYAPIResponseEvents = @"events";
NSString *const kPYAPIResponseEvent = @"event";
NSString *const kPYAPIResponseStreams = @"streams";
NSString *const kPYAPIResponseStream = @"stream";
NSString *const kPYAPIResponseProfile = @"profile";
NSString *const kPYAPIResponseAccesses = @"accesses";
NSString *const kPYAPIResponseFollowedSlices = @"followedSlices";

NSString *const kPYAPIResponseHeaderApiVersion = @"api-version";

NSString *const kPYAPIResponseMeta = @"meta";
NSString *const kPYAPIResponseMetaServerTime = @"serverTime";

NSString *const kPYAPIConnectionRequestStreamId = @"streamId";
NSString *const kPYAPIConnectionRequestDefaultStreamName = @"defaultName";
NSString *const kPYAPIConnectionRequestAllStreams = @"*";
NSString *const kPYAPIConnectionRequestLevel = @"level";
NSString *const kPYAPIConnectionRequestReadLevel = @"read";
NSString *const kPYAPIConnectionRequestManageLevel = @"manage";
NSString *const kPYAPIConnectionRequestContributeLevel = @"contribute";


NSString *const kPYAPIEventFilterLimit = @"limit";
NSString *const kPYAPIEventFilterFromTime = @"fromTime";
NSString *const kPYAPIEventFilterToTime = @"toTime";
NSString *const kPYAPIEventModifiedSinceTime = @"modifiedSince";
NSString *const kPYAPIEventFilterOnlyStreams = @"streams[]";
NSString *const kPYAPIEventFilterTags = @"tags[]";
NSString *const kPYAPIEventFilterTypes = @"types[]";
NSString *const kPYAPIEventFilterState = @"state";


//Notifications
