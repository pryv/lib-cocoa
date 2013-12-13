//
//  Constants.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/19/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYConstants.h"

NSString *const kLanguageCodeDefault = @"en";

#pragma mark - API

NSString *const kPYAPIScheme = @"https";
NSString *const kPYAPIDomain = @".pryv.io";
NSString *const kPYAPIDomainStaging = @".pryv.in";

NSString *const kROUTE_EVENTS = @"events";
NSString *const kROUTE_STREAMS = @"streams";

NSString *const kPYAPIConnectionRequestStreamId = @"streamId";
NSString *const kPYAPIConnectionRequestAllStreams = @"*";
NSString *const kPYAPIConnectionRequestLevel = @"level";
NSString *const kPYAPIConnectionRequestReadLevel = @"read";
NSString *const kPYAPIConnectionRequestManageLevel = @"manage";
NSString *const kPYAPIConnectionRequestContributeLevel = @"contribute";


NSString *const kPYAPIEventFilterLimit = @"limit";
NSString *const kPYAPIEventFilterFromTime = @"fromTime";
NSString *const kPYAPIEventFilterToTime = @"toTime";
NSString *const kPYAPIEventFilterOnlyStreams = @"onlyStreams[]";
NSString *const kPYAPIEventFilterTags = @"tags[]";


//Notifications
NSString *const kPYWebViewLoginNotVisibleNotification = @"PYWebViewLoginNotVisibleNotification";