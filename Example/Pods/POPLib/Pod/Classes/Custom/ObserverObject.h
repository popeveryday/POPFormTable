//
//  SharedObject.h
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/25/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObserverObject : NSObject

@property (nonatomic) NSString *message;
@property (nonatomic) id object;
@property (nonatomic) NSInteger key;
@property (nonatomic) NSInteger counter;


+ (ObserverObject *)Instance;

+ (void) RemoveObserverToTarget:(id)target;
+ (void) AddObserverToTarget:(id)target;

+ (void) SendObserver:(NSInteger) key;
+ (void) SendObserver:(NSInteger) key object:(id)object;
+ (void) SendObserver:(NSInteger) key message:(NSString*)message;
+ (void) SendObserver:(NSInteger) key message:(NSString*)message object:(id)object;

+ (NSInteger) Key;
+ (NSString*) Message;
+ (id) Object;
@end


//viewDidLoad
//[ObserverObject AddObserverToTarget:self];

//-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    switch ([ObserverObject Key])
//    {
//        case OBS_FinishRoundDialog_NextRound:
//            NSLog(@"next");
//            break;
//        case OBS_FinishRoundDialog_ReplayRound:
//            NSLog(@"replay");
//            break;
//        case OBS_FinishRoundDialog_ReturnPackage:
//            NSLog(@"return");
//            break;
//    }
//}

//-(void) dealloc{
//    [ObserverObject RemoveObserverToTarget:self];
//}