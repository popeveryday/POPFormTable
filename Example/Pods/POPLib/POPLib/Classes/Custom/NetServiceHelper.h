//
//  NetServiceHelper.h
//  DemoNSServiceNSStream
//
//  Created by Trung Pham Hieu on 9/8/17.
//  Copyright © 2017 poptato. All rights reserved.
//

#import <Foundation/Foundation.h>

enum NetServiceState{
    NetServiceStateWaiting,
    NetServiceStateConnected
};


@protocol NetServiceHelperDelegate <NSObject>

-(void) netServiceHelperDidReceivedMessage:(NSString*)message;

@optional
-(void) netServiceHelperDidFindService:(NSNetService*)service;
-(void) netServiceHelperDidRemoveService:(NSNetService*)service;
-(void) netServiceHelperDidAcceptedConnectionWithService:(NSNetService*)service;
-(void) netServiceHelperDidDisconnectStream;
-(void) netServiceHelperStateChanged:(enum NetServiceState)state;

@end


@interface NetServiceHelper : NSObject<NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>

@property (nonatomic, readonly) NSNetService* server;
@property (nonatomic, readonly) NSNetServiceBrowser* browser;
@property (nonatomic, readonly) NSMutableDictionary* services;
@property (nonatomic, readonly) NSNetService* connectedService;

@property (nonatomic, readonly) NSInputStream* inputStream;
@property (nonatomic, readonly) NSOutputStream* outputStream;

@property (nonatomic) NSString* domain;
@property (nonatomic) NSString* bonjourName;
@property (nonatomic) BOOL isAutoConnectAvailableService;
@property (nonatomic) id<NetServiceHelperDelegate> delegate;
@property (nonatomic, readonly) enum NetServiceState netServiceState;


-(instancetype)initWithDomain:(NSString*)domain bonjourName:(NSString*)bonjourName;
-(BOOL) connectToService:(NSNetService*)service;
- (void) sendMessage:(NSString*)message;

@end
