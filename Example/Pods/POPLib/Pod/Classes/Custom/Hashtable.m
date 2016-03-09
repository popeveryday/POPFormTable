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

+(id) initWithDictionary:(NSDictionary*)dic
{
    Hashtable* hash = [[Hashtable alloc] init];
    for (NSString* key in dic.allKeys) {
        [hash Hashtable_AddValue:[dic valueForKey:key] forKey:key];
    }
    return hash;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _Keys forKey:@"key"];
    [aCoder encodeObject: _Values forKey:@"value"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        _Keys = [decoder decodeObjectForKey:@"key"] == nil ? [[NSMutableArray alloc] init] : [decoder decodeObjectForKey:@"key"];
        _Values = [decoder decodeObjectForKey:@"value"] == nil ? [[NSMutableArray alloc] init] : [decoder decodeObjectForKey:@"value"];
    }
    return self;
}



-(id) init{
    self = [super init];
    if (self) {
        _Keys = [[NSMutableArray alloc] init];
        _Values = [[NSMutableArray alloc] init];
    }
    return self;
}



-(void) clear{
    [_Keys removeAllObjects];
    [_Values removeAllObjects];
}

-(NSInteger) count{
    return _Keys.count;
}

-(void) AddValue:(id)value forKey:(NSString*) key
{
    if (_AutoTrimKeyValue) {
        key = [StringLib Trim: key];
        value = [StringLib Trim: value];
    }
    
    NSUInteger index = [_Keys indexOfObject: key];
    
    if (index == NSNotFound) {
        [_Keys addObject:key];
        [_Values addObject:value];
    }else{
        _Values[index] = value;
    }
    
}

-(id) GetValueForKey:(NSString*) key
{
    if (_AutoTrimKeyValue) {
        key = [StringLib Trim: key];
    }
    
    NSUInteger index = [_Keys indexOfObject:key];
    if (index == NSNotFound) {
        return nil;
    }else{
        return _Values[index];
    }
}

-(void) Hashtable_AddValue:(id)value forKey:(NSString*) key{
    [self AddValue:value forKey:key];
}

-(id) Hashtable_GetValueForKey:(NSString*) key{
    return [self GetValueForKey:key];
}

-(void) Hashtable_AddValueFromHashtable:(Hashtable*)hash{
    [_Keys addObjectsFromArray:hash.Keys];
    [_Values addObjectsFromArray:hash.Values];
}


@end
