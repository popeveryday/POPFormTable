//
//  ReturnSet.m
//  PopLibPreview
//
//  Created by Trung Pham on 9/26/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "ReturnSet.h"

@implementation ReturnSet

+(ReturnSet*) initWithResult:(BOOL) result
{
    return [self initWithResult:result message:nil object:nil extraObject:nil];
}

+(ReturnSet*)initWithMessage:(BOOL) result message:(NSString*) message
{
    return [self initWithResult:result message:message object:nil extraObject:nil];
}

+(ReturnSet*)initWithObject:(BOOL) result object:(id) object
{
    return [self initWithResult:result message:nil object:object extraObject:nil];
}

+(ReturnSet*)initWithObject:(BOOL) result object:(id)object extraObject:(id)extraObject{
    return [self initWithResult:result message:nil object:object extraObject:extraObject];
}

+(ReturnSet*)init:(BOOL) result message:(NSString*) message object:(id) object{
    return [self initWithResult:result message:message object:object extraObject:nil];
}

+(ReturnSet*) initWithResult:(BOOL) result message:(NSString*) message object:(id) object extraObject:(id)extraObject
{
    ReturnSet* obj = [[ReturnSet alloc] initWithResult:result message:message object:object extraObject:extraObject];
    return obj;
}

-(instancetype)initWithResult:(BOOL) result message:(NSString*) message object:(id) object extraObject:(id)extraObject
{
    self = [super init];
    if (self) {
        self.result = result;
        if(message) self.message = message;
        if(object) self.object = object;
        if(extraObject) self.extraObject = extraObject;
    }
    return self;
}

@end
