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
NSString *const kPYAPIDomainStaging = @".rec.la";

NSString *const kROUTE_CHANNELS = @"channels";
NSString *const kROUTE_EVENTS = @"events";
NSString *const kROUTE_FOLDERS =@"folders";




NSString *const kPrYvChannelEventFilterLimit = @"limit";
NSString *const kPrYvChannelEventFilterFromTime = @"fromTime";
NSString *const kPrYvChannelEventFilterToTime = @"toTime";
NSString *const kPrYvChannelEventFilterOnlyFolders = @"onlyFolders";


// the following should not be set as constants
NSString *const kPYUserTempToken = @"Ve69mGqqX5";
NSString *const kPYUserTempTokenMladen = @"PeySaPzMsM";

NSString *const kPrYvApplicationChannelId = @"position";
NSString *const kPrYvApplicationChannelName = @"Position";