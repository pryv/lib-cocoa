//
//  PryvJSONUtils.m
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/4/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvJSONUtils.h"
#import "PryvLocation.h"
#import "PryvAttachment.h"
#import "PYEventType.h"



@implementation PryvJSONUtils{
    
}
-(NSArray*)parseEvents:(NSString *)jsonString{
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonString error:&error];
    [jsonParser release], jsonParser = nil;
    NSMutableArrary *events = [NSMutableArray array];
    
    for (NSDictionary *dict in jsonObjects)
    {
        PryvEvent *event = [[[PryvEvent alloc] init] autorelease];
        event.description=(NSString*)[dict objectForKey:@"description"];
        event.eventId=(NSString*)[dict objectForKey:@"eventId"];
        event.folderId=(NSString*)[dict objectForKey:@"folderId"];
        event.modified=(NSString*)[dict objectForKey:@"modified"];
        event.duration=(NSString*)[dict objectForKey:@"duration"];//handling of attachments todo
        
        NSDictionary *type= [dict objectForKey:@"type"];
        PYEventType *pryvType=[[PYEventType alloc] init];
        pryvType.format=(NSString*)[dict objectForKey:@"format"];
        pryvType.clazz=(NSString*)[dict objectForKey:@"class"];
        
        NSDictionary *value = [dict objectForKey:@"value"];
        NSDictionary *location = [value objectForKey:@"location"];
        NSString *latitude = (NSString*)[location objectForKey:@"lat"];
        NSString *longitude = (NSString*)[location objectForKey:@"lng"];
        PryvLocation *location=[[PryvLocation alloc] init];
        location.latitude=[NSNumber numberWithFloat::[latitude floatValue]];
        location.longitude=[NSNumber numberWithFloat::[longitude floatValue]];
        event.location=location;
        NSArray *attachFiles = [dict objectForKey:@"attachments"]
        NSMutableArray *attachments = [NSMutableArray array];
        for (NSDictionary *atachedFiles in attachFiles)
        {
            NSArray * keys=[[NSArray alloc]init];
            keys=[atachedFiles allKeys];
            
            for(int i=0;i<[keys count];i++){
                
                NSString *attachmentName =(NSString *)[keys objectAtIndex:i];
                NSDictionary *attachmentData = [jsonDict valueForKey:attachmentName];
                PryvAttachment *attachment=[[PryvAttachment alloc] init ];
                attachment.fileName =(NSString*)[attachmentData objectForKey:@"fileName"];
                attachment.type  =(NSString*)[attachmentData objectForKey:@"type"];
                attachment.size  =(NSNumber*) [NSNumber numberWithFloat::[[attachmentData objectForKey:@"size"] floatValue]] ;
                
                [ attachments addObject attachment];
                
            }
        }
        event.attachmentList=attachments;
        event.location=location;
        [events addObject:event];
        
        return events;
    }}

-(NSArray*)parseEventsWithParser:(NSString *)jsonString :(SBJsonParser *)jsonParser{
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonString error:&error];
    NSMutableArrary *events = [NSMutableArray array];
    
    for (NSDictionary *dict in jsonObjects)
    {
        PryvEvent *event = [[[PryvEvent alloc] init] autorelease];
        event.description=(NSString*)[dict objectForKey:@"description"];
        event.eventId=(NSString*)[dict objectForKey:@"eventId"];
        event.folderId=(NSString*)[dict objectForKey:@"folderId"];
        event.modified=(NSString*)[dict objectForKey:@"modified"];
        event.duration=(NSString*)[dict objectForKey:@"duration"];//handling of attachments todo
        
        NSDictionary *type= [dict objectForKey:@"type"];
        PYEventType *pryvType=[[PYEventType alloc] init];
        pryvType.format=(NSString*)[dict objectForKey:@"format"];
        pryvType.clazz=(NSString*)[dict objectForKey:@"class"];
        
        NSDictionary *value = [dict objectForKey:@"value"];
        NSDictionary *location = [value objectForKey:@"location"];
        NSString *latitude = (NSString*)[location objectForKey:@"lat"];
        NSString *longitude = (NSString*)[location objectForKey:@"lng"];
        PryvLocation *location=[[PryvLocation alloc] init];
        location.latitude=[NSNumber numberWithFloat::[latitude floatValue]];
        location.longitude=[NSNumber numberWithFloat::[longitude floatValue]];
        event.location=location;
        NSArray *attachFiles = [dict objectForKey:@"attachments"]
        NSMutableArray *attachments = [NSMutableArray array];
        for (NSDictionary *atachedFiles in attachFiles)
        {
            NSArray * keys=[[NSArray alloc]init];
            keys=[atachedFiles allKeys];
            
            for(int i=0;i<[keys count];i++){
                
                NSString *attachmentName =(NSString *)[keys objectAtIndex:i];
                NSDictionary *attachmentData = [jsonDict valueForKey:attachmentName];
                PryvAttachment *attachment=[[PryvAttachment alloc] init ];
                attachment.fileName =(NSString*)[attachmentData objectForKey:@"fileName"];
                attachment.type  =(NSString*)[attachmentData objectForKey:@"type"];
                attachment.size  =(NSNumber*) [NSNumber numberWithFloat::[[attachmentData objectForKey:@"size"] floatValue]] ;
               
                [ attachments addObject attachment];
                
            }
        }
        
        
        
        
        event.attachmentList=attachments;
        [events addObject:event];
        return events;
    }
}



@end


