//
//  SharedObject.m
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/25/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import "ObserverObject.h"
#define OBS_KEY @"ObserverObjectKey"

@implementation ObserverObject
{
    NSLock* targetLock;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.targetObjects = [NSMutableDictionary new];
        targetLock = [NSLock new];
        [self registerForNotificationKey:OBS_KEY];
    }
    return self;
}

-(void) registerForNotificationKey:(NSString*)notificationKey
{
    [targetLock lock];
    if ([self.targetObjects.allKeys containsObject:notificationKey]) {
        [targetLock unlock];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionObserver:) name:notificationKey object:nil];
    [self.targetObjects setObject:[NSMutableArray new] forKey:notificationKey];
    [targetLock unlock];
}

-(void) actionObserver:(NSNotification*)sender
{
    NSDictionary* data = sender.object;
    NSInteger key = [[data objectForKey:@"key"] integerValue];
    NSObject* value = [data objectForKey:@"value"];
    
    
    NSArray* targets = [self.targetObjects objectForKey:sender.name];
    if(!targets || targets.count == 0) return;
    NSArray* copiedTargets = [targets mutableCopy];
    
    for (id target in copiedTargets) {
        if(target && [target respondsToSelector:@selector(observerObjectDidCallWithKey:value:notificationKey:)])
        {
            [target observerObjectDidCallWithKey:key value:value notificationKey:sender.name];
        }
        
        if(target && [target respondsToSelector:@selector(observerObjectDidCallWithKey:value:)])
        {
            [target observerObjectDidCallWithKey:key value:value];
        }
    }
}

-(void)addObserverToTarget:(id<ObserverObjectDelegate>)target
{
    [self addObserverToTarget:target notificationKey:nil];
}

-(void)addObserverToTarget:(id<ObserverObjectDelegate>)target notificationKey:(NSString*)notificationKey
{
    NSString* notiKey = notificationKey ? notificationKey : OBS_KEY;
    
    if(![self.targetObjects.allKeys containsObject:notiKey]) [self registerForNotificationKey:notiKey];
    
    [targetLock lock];
    NSMutableArray* groupTargets = [self.targetObjects objectForKey: notiKey];
    
    if ([groupTargets containsObject:target]){
        [targetLock unlock];
        return;
    }
    
    [groupTargets addObject:target];
    [self.targetObjects setObject:groupTargets forKey:notiKey];
    [targetLock unlock];
}

-(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target
{
    [self removeObserverWithTarget:target notificationKey:nil];
}

-(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target notificationKey:(NSString*)notificationKey
{
    NSString* notiKey = notificationKey ? notificationKey : OBS_KEY;
    
    if(![self.targetObjects.allKeys containsObject:notiKey]) [self registerForNotificationKey:notiKey];
    
    [targetLock lock];
    NSMutableArray* groupTargets = [self.targetObjects objectForKey: notiKey];
    
    if (![groupTargets containsObject:target])
    {
        [targetLock unlock];
        return;
    }
    
    [groupTargets removeObject:target];
    [self.targetObjects setObject:groupTargets forKey:notiKey];
    [targetLock unlock];
}





+(ObserverObject*)instance
{
    static ObserverObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ObserverObject alloc] init];
    });
    
    return sharedInstance;
}

+(void)registerForNotificationKey:(NSString*)notificationKey
{
    [[ObserverObject instance] registerForNotificationKey:notificationKey];
}


+(void)addObserverToTarget:(id<ObserverObjectDelegate>)target
{
    [[ObserverObject instance] addObserverToTarget:target];
}

+(void)addObserverToTarget:(id<ObserverObjectDelegate>)target notificationKey:(NSString*)notificationKey
{
    [[ObserverObject instance] addObserverToTarget:target notificationKey:notificationKey];
}

+(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target
{
    [[ObserverObject instance] removeObserverWithTarget:target];
}

+(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target notificationKey:(NSString*)notificationKey
{
    [[ObserverObject instance] removeObserverWithTarget:target notificationKey:notificationKey];
}


+(void)sendObserver:(NSInteger)key object:(id)object notificationKey:(NSString*)notificationKey
{
    NSString* notiKey = notificationKey ? notificationKey : OBS_KEY;
    [[NSNotificationCenter defaultCenter] postNotificationName:notiKey object: object ? @{ @"key":@(key), @"value": object } : @{ @"key":@(key) } ];
}

+(void)sendObserver:(NSInteger)key object:(id)object
{
    [self sendObserver:key object:object notificationKey:nil];
}

+(void)sendObserver:(NSInteger)key notificationKey:(NSString*)notificationKey
{
    [self sendObserver:key object:nil notificationKey:notificationKey];
}

+(void)sendObserver:(NSInteger)key
{
    [self sendObserver:key object:nil];
}



@end

