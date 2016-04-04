//
//  ReturnSet.m
//  PopLibPreview
//
//  Created by Trung Pham on 9/26/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "ReturnSet.h"

@implementation ReturnSet

-(ReturnSet*)initWithResult:(BOOL) result{
    self.result = result;
    return self;
}

-(ReturnSet*)initWithMessage:(BOOL) result message:(NSString*) message{
    self.result = result;
    self.message = message;
    return self;
}

-(ReturnSet*)initWithObject:(BOOL) result object:(id) object{
    self.result = result;
    self.object = object;
    return self;
}

-(ReturnSet*)initWithObject:(BOOL) result object:(id) object extraObject:(id)extraObject{
    self.result = result;
    self.object = object;
    self.extraObject = extraObject;
    return self;
}

-(ReturnSet*)init:(BOOL) result message:(NSString*) message object:(id) object{
    self.result = result;
    self.message = message;
    self.object = object;
    return self;
}

-(ReturnSet*)init:(BOOL) result message:(NSString*) message object:(id) object extraObject:(id)extraObject{
    self.result = result;
    self.message = message;
    self.object = object;
    self.extraObject = extraObject;
    return self;
    
}

@end
