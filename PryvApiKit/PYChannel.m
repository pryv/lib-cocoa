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

- (void)createFolderId:(NSString *)folderId
       withRequestType:(PYRequestType)reqType
              withName:(NSString *)folderName
        successHandler:(void (^)(NSString *createdFolderId, NSString *createdFolderName))successHandler
          errorHandler:(void (^)(NSError *error))errorHandler;
{
    
    NSMutableString *pathString = [NSMutableString stringWithFormat:@"/%@/folders", self.channelId];
    NSDictionary *postData = @{@"name" : folderName,
                               @"id" : folderId
                               };
    
    [PYClient apiRequest:[pathString copy]
                  access:self.access
                 requestType:reqType
                      method:PYRequestMethodPOST
                    postData:postData
                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                         NSLog(@"JSON %@",JSON);
                     } failure:^(NSError *error) {
                         if (errorHandler) {
                             errorHandler (error);
                         }
                     }];
    
    
    //    [self apiRequest:[NSString stringWithFormat:@"%@/%@/folders", [self apiBaseUrl], self.channelId]
    //              method:@"POST"
    //            postData:@{@"name": folderName, @"id" : folderId}
    //      successHandler:successHandler:^(NSDictionary *jsonData, NSHTTPURLResponse *response) {
    //          if (successHandler) successHandler(folderName, folderId)
    //              }
    //        errorHandler:errorHandler
    //     ]
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
