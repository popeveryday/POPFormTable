//
//  ReturnSet.m
//  PopLibPreview
//
//  Created by Trung Pham on 9/26/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "ReturnSet.h"

@implementation ReturnSet

-(ReturnSet*) initWithResult:(BOOL) result{
    self.Result = result;
    return self;
}

-(ReturnSet*) initWithMessage:(BOOL) result message:(NSString*) message{
    self.Result = result;
    self.Message = message;
    return self;
}

-(ReturnSet*) initWithObject:(BOOL) result object:(id) object{
    self.Result = result;
    self.Object = object;
    return self;
}

-(ReturnSet*) initWithObject:(BOOL) result object:(id) object extraObject:(id)extraObject{
    self.Result = result;
    self.Object = object;
    self.ExtraObject = extraObject;
    return self;
}

-(ReturnSet*) init:(BOOL) result message:(NSString*) message object:(id) object{
    self.Result = result;
    self.Message = message;
    self.Object = object;
    return self;
}

-(ReturnSet*) init:(BOOL) result message:(NSString*) message object:(id) object extraObject:(id)extraObject{
    self.Result = result;
    self.Message = message;
    self.Object = object;
    self.ExtraObject = extraObject;
    return self;
    
}


@end
