//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "PYStream.h"
#import "PYConnection.h"


@implementation PYStream

@synthesize connection = _connection;
@synthesize streamId = _streamId;
@synthesize name = _name;
@synthesize parentId = _parentId;
@synthesize clientData = _clientData;
@synthesize timeCount = _timeCount;
@synthesize children = _children;
@synthesize singleActivity = _singleActivity;
@synthesize trashed = _trashed;

@synthesize isSyncTriedNow = _isSyncTriedNow;
@synthesize hasTmpId = _hasTmpId;
@synthesize notSyncAdd = _notSyncAdd;
@synthesize notSyncModify = _notSyncModify;
@synthesize synchedAt = _synchedAt;
@synthesize modifiedStreamPropertiesAndValues = _modifiedStreamPropertiesAndValues;

- (void)dealloc
{
    [_streamId release];
    [_name release];
    [_parentId release];
    [_clientData release];
    [super dealloc];
}

- (NSDictionary *)cachingDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if (_streamId && _streamId.length > 0) {
        [dic setObject:_streamId forKey:@"id"];
    }
    
    if (_name && _name.length > 0) {
        [dic setObject:_name forKey:@"name"];
    }

    if (_parentId && _parentId.length > 0) {
        [dic setObject:_parentId forKey:@"parentId"];
    }
                
    if (_clientData && _clientData.count > 0) {
        [dic setObject:_clientData forKey:@"clientData"];
    }

    [dic setObject:[NSNumber numberWithBool:_singleActivity] forKey:@"singleActivity"];
    [dic setObject:[NSNumber numberWithBool:_trashed] forKey:@"trashed"];
    [dic setObject:[NSNumber numberWithBool:_hasTmpId] forKey:@"hasTmpId"];
    [dic setObject:[NSNumber numberWithBool:_notSyncAdd] forKey:@"notSyncAdd"];
    [dic setObject:[NSNumber numberWithBool:_notSyncModify] forKey:@"notSyncModify"];
    [dic setObject:[NSNumber numberWithDouble:_synchedAt] forKey:@"synchedAt"];
    if (_modifiedStreamPropertiesAndValues) {
        [dic setObject:_modifiedStreamPropertiesAndValues forKey:@"modifiedProperties"];
    }
    
    return [dic autorelease];
}


- (NSDictionary *)dictionary {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
    if (_streamId && _streamId.length > 0) {
        [dic setObject:_streamId forKey:@"id"];
    }
    
    if (_name && _name.length > 0) {
        [dic setObject:_name forKey:@"name"];
    }
    
    if (_parentId && _parentId.length > 0) {
        [dic setObject:_parentId forKey:@"parentId"];
    }
    
    if (_clientData && _clientData.count > 0) {
        [dic setObject:_clientData forKey:@"clientData"];
    }
    
    [dic setObject:[NSNumber numberWithBool:_singleActivity] forKey:@"singleActivity"];
    
    return [dic autorelease];
    
}

-(NSString *)description{
    NSMutableString *description = [NSMutableString stringWithString:@""];
    
    [description appendString:@"<"];
    [description appendFormat:@"%@",_name];
    [description appendFormat:@" (%@)",_streamId];
    
    if (_singleActivity) {
        [description appendString:@" is single activity"];
    }
    if (_parentId) {
        [description appendFormat:@" in %@",_parentId];
    }
    if ([_children count] > 0) {
        [description appendFormat:@" with children %@",_children];
    }
    [description appendString:@">"];
    return description;
}

@end