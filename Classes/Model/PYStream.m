//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "PYStream.h"
#import "PYConnection.h"
#import "PYClient.h"
#import "NSObject+Supervisor.h"
#import "PYSupervisable.h"
#import "PYConnection+FetchedStreams.h"

@interface PYStream ()<PYSupervisable>
@end


@implementation PYStream

@synthesize streamId = _streamId;
@synthesize name = _name;
@synthesize parentId = _parentId;
@synthesize singleActivity = _singleActivity;
@synthesize clientData = _clientData;
@synthesize children = _children;
@synthesize trashed = _trashed;
@synthesize created = _created;
@synthesize createdBy = _createdBy;
@synthesize modified = _modified;
@synthesize modifiedBy = _modifiedBy;


@synthesize clientId = _clientId;
@synthesize connection = _connection;
@synthesize isSyncTriedNow = _isSyncTriedNow;
@synthesize hasTmpId = _hasTmpId;
@synthesize notSyncAdd = _notSyncAdd;
@synthesize notSyncModify = _notSyncModify;
@synthesize synchedAt = _synchedAt;
@synthesize modifiedStreamPropertiesAndValues = _modifiedStreamPropertiesAndValues;

+ (NSString *)createClientId
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return [(NSString *)uuidStringRef autorelease];
}


+ (PYStream*) createOrReuseWithClientId:(NSString*) clientId {
    if (clientId) {
        PYStream *liveStream = [PYStream liveObjectForSupervisableKey:clientId];
        if (liveStream) {
            return liveStream;
        }
    }
    return [[[PYStream alloc] initWithConnection:nil andClientId:clientId] autorelease];
}

- (id)init {
    return [self initWithConnection:nil];
}

- (id)initWithConnection:(PYConnection *)connection {
    return [self initWithConnection:connection andClientId:nil];
}

- (id)initWithConnection:(PYConnection *) connection andClientId:(NSString *) clientId {
    self = [super init];
    if (self)
    {
        if (clientId) {
            _clientId = clientId;
        } else {
            _clientId = [PYStream createClientId];
        }
#warning fixme
        [_clientId retain]; // should we retain?
        
        [self superviseIn];
        self.connection = connection;
    }
    return self;
}

#pragma mark - PYSupervisable

- (NSString *)supervisableKey {
    return self.clientId;
}

#pragma mark -

- (void)dealloc
{
    [self superviseOut];
    [_streamId release];
    [_name release];
    [_parentId release];
    [_clientData release];
    [_modifiedStreamPropertiesAndValues release];
    [_children release];
    [_createdBy release];
    [_modifiedBy release];
    
    [_clientId release];
    [_connection release];
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
    
    
    [dic setObject:[NSNumber numberWithDouble:_created] forKey:@"created"];
    if (_createdBy && _createdBy.length > 0) {
        [dic setObject:_createdBy forKey:@"createdBy"];
    }
    
    [dic setObject:[NSNumber numberWithDouble:_modified] forKey:@"modified"];
    if (_modifiedBy && _modifiedBy.length > 0) {
        [dic setObject:_modifiedBy forKey:@"modifiedBy"];
    }

    [dic setObject:[NSNumber numberWithBool:_singleActivity] forKey:@"singleActivity"];
    [dic setObject:[NSNumber numberWithBool:_trashed] forKey:@"trashed"];
    
    
    if (_clientId && _clientId.length > 0) {
        [dic setObject:_clientId forKey:@"clientId"];
    }
    [dic setObject:[NSNumber numberWithBool:_hasTmpId] forKey:@"hasTmpId"];
    [dic setObject:[NSNumber numberWithBool:_notSyncAdd] forKey:@"notSyncAdd"];
    [dic setObject:[NSNumber numberWithBool:_notSyncModify] forKey:@"notSyncModify"];
    [dic setObject:[NSNumber numberWithDouble:_synchedAt] forKey:@"synchedAt"];
    if (_modifiedStreamPropertiesAndValues) {
        [dic setObject:_modifiedStreamPropertiesAndValues forKey:@"modifiedProperties"];
    }
    
    
    if ([_children count] > 0) {
        NSMutableArray* children = [[[NSMutableArray alloc] init] autorelease];
        for (PYStream *child in _children) {
            [children addObject:[child cachingDictionary]];
        }
        [dic setObject:children forKey:@"children"];
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
    
    
    [dic setObject:[NSNumber numberWithDouble:_created] forKey:@"created"];
    if (_createdBy && _createdBy.length > 0) {
        [dic setObject:_createdBy forKey:@"createdBy"];
    }
    
    [dic setObject:[NSNumber numberWithDouble:_modified] forKey:@"modified"];
    if (_modifiedBy && _modifiedBy.length > 0) {
        [dic setObject:_modifiedBy forKey:@"modifiedBy"];
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
        [description appendString:@" with children : "];
        for (PYStream *child in _children) {
            [description appendFormat:@" %@,", child.name];
        }
    }
    [description appendString:@">"];
    return description;
}

- (PYStream*)parent {
    if (self.parentId == nil) return nil;
    return [self.connection streamWithStreamId:self.parentId];
}

@end