# Pryv iOS/OSX Cocoa SDK

**PryvApiKit is an OS X framework and an iOS static library. It handles all networking and interactions with Pryv API for your Objective-C based applications.**

## PryvApiKit.framework

This framework Mac OS X lets you interact with the Pryv servers from your Mac OS X application.
First of all, you need to create a WebView object `myWebView` that you locate in a window, a panel, a view or whatever you think will be appropriate and make one of your controller a `PYWebLoginDelegate` – typically, the WebView controller. You can then obtain your access token with your app ID using the following lines.

	NSArray *objects = [NSArray arrayWithObjects:@"*", @"manage", nil];
	NSArray *keys = [NSArray arrayWithObjects:@"channelId", @"level", nil];
	NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
	
After this preparation, you actually request an access token with these two lines :
	
	[PYClient setDefaultDomainStaging];
	[PYWebLoginViewController requestAccessWithAppId:@"pryv-sdk-osx-example"
                                     andPermissions:permissions
                                           delegate:self
                                           withWebView:&myWebView];
        
The first one is needed whenever you need to (re-)log a user. Notice in the second method that you pass the reference of your WebView object which will be displayed where you located it asking for username and password. If everything went good, you'll manage the response in the delegate method :

	- (void) pyWebLoginSuccess:(PYAccess*)pyAccess {
	    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
	    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
	}
	
Otherwise, you can manage abortion and error using the methods `- (void) pyWebLoginAborded:(NSString*)reason` and `- (void) pyWebLoginError:(NSError*)error`.

## LibPryvApiKit.a
This is a static library to be used for iOS. Usage is pretty straightforward. First of all, you need to obtain access token. To achieve this, you should set up a permission array in which you specify what channels you need and what access for those channels you ask for, like this :

	NSArray *objects = [NSArray arrayWithObjects:@"*", @"manage", nil];
	NSArray *keys = [NSArray arrayWithObjects:@"channelId", @"level", nil];
	    
	NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];

After this preparation, you actually request for an access token using this method :
	
	[PYClient setDefaultDomainStaging];
    [PYWebLoginViewController requestAccessWithAppId:@"pryv-sdk-ios-example"
                                     andPermissions:permissions
                                           delegate:self];

The first line is needed whenever you need to (re-)log a user. Here you are sending the `appId` and an array of permissions. An instance of `UIWebView` will pop up and will ask the user for username and password. If everything went ok, you'll get response in the delegate method.

	- (void) pyWebLoginSuccess:(PYAccess*)pyAccess {
	    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
	    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
	}
	
Otherwise, you can manage abortion and error using the methods `- (void) pyWebLoginAborded:(NSString*)reason` and `- (void) pyWebLoginError:(NSError*)error`.

##PryvApiKit : Main Methods
*Compatible with iOS and Mac OS X.*

The user ID and the access token are used for creating PYAccess object.

	PYAccess *access = [PYClient createAccessWithUsername:@"username" andAccessToken:@"accessToken"];

With `PYAccess` objects, you can browse channels, folders and events with the permissions you have in access token.

	   [access getAllChannelsWithRequestType:PYRequestTypeAsync gotCachedChannels:^(NSArray *cachedChannelList) {
	       
	   } gotOnlineChannels:^(NSArray *onlineChannelList) {
	       
	   } errorHandler:^(NSError *error) {
	       
	   }];

This library can work offline if caching is enabled. To enable/disable caching possibility you set the preprocessor macro `CACHE` in project file to 1/0 depending on whether or not you want caching support.

`cachedChannelList` and `onlineChannelList` contain `PYChannel` objects. A channel contains `PYFolder` and `PYEvent` objects.

You can manipulate channels, folders and events. For example, you can create, delete, modify, … events. Same rules applie for other object types. Currently only personal type of access allows creating channels and it will be added for v2 of SDK when access-rights will be covered in depth.

###Some useful `PYChannel` methods:

Example of getting all events:

    [channel getAllEventsWithRequestType:PYRequestTypeAsync gotCachedEvents:^(NSArray *cachedEventList) {
        
    } gotOnlineEvents:^(NSArray *onlineEventList) {
        
    } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
        
    } errorHandler:^(NSError *error) {
        
    }];

Example of creating event on server:

    PYEvent *event = [[PYEvent alloc] init];
    event.folderId = @"someFolderId";
    event.value = @"someEventValue";
    event.eventClass = @"note";
    event.eventFormat = @"txt";
    event.tags = @[@"tag1", @"tag2", @"tag3"];
    event.clientData = @{@"clDataKey": @"clientDataObject"};

    [channel createEvent:event
             requestType:PYRequestTypeAsync
          successHandler:^(NSString *newEventId, NSString *stoppedId) {
        
    } errorHandler:^(NSError *error) {
        
    }];
                
Example of modifying event data on server. You create an event object with the properties you want to modify. In the example below, we are sending events with id "someEventId" to folder with id "someFolderId" and we are changing event `value` property.

    PYEvent *event = [[PYEvent alloc] init];
    event.folderId = @"someFolderId";
    event.value = @"someEventValue";

    [channel setModifiedEventAttributesObject:event
                                   forEventId:@"someEventId"
                                  requestType:PYRequestTypeAsync
                               successHandler:^(NSString *stoppedId) {
        
    } errorHandler:^(NSError *error) {
        
    }];


Example of getting events from server with filter. This particular filter will search for events recorded in the last 60 days, ones that are in specific `folderId` and tagged with `tag2`. List of events will be limited to 10 results. If caching is enabled for library it will automatically sync events with ones from cache and give you result of synchronization.

	   NSDate *today = [NSDate date];
	   NSCalendar *cal = [NSCalendar currentCalendar];
	   NSDateComponents *components = [[NSDateComponents alloc] init];
	   [components setDay:-60];
	   NSDate *fromTime = [cal dateByAddingComponents:components toDate:today options:0];
	   NSDate *toTime = today;
	   PYEventFilter *eventFilter = [[PYEventFilter alloc] initWithChannel:channel
	                                                              fromTime:[fromTime timeIntervalSince1970]
	                                                                toTime:[toTime timeIntervalSince1970]
	                                                                 limit:10
	                                                        onlyFoldersIDs:@[@"folderId"]
	                                                                  tags:@[@"tag2"]];
	   
	   [eventFilter getEventsWithRequestType:PYRequestTypeSync gotCachedEvents:^(NSArray *eventList) {
	       NSLog(@"cached eventList %@",eventList);
	   } gotOnlineEvents:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
	       NSLog(@"eventsToAdd %@",eventsToAdd);
	       NSLog(@"eventsToRemove %@",eventsToRemove);
	       NSLog(@"eventModified %@",eventModified);
	   } errorHandler:^(NSError *error) {
	       NSLog(@"error is %@",error);
	   }];

In a similar way, you manipulate folders.

###Some useful `PYFolder` methods

Getting all folders from current channel:

	[channel getAllFoldersWithRequestType:PYRequestTypeAsync
	                         filterParams:nil
	                     gotCachedFolders:^(NSArray *cachedFoldersList) {
	    
	} gotOnlineFolders:^(NSArray *onlineFolderList) {
	    
	} errorHandler:^(NSError *error) {
	    
	}];
	
Creating folder in current channel:

    PYFolder *folder = [[PYFolder alloc] init];
    folder.name = @"someFolderName";
                
    [channel createFolder:folder withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdFolderId) {
        
    } errorHandler:^(NSError *error) {
        
    }];

If you want to change name of previously created folder above, you do this :

    PYFolder *folder = [[PYFolder alloc] init];
    folder.name = @"someFolderNameChanged";
    [channel setModifiedFolderAttributesObject:folder
                                   forFolderId:createdFolderId
                                   requestType:PYRequestTypeAsync successHandler:^{
        
    } errorHandler:^(NSError *error) {
        
    }];

You can trash/delete folder in this way:

    [channel trashOrDeleteFolderWithId:createdFolderId filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
        
    } errorHandler:^(NSError *error) {
        
    }];

###Some words about caching
If caching is enabled for library, channels, folders or events requested from server will be cached automatically. If you want to create an event and you get successful response, that event will be cached automatically for you. Same rules apply for other types. If you are offline, the library still works. All channels, folders or events will be cached on disk with tempId and will be put in unsync list. When internet turns on, the unsync list will be synched with server and all events, folders or channels will be cached automatically. Developers don't need to care about caching, all process about it is done in background. Developers should use public API methods as usual. From my pov I'll rather take out `gotCachedFolders` `gotCachedEvents` and `gotCachedChannels` callbacks because I think it's unnecessary. Everything can be in one callback… Perki, what do you think about it?

Also, there are some testing classes that are testing whether or not Objective-C public API works with web service. To perform those tests start iOS example in simulator first. After this step, stop the simulator and choose libPryvApiKit.a scheme. Go to Product->Test in xCode. 


## License

[Revised BSD license](https://github.com/pryv/documents/blob/master/license-bsd-revised.md)
