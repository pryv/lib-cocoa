//
//  Constants.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/19/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const kLanguageCodeDefault;

#pragma mark - API

FOUNDATION_EXPORT NSString *const kPYAPIScheme;
FOUNDATION_EXPORT NSString *const kPYAPIDomain;
FOUNDATION_EXPORT NSString *const kPYAPIDomainStaging;

FOUNDATION_EXPORT NSString *const kROUTE_EVENTS;
FOUNDATION_EXPORT NSString *const kROUTE_STREAMS;
FOUNDATION_EXPORT NSString *const kROUTE_ACCESSES;


NSString *const kPYAPIResponseEvents;
NSString *const kPYAPIResponseEvent;
NSString *const kPYAPIResponseStreams;
NSString *const kPYAPIResponseStream;
NSString *const kPYAPIResponseMeta;
NSString *const kPYAPIResponseMetaServerTime;
NSString *const kPYAPIResponseAccesses;

FOUNDATION_EXPORT NSString *const kPYAPIConnectionRequestStreamId;
FOUNDATION_EXPORT NSString *const kPYAPIConnectionRequestAllStreams;
FOUNDATION_EXPORT NSString *const kPYAPIConnectionRequestLevel;
FOUNDATION_EXPORT NSString *const kPYAPIConnectionRequestReadLevel;
FOUNDATION_EXPORT NSString *const kPYAPIConnectionRequestManageLevel;
FOUNDATION_EXPORT NSString *const kPYAPIConnectionRequestContributeLevel;


FOUNDATION_EXPORT NSString *const kPYAPIEventFilterLimit;
FOUNDATION_EXPORT NSString *const kPYAPIEventFilterOnlyStreams;
FOUNDATION_EXPORT NSString *const kPYAPIEventFilterFromTime;
FOUNDATION_EXPORT NSString *const kPYAPIEventFilterToTime;
FOUNDATION_EXPORT NSString *const kPYAPIEventModifiedSinceTime;
FOUNDATION_EXPORT NSString *const kPYAPIEventFilterTags;
FOUNDATION_EXPORT NSString *const kPYAPIEventFilterTypes;
FOUNDATION_EXPORT NSString *const kPYAPIEventFilterState;

FOUNDATION_EXPORT NSString *const kPYWebViewLoginNotVisibleNotification;


FOUNDATION_EXPORT NSString *const kPYNotificationStreams;
FOUNDATION_EXPORT NSString *const kPYNotificationEvents;
FOUNDATION_EXPORT NSString *const kPYNotificationKeyAdd;
FOUNDATION_EXPORT NSString *const kPYNotificationKeyModify;
FOUNDATION_EXPORT NSString *const kPYNotificationKeyDelete;
FOUNDATION_EXPORT NSString *const kPYNotificationKeyUnchanged;
FOUNDATION_EXPORT NSString *const kPYNotificationWithFilter;

