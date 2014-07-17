//
//  PYMeasurementSet.h
//  Is a set of PYMesurementGroups
//

#import <Foundation/Foundation.h>
#import "PYMeasurementTypesGroup.h"

@interface PYMeasurementSet : NSObject
{
    NSString *_key;
    NSMutableArray *_measurementGroups;
    
    @private
    NSDictionary *_names;
    NSDictionary *_descriptions;
}

- (id)initWithKey:(NSString*)key andDictionary:(NSDictionary*)dictionary andPYEventsTypes:(PYEventTypes*) pyTypes;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
//Private variables
@property (nonatomic, copy) NSDictionary *names;
@property (nonatomic, copy) NSDictionary *descriptions;

- (NSString *)localizedName;
- (NSString *)localizedDescription;
@end
