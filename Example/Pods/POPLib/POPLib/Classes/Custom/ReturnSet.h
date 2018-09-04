//
//  ReturnSet.h
//  PopLibPreview
//
//  Created by Trung Pham on 9/26/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface ReturnSet : NSObject

@property (nonatomic) BOOL result;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) id extraObject;
@property (nonatomic, strong) NSString* message;


-(instancetype)initWithResult:(BOOL) result message:(NSString*) message object:(id) object extraObject:(id)extraObject;

+(ReturnSet*) initWithResult:(BOOL) result;

+(ReturnSet*)initWithMessage:(BOOL) result message:(NSString*) message;

+(ReturnSet*)initWithObject:(BOOL) result object:(id) object;

+(ReturnSet*)initWithObject:(BOOL) result object:(id)object extraObject:(id)extraObject;

+(ReturnSet*)init:(BOOL) result message:(NSString*) message object:(id) object;

+(ReturnSet*) initWithResult:(BOOL) result message:(NSString*) message object:(id) object extraObject:(id)extraObject;


@end
