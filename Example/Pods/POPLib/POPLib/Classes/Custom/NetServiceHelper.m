//
//  NetServiceHelper.m
//  DemoNSServiceNSStream
//
//  Created by Trung Pham Hieu on 9/8/17.
//  Copyright © 2017 poptato. All rights reserved.
//

#import "NetServiceHelper.h"
#import "StringLib.h"

#define SEND_START @"[[[BeGiN>>>"
#define SEND_END @"<<<EnD]]]"


@implementation NetServiceHelper
{
    NSString* loadedStr;
}

-(instancetype)initWithDomain:(NSString*)domain bonjourName:(NSString*)bonjourName
{
    self = [super init];
    if (self) {
        [self initServiceWithDomain:domain bonjourName:bonjourName];
    }
    return self;
}

-(void) initServiceWithDomain:(NSString*)domain bonjourName:(NSString*)bonjourName
{
    _domain = domain;
    _bonjourName = bonjourName;
    
    _services = [NSMutableDictionary new];
    
    NSString* bonjourNameType = [NSString stringWithFormat:@"_%@._tcp.", bonjourName];

#if TARGET_OS_IPHONE
    _server = [[NSNetService alloc] initWithDomain:[NSString stringWithFormat:@"%@.",domain] type:bonjourNameType name:[UIDevice currentDevice].name port:0];
#elif TARGET_OS_MAC
    _server = [[NSNetService alloc] initWithDomain:[NSString stringWithFormat:@"%@.",domain] type:bonjourNameType name:[[NSHost currentHost] localizedName] port:0];
#endif
    
    _server.includesPeerToPeer = YES;
    _server.delegate = self;
    [_server publishWithOptions:NSNetServiceListenForConnections];
    
    _browser = [[NSNetServiceBrowser alloc] init];
    _browser.includesPeerToPeer = YES;
    _browser.delegate = self;
    [_browser searchForServicesOfType:bonjourNameType inDomain:_domain];
    
    loadedStr = @"";
    
    self.netServiceState = NetServiceStateWaiting;
}

#pragma other functions

-(void)setNetServiceState:(enum NetServiceState)netServiceState{
    _netServiceState = netServiceState;
    
    if (_delegate && [_delegate respondsToSelector:@selector(netServiceHelperStateChanged:)]) {
        [_delegate netServiceHelperStateChanged: self.netServiceState];
    }
}

-(BOOL) connectToService:(NSNetService*)service
{
    BOOL success = [service getInputStream:&_inputStream outputStream:&_outputStream];
    
    if(!success){
        NSLog(@"Cannot connect to service: %@", service.name);
        return success;
    }
    
    [self openStream];
    
    _connectedService = service;
    
    return success;
}


-(void) openStream
{
    NSLog(@"Open stream and stop server + browser");
    
    _inputStream.delegate = self;
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    
    _outputStream.delegate = self;
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream open];
    
    [_browser stop];
    [_server stop];
    
    self.netServiceState = NetServiceStateConnected;
}

-(void) closeStream
{
    NSLog(@"Open stream and restart server + browser");
    
    if (_inputStream) {
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream close];
        _inputStream = nil;
    }
    
    if (_outputStream) {
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream close];
        _outputStream = nil;
    }
    
    _connectedService = nil;
    
    [self.server publishWithOptions:NSNetServiceListenForConnections];
    [_browser searchForServicesOfType:[NSString stringWithFormat:@"_%@._tcp.", _bonjourName] inDomain:_domain];
    
    self.netServiceState = NetServiceStateWaiting;
}

- (void) sendMessage:(NSString*)message
{
    if(!_outputStream) return;
    
    NSData *data = [SEND_START dataUsingEncoding:NSUTF8StringEncoding];
    [_outputStream write:[data bytes] maxLength:[data length]];
    
    data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //    [_outputStream write:[data bytes] maxLength:[data length]];
    
    NSUInteger length = [data length];
    NSUInteger chunkSize = 50 * 1024;
    NSUInteger offset = 0;
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[data bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        [_outputStream write:[chunk bytes] maxLength:[chunk length]];
        offset += thisChunkSize;
        // do something with chunk
    } while (offset < length);
    
    
    data = [SEND_END dataUsingEncoding:NSUTF8StringEncoding];
    [_outputStream write:[data bytes] maxLength:[data length]];
    
    NSLog(@"Send: %@", message);
}

- (void) messageReceived:(NSString*)message
{
    NSLog(@"Received: %@", message);
    
    if (_delegate && [_delegate respondsToSelector:@selector(netServiceHelperDidReceivedMessage:)]) {
        [_delegate netServiceHelperDidReceivedMessage:message];
    }
}

#pragma netservice browser delegate

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(nonnull NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"%s", __func__);
    
    if([service isEqual:_server]) return;
    
    [_services setObject:service forKey:service.name];
    
    if (_isAutoConnectAvailableService)
    {
        [self connectToService:service];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(netServiceHelperDidFindService:)]) {
        [_delegate netServiceHelperDidFindService:service];
    }
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"%s", __func__);
    if([service isEqual:_server]) return;
    
    [_services removeObjectForKey:service.name];
    
    if (_delegate && [_delegate respondsToSelector:@selector(netServiceHelperDidRemoveService:)]) {
        [_delegate netServiceHelperDidRemoveService:service];
    }
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    NSLog(@"%s", __func__);
}

#pragma netservice delegate
-(void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"%s - %@", __func__, sender.name);
}

-(void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    NSLog(@"%s", __func__);
    
    //if already connectd -> reject this new one.
    if (_inputStream) {
        [inputStream open];
        [inputStream close];
        [outputStream open];
        [outputStream close];
        return;
    }
    
    
    _inputStream = inputStream;
    _outputStream = outputStream;
    
    if (_delegate && [_delegate respondsToSelector:@selector(netServiceHelperDidAcceptedConnectionWithService:)]) {
        [_delegate netServiceHelperDidAcceptedConnectionWithService:sender];
    }
    
    [self openStream];
    
    _connectedService = sender;
    
}

-(void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    NSLog(@"%s", __func__);
}

#pragma stream service

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"stream event %lu", (unsigned long)eventCode);
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (aStream == _inputStream) {
                uint8_t buffer[1024];
                long len;
                
                
                NSString* content = @"";
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                        if (nil != output) {
                            NSLog(@"%@", output);
                            content = [content stringByAppendingString:output];
                        }
                    }
                }
                
                loadedStr = [loadedStr stringByAppendingString:content];
                
                if([StringLib contains:SEND_END inString:loadedStr]){
                    NSString* item;
                    while (YES) {
                        item = [StringLib subStringBetween:loadedStr startStr:SEND_START endStr:SEND_END];
                        if(![StringLib contains:SEND_END inString:loadedStr]) break;
                        [self messageReceived:item];
                        loadedStr = [loadedStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@%@",SEND_START,item,SEND_END] withString:@""];
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            [self closeStream];
            break;
            
        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            
            if (_delegate && [_delegate respondsToSelector:@selector(netServiceHelperDidDisconnectStream)]) {
                [_delegate netServiceHelperDidDisconnectStream];
            }
            
            [self closeStream];
            break;
            
        default:
            NSLog(@"Unknown event");
            
    }
    
}




@end

