//
//  SharedObject.h
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/25/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObserverObjectDelegate <NSObject>
-(void) observerObjectDidCallWithKey:(NSInteger)key value:(id)value;

@optional
-(void) observerObjectDidCallWithKey:(NSInteger)key value:(id)value notificationKey:(NSString*)notificationKey;
@end

@interface ObserverObject : NSObject
@property (nonatomic) NSMutableDictionary* targetObjects;

+(ObserverObject*)instance;

+(void)registerForNotificationKey:(NSString*)notificationKey;

+(void)addObserverToTarget:(id<ObserverObjectDelegate>)target;

+(void)addObserverToTarget:(id<ObserverObjectDelegate>)target notificationKey:(NSString*)notificationKey;

+(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target;

+(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target notificationKey:(NSString*)notificationKey;

+(void)sendObserver:(NSInteger)key object:(id)object notificationKey:(NSString*)notificationKey;

+(void)sendObserver:(NSInteger)key object:(id)object;

+(void)sendObserver:(NSInteger)key notificationKey:(NSString*)notificationKey;

+(void)sendObserver:(NSInteger)key;

@end

/*
 
 //implement delegate
 <ObserverObjectDelegate>
 
 
 //viewDidLoad
 [ObserverObject addObserverToTarget:self];
 
 -(void)observerObjectDidCallWithKey:(NSInteger)key value:(id)value
 {
 switch (key)
 {
 case OBS_FinishRoundDialog_NextRound:
 NSLog(@"next");
 break;
 case OBS_FinishRoundDialog_ReplayRound:
 NSLog(@"replay");
 break;
 case OBS_FinishRoundDialog_ReturnPackage:
 NSLog(@"return");
 break;
 }
 }
 
 -(void) dealloc{
 [ObserverObject removeObserverToTarget:self];
 }
 */







/*
 FOR MANUAL OBSERVER =====================
 
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionObserver:) name:@"ANY_NAME_HERE" object:nil];
 
 [[NSNotificationCenter defaultCenter] postNotificationName:OBS_KEY object: @{ @"key":@(key), @"value": object } ];
 
 -(void) actionObserver:(NSNotification*)sender
 {
 NSDictionary* data = sender.object;
 }
 */

