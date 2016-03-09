//
//  Hashtable.h
//  CommonLib
//
//  Created by popeveryday on 5/30/14.
//  Copyright (c) 2014 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hashtable : NSObject <NSCoding>

@property (nonatomic) BOOL AutoTrimKeyValue;
@property (nonatomic, readonly) NSMutableArray* Keys;
@property (nonatomic, readonly) NSMutableArray* Values;

-(void) clear;
-(NSInteger) count;

-(void) AddValue:(id)value forKey:(NSString*) key;
-(id) GetValueForKey:(NSString*) key;

-(void) Hashtable_AddValue:(id)value forKey:(NSString*) key;
-(id) Hashtable_GetValueForKey:(NSString*) key;

-(void) Hashtable_AddValueFromHashtable:(Hashtable*)hash;

+(id) initWithDictionary:(NSDictionary*)dic;

@end
