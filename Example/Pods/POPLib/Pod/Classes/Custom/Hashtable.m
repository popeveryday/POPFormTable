//
//  Hashtable.m
//  CommonLib
//
//  Created by popeveryday on 5/30/14.
//  Copyright (c) 2014 Lapsky. All rights reserved.
//

#import "Hashtable.h"
#import "StringLib.h"

@implementation Hashtable

+(id)initWithDictionary:(NSDictionary*)dic
{
    Hashtable* hash = [[Hashtable alloc] init];
    for (NSString* key in dic.allKeys) {
        [hash hashtable_AddValue:[dic valueForKey:key] forKey:key];
    }
    return hash;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _keys forKey:@"key"];
    [aCoder encodeObject: _values forKey:@"value"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        _keys = [decoder decodeObjectForKey:@"key"] == nil ? [[NSMutableArray alloc] init] : [decoder decodeObjectForKey:@"key"];
        _values = [decoder decodeObjectForKey:@"value"] == nil ? [[NSMutableArray alloc] init] : [decoder decodeObjectForKey:@"value"];
    }
    return self;
}



-(id)init{
    self = [super init];
    if (self) {
        _keys = [[NSMutableArray alloc] init];
        _values = [[NSMutableArray alloc] init];
    }
    return self;
}



-(void)clear{
    [_keys removeAllObjects];
    [_values removeAllObjects];
}

-(NSInteger)count{
    return _keys.count;
}

-(void)addValue:(id)value forKey:(NSString*) key
{
    if (_autoTrimKeyValue) {
        key = [StringLib trim: key];
        value = [StringLib trim: value];
    }
    
    NSUInteger index = [_keys indexOfObject: key];
    
    if (index == NSNotFound) {
        [_keys addObject:key];
        [_values addObject:value];
    }else{
        _values[index] = value;
    }
    
}

-(id)getValueForKey:(NSString*) key
{
    if (_autoTrimKeyValue) {
        key = [StringLib trim: key];
    }
    
    NSUInteger index = [_keys indexOfObject:key];
    if (index == NSNotFound) {
        return nil;
    }else{
        return _values[index];
    }
}

-(void)hashtable_AddValue:(id)value forKey:(NSString*) key{
    [self addValue:value forKey:key];
}

-(id)hashtable_GetValueForKey:(NSString*) key{
    return [self getValueForKey:key];
}

-(void)hashtable_AddValueFromHashtable:(Hashtable*)hash{
    [_keys addObjectsFromArray:hash.keys];
    [_values addObjectsFromArray:hash.values];
}


@end

