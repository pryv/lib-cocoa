//
//  Constants.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/19/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYConstants.h"

#pragma mark - API

NSString *const kPYAPIScheme = @"https";
NSString *const kPYAPIDomain = @".pryv.io";
NSString *const kPYAPIDomainStaging = @".pryv.in";

NSString *const kROUTE_EVENTS = @"events";
NSString *const kROUTE_FOLDERS = @"folders";
NSString *const kROUTE_STREAMS = @"streams";

NSString *const kPYAPIConnectionRequestStreamId = @"streamId";
NSString *const kPYAPIConnectionRequestAllStreams = @"*";
NSString *const kPYAPIConnectionRequestLevel = @"level";
NSString *const kPYAPIConnectionRequestReadLevel = @"read";
NSString *const kPYAPIConnectionRequestManageLevel = @"manage";
NSString *const kPYAPIConnectionRequestContributeLevel = @"contribute";



NSString *const kPrYvChannelEventFilterLimit = @"limit";
NSString *const kPrYvChannelEventFilterFromTime = @"fromTime";
NSString *const kPrYvChannelEventFilterToTime = @"toTime";
NSString *const kPrYvChannelEventFilterOnlyFolders = @"onlyFolders[]";
NSString *const kPrYvChannelEventFilterTags = @"tags[]";


// the following should not be set as constants
NSString *const kPYUserTempToken = @"Ve69mGqqX5";
NSString *const kPYUserTempTokenMladen = @"PeySaPzMsM";

NSString *const kPrYvApplicationChannelId = @"position";
NSString *const kPrYvApplicationChannelName = @"Position";

//Notifications
NSString *const kPYWebViewLoginNotVisibleNotification = @"PYWebViewLoginNotVisibleNotification";