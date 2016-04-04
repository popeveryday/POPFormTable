//
//  SharedObject.m
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/25/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import "ObserverObject.h"

@implementation ObserverObject



static ObserverObject* shared = nil;

+(ObserverObject*)instance
{
    static ObserverObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ObserverObject alloc] init];
    });
    
    return sharedInstance;
}



+(void)addObserverToTarget:(id)target{
    [self removeObserverToTarget:target];
    [[ObserverObject instance] addObserver:target forKeyPath:@"counter" options:NSKeyValueObservingOptionNew context:NULL];
}

+(void)removeObserverToTarget:(id)target{
    @try{
        [[ObserverObject instance] removeObserver:target forKeyPath:@"counter"];
    }@catch (id exception) { }
}


+(void)sendObserver:(NSInteger) key{
    [self sendObserver:key message:nil object:nil];
}

+(void)sendObserver:(NSInteger) key object:(id)object{
    [self sendObserver:key message:nil object:object];
}

+(void)sendObserver:(NSInteger) key message:(NSString*)message{
    [self sendObserver:key message:message object:nil];
}

+(void)sendObserver:(NSInteger) key message:(NSString*)message object:(id)object{
    [ObserverObject instance].key = key;
    [ObserverObject instance].message = message;
    [ObserverObject instance].object = object;
    [ObserverObject instance].counter = [ObserverObject instance].counter + 1;
}

+(NSInteger)key{
    return [ObserverObject instance].key;
}

+(NSString*)message{
    return [ObserverObject instance].message;
}

+(id)object{
    return [ObserverObject instance].object;
}



@end
