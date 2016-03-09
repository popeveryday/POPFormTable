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

+ (ObserverObject *)Instance
{
    static ObserverObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ObserverObject alloc] init];
    });
    
    return sharedInstance;
}



+ (void) AddObserverToTarget:(id)target{
    [ObserverObject RemoveObserverToTarget:target];
    [[ObserverObject Instance] addObserver:target forKeyPath:@"counter" options:NSKeyValueObservingOptionNew context:NULL];
}

+ (void) RemoveObserverToTarget:(id)target{
    @try{
        [[ObserverObject Instance] removeObserver:target forKeyPath:@"counter"];
    }@catch (id exception) { }
}


+ (void) SendObserver:(NSInteger) key{
    [self SendObserver:key message:nil object:nil];
}

+ (void) SendObserver:(NSInteger) key object:(id)object{
    [self SendObserver:key message:nil object:object];
}

+ (void) SendObserver:(NSInteger) key message:(NSString*)message{
    [self SendObserver:key message:message object:nil];
}

+ (void) SendObserver:(NSInteger) key message:(NSString*)message object:(id)object{
    [ObserverObject Instance].key = key;
    [ObserverObject Instance].message = message;
    [ObserverObject Instance].object = object;
    [ObserverObject Instance].counter = [ObserverObject Instance].counter + 1;
}

+ (NSInteger) Key{
    return [ObserverObject Instance].key;
}

+ (NSString*) Message{
    return [ObserverObject Instance].message;
}

+ (id) Object{
    return [ObserverObject Instance].object;
}



@end
