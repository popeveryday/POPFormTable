//
//  Hashtable.h
//  CommonLib
//
//  Created by popeveryday on 5/30/14.
//  Copyright (c) 2014 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hashtable : NSObject <NSCoding>

@property (nonatomic) BOOL autoTrimKeyValue;
@property (nonatomic, readonly) NSMutableArray* keys;
@property (nonatomic, readonly) NSMutableArray* values;

-(void)clear;
-(NSInteger)count;

-(void)addValue:(id)value forKey:(NSString*) key;
-(id)getValueForKey:(NSString*) key;

-(void)hashtable_AddValue:(id)value forKey:(NSString*) key;
-(id)hashtable_GetValueForKey:(NSString*) key;

-(void)hashtable_AddValueFromHashtable:(Hashtable*)hash;
-(void) hashtable_RemoveObjectWithKey:(NSString*)key;
-(NSDictionary*) toDictionary;

+(id)initWithDictionary:(NSDictionary*)dic;

@end
