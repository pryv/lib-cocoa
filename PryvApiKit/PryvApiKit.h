//
//  PryvApiKit.h
//  PryvApiKit
//
//  Created by Konstantin Dorodov on 1/30/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

//Temporary
#import "AccessClient.h"

#import <PryvApiKit/PYError.h>
#import <PryvApiKit/PYConstants.h>
#import <PryvApiKit/PYErrorUtility.h>

// Model
#import <PryvApiKit/PYChannel.h>
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventFilter.h>
#import <PryvApiKit/PYAccess.h>
#import <PryvApiKit/PYFolder.h>
#import <PryvApiKit/PYAttachment.h>

// Pryv Api Client
#import <PryvApiKit/PYClient.h>
#import <PryvApiKit/PYEventClient.h>
#import <PryvApiKit/PYCachingController.h>
#import <PryvApiKit/PYEventsCachingUtillity.h>
#import <PryvApiKit/PYChannelsCachingUtillity.h>
#import <PryvApiKit/PYFoldersCachingUtillity.h>

#if TARGET_OS_MAC

#else 
#import <PryvApiKit/PYWebLoginViewController.h>
#endif


