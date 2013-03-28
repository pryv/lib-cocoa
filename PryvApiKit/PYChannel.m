//
//  Channel.m
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYChannel.h"
#import "PYFolder+JSON.h"


@implementation PYChannel

@synthesize access = _access;
@synthesize channelId = _channelId;
@synthesize name = _name;
@synthesize timeCount = _timeCount;
@synthesize clientData = _clientData;
@synthesize enforceNoEventsOverlap = _enforceNoEventsOverlap;
@synthesize trashed = _trashed;

- (void)dealloc
{
    [_access release];
    [_channelId release];
    [_name release];
    [_clientData release];
    [super dealloc];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.id=%@", self.channelId];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.clientData=%@", self.clientData];
    [description appendFormat:@", self.enforceNoEventsOverlap=%d", self.enforceNoEventsOverlap];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendString:@">"];
    return description;
}

#pragma mark - PrYv API Folder get all (GET /{channel-id}/folders/)

- (void)getFoldersWithRequestType:(PYRequestType)reqType
                     filterParams:(NSString *)filter
                   successHandler:(void (^)(NSArray *folderList))successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler;
{
    NSMutableString *pathString = [NSMutableString stringWithFormat:@"/%@/folders", self.channelId];
    if (filter) {
        [pathString appendFormat:@"?%@",filter];
    }
    [PYClient apiRequest:[pathString copy]
                  access:self.access
                 requestType:reqType
                      method:PYRequestMethodGET
                    postData:nil
                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSMutableArray *folderList = [[NSMutableArray alloc] init];
                         for (NSDictionary *folderDictionary in JSON) {
                             PYFolder *folderObject = [PYFolder folderFromJSON:folderDictionary];
                             [folderList addObject:folderObject];
                         }
                         if (successHandler) {
                             successHandler(folderList);
                         }
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
}


#pragma mark - PrYv API Folder create (POST /{channel-id}/folders/)

- (void)createFolderWithId:(NSString *)folderId
                      name:(NSString *)folderName
                  parentId:(NSString *)parentId
                  isHidden:(BOOL)hidden
                 isTrashed:(BOOL)trashed
          customClientData:(NSDictionary *)clientData
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)(NSString *createdFolderId))successHandler
              errorHandler:(void (^)(NSError *error))errorHandler;
{
    
    NSMutableString *pathString = [NSMutableString stringWithFormat:@"/%@/folders", self.channelId];
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:folderId forKey:@"id"];
    [postData setObject:folderName forKey:@"name"];
    [postData setObject:self.channelId forKey:@"channelId"];
        
    if (parentId) {
        [postData setObject:parentId forKey:@"parentId"];
    }
    
    if (clientData) {
        [postData setObject:clientData forKey:@"clientData"];
    }
    
    if (hidden) {
        [postData setObject:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
    }
    
    if (trashed) {
        [postData setObject:[NSNumber numberWithBool:trashed] forKey:@"trashed"];
    }
    
    [PYClient apiRequest:[pathString copy]
                  access:self.access
                 requestType:reqType
                      method:PYRequestMethodPOST
                    postData:[postData autorelease]
                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSString *createdFolderId = [JSON objectForKey:@"id"];
                         if (successHandler) {
                             successHandler(createdFolderId);
                         }
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
    
}


#pragma mark - PrYv API Folder modify (PUT /{channel-id}/folders/{folder-id})

- (void)renameFolderId:(NSString *)folderId
       withRequestType:(PYRequestType)reqType
     withNewFolderName:(NSString *)folderName
        successHandler:(void(^)(NSString *createdFolderId, NSString *newFolderName))successHandler
          errorHandler:(void(^)(NSError *error))errorHandler;
{
    
    
    //    [self apiRequest:[NSString stringWithFormat:@"%@/%@/folders/%@", [self apiBaseUrl], self.channelId, folderId]
    //              method:@"PUT"
    //            postData:@{@"name": newFolderName}
    //      successHandler:^(NSDictionary *jsonData, NSHTTPURLResponse *response) {
    //          if (successHandler) successHandler(folderId, newFolderName)
    //              }
    //        errorHandler:errorHandler
    //     ]
    
}


@end
