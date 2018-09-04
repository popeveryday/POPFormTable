//
//  NetLib.m
//  PopLibPreview
//
//  Created by popeveryday on 11/2/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "NetLib.h"
#import "SimplePing.h"

@implementation NetLib

+(void)downloadAsyncFileToPath:(NSString*) toPath url:(NSString*) url delegate:(id<NSURLConnectionDelegate>)delegate{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
    [connection start];
    
}

+(ReturnSet*)downloadFileToPath:(NSString*) toPath url:(NSString*) url{
    NSURL *nsurl = [NSURL URLWithString:url];
    NSData *urlData = [NSData dataWithContentsOfURL:nsurl];
    
    if ([urlData length] == 0) {
        return [ReturnSet initWithResult:NO];
    }
    
    //[urlData writeToFile:toPath atomically:YES];
    
    NSError* error;
    [urlData writeToFile:toPath options:NSDataWritingAtomic error:&error];
    
    if(error) NSLog(@"Error: %@", error);
    
    return [ReturnSet initWithMessage:YES message:toPath];
}

+(ReturnSet*)downloadFileToDocument:(NSString*) destinationFile url:(NSString*) url{
    destinationFile = [FileLib getDocumentPath:destinationFile];
    return [self downloadFileToPath:destinationFile url:url];
}

+(ReturnSet*)downloadTextFileToPath:(NSString*) toPath url:(NSString*) url{
    NSURL *nsurl = [NSURL URLWithString:url];
    
    NSError* error;
    
    NSString* content = [[NSString alloc] initWithContentsOfURL:nsurl encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"DownloadTextFileToPath error:: %@", error);
    }
    
    if (content == nil) {
        return [ReturnSet initWithResult:NO];
    }
    
    [FileLib writeContent:content toFile:toPath isAppend:NO];
    
    return [ReturnSet init:YES message:toPath object:toPath];
}

+(ReturnSet*)downloadTextFileToDocument:(NSString*) destinationFile url:(NSString*) url{
    destinationFile = [FileLib getDocumentPath:destinationFile];
    return [self downloadTextFileToPath:destinationFile url:url];
}

+(ReturnSet*)uploadFileWithPath:(NSString *)filePath toUrl:(NSString *)url uploadTagName:(NSString *)uploadTagName requestData:(Hashtable *)requestData
{
    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [theRequest setHTTPMethod:@"POST"];
    //    [theRequest setValue:uid forHTTPHeaderField:@"uid"];
    
    // define post boundary...
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *boundaryString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [theRequest addValue:boundaryString forHTTPHeaderField:@"Content-Type"];
    
    // viagra 25mg define boundary separator...
    NSString *boundarySeparator = [NSString stringWithFormat:@"--%@\r\n", boundary];
    
    //adding the body...
    NSMutableData *postBody = [NSMutableData data];
    
    // adding params...
    if (requestData != nil) {
        for (NSString* key in requestData.keys)
        {
            NSString *formDataName = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
            NSString *formDataValue = [NSString stringWithFormat:@"%@\r\n", [requestData hashtable_GetValueForKey:key]];
            
            [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[formDataName dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[formDataValue dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    // if file is defined, upload it...
    if (filePath)
    {
        NSArray *split = [filePath componentsSeparatedByString:@"/"];
        NSString *fileName = (NSString*)[split lastObject];
        NSData *fileContent = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
        
        [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadTagName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:fileContent];
    }
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    [theRequest setHTTPBody:postBody];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *reqResults = [NSURLConnection sendSynchronousRequest:theRequest
                                               returningResponse:&theResponse
                                                           error:&theError];
    if (!reqResults) {
        return [ReturnSet initWithMessage:NO message:[NSString stringWithFormat:@"Connection error for URL: %@", [url description]]];
    }else{
        NSString *returnString = [[NSString alloc] initWithData:reqResults encoding:NSUTF8StringEncoding];
        return [ReturnSet init:YES message:[NSString stringWithFormat:@"%@", returnString] object:returnString];
    }
}

+(ReturnSet*)uploadFileToUrl:(NSString *)url withTagNameFilePaths:(Hashtable*)files requestData:(Hashtable *)requestData
{
    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [theRequest setHTTPMethod:@"POST"];
    //    [theRequest setValue:uid forHTTPHeaderField:@"uid"];
    
    // define post boundary...
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *boundaryString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [theRequest addValue:boundaryString forHTTPHeaderField:@"Content-Type"];
    
    // viagra 25mg define boundary separator...
    NSString *boundarySeparator = [NSString stringWithFormat:@"--%@\r\n", boundary];
    
    //adding the body...
    NSMutableData *postBody = [NSMutableData data];
    
    // adding params...
    if (requestData != nil) {
        for (NSString* key in requestData.keys)
        {
            NSString *formDataName = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
            NSString *formDataValue = [NSString stringWithFormat:@"%@\r\n", [requestData hashtable_GetValueForKey:key]];
            
            [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[formDataName dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[formDataValue dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    // if file is defined, upload it...
    if (files != nil && files.count > 0) {
        for (NSString* fileTagName in files.keys)
        {
            NSString* filePath = [files hashtable_GetValueForKey:fileTagName];
            
            if(![FileLib checkPathExisted:filePath]) continue;
            
            NSString *fileName = [filePath lastPathComponent];
            NSData *fileContent = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
            
            [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileTagName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                                  dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:fileContent];
            
            NSLog(@"uploading file: %@ tag: %@", fileName, fileTagName);
        }
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    [theRequest setHTTPBody:postBody];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *reqResults = [NSURLConnection sendSynchronousRequest:theRequest
                                               returningResponse:&theResponse
                                                           error:&theError];
    if (!reqResults) {
        return [ReturnSet initWithMessage:NO message:[NSString stringWithFormat:@"Connection error for URL: %@", [url description]]];
    }else{
        NSString *returnString = [[NSString alloc] initWithData:reqResults encoding:NSUTF8StringEncoding];
        return [ReturnSet init:YES message:[NSString stringWithFormat:@"%@", returnString] object:returnString];
    }
}



+(BOOL)isInternetAvailable
{
    return [NetworkChecker instance].isPingSuccess;
}

+(BOOL)isNetworkConnectionReady
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    NSLog(@"Checking network connection: %@", @(!(networkStatus == NotReachable)));
    return !(networkStatus == NotReachable);
}

+(BOOL) isReachableURL:(NSString*)url
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(!response) return NO;
    
    NSLog(@"isReachableURL: %@", response.URL.absoluteString);
    
    if(![response.URL.absoluteString containsString:url]) return NO;
    
    NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
    
    return statusCode >= 200 && statusCode < 300;
}

+(NSString*)uRLEncoding:(NSString *)val
{
    return [val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(ReturnSet*)readTextFromUrl:(NSString*) url
{
    NSURL *nsurl = [NSURL URLWithString:url];
    
    NSError* error;
    
    NSString* content = [[NSString alloc] initWithContentsOfURL:nsurl encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        return [ReturnSet initWithMessage:NO message:[NSString stringWithFormat:@"ReadTextFromUrl error:: %@", error]];
    }
    
    if (content == nil) {
        return [ReturnSet initWithMessage:NO message:@"No content returned"];
    }
    
    return [ReturnSet initWithObject:YES object:[NSString stringWithFormat:@"%@", content]];
}

+(ReturnSet*)getFileNameSizeFromURL:(NSString*)url{
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"HEAD"];
    
    NSHTTPURLResponse *response;
    
    NSError* error;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    
    NSString* size = [NSString stringWithFormat:@"%lld", [response expectedContentLength]];
    
    if (error != nil) {
        return [ReturnSet initWithMessage:NO message:[NSString stringWithFormat:@"Error: %@", error]];
    }
    
    if (response.statusCode /100 != 2) {
        return [ReturnSet initWithMessage:NO message:@"Wrong return code"];
    }else{
        return [ReturnSet initWithObject:YES object:[NSString stringWithFormat:@"%@",response.suggestedFilename] extraObject: size ];
    }
}

+(void)emailWithAttachments:(NSMutableArray*) attachments fromViewController:(UIViewController*)fromVC delegate:(id<MFMailComposeViewControllerDelegate>) delegate
{
    
    NSData *imageData;
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if(delegate != nil) [controller setMailComposeDelegate:delegate];
    
    NSInteger counter = 1;
    if (attachments != nil) {
        for (NSString* attachment in attachments) {
            imageData = [NSData dataWithContentsOfFile:attachment];
            [controller addAttachmentData:imageData
                                 mimeType:[NSString stringWithFormat:@"image/%@", [attachment.pathExtension.lowercaseString stringByReplacingOccurrencesOfString:@"jpg" withString:@"jpeg"]]
                                 fileName:[NSString stringWithFormat:@"Image_%ld.%@", (long)counter, attachment.pathExtension.lowercaseString]];
            counter++;
        }
    }
    
    [controller setMessageBody:@"Image attached" isHTML:NO];
    
    if ([fromVC navigationController] != nil) {
        [[fromVC navigationController] presentViewController:controller animated:YES completion:nil];
    }
}

@end









@interface NetworkChecker()<SimplePingDelegate>
@property (nonatomic) SimplePing* pinger;
@property (nonatomic) NSTimer* sendTimer;
@property (nonatomic) void(^networkStatusChangedBlock)(BOOL isOnline);
@property (nonatomic) void(^networkInitFail)(NSError *error);
@end

@implementation NetworkChecker

+ (instancetype)instance
{
    static NetworkChecker *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[NetworkChecker alloc] initDefaultAuto];
    });
    
    return sharedGameKitHelper;
}

-(instancetype) initDefaultAuto
{
    self = [super init];
    if (self) {
        self.pinger = [[SimplePing alloc] initWithHostName:@"8.8.8.8"];
        self.pinger.delegate = self;
        self.isAutoRetryPing = YES;
        _isInitSuccess = YES;
        [self.pinger start];
    }
    return self;
}

-(instancetype) initWithHostName:(NSString*)hostName
{
    self = [super init];
    if (self) {
        self.pinger = [[SimplePing alloc] initWithHostName:hostName];
        self.pinger.delegate = self;
        self.isAutoRetryPing = YES;
        _isInitSuccess = YES;
    }
    return self;
}

-(void) startPinger
{
    [self.pinger start];
}


-(void)setNetworkStatusChangedBlock:(void (^)(BOOL isOnline))networkStatusChangedBlock
{
    _networkStatusChangedBlock = networkStatusChangedBlock;
}

-(void)setNetworkInitFail:(void (^)(NSError *error))networkInitFail
{
    _networkInitFail = networkInitFail;
}

- (void)sendPing
{
    if(!self.pinger) return;
    [self.pinger sendPingWithData:nil];
    
    if(!self.isAutoRetryPing) return;
    
    if(self.sendTimer){
        [self.sendTimer invalidate];
        self.sendTimer = nil;
    }
    
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:(self.pingDelay == 0 ? 1 : self.pingDelay) target:self selector:@selector(sendPing) userInfo:nil repeats:NO];
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    assert(pinger == self.pinger);
    assert(address != nil);
    
    NSLog(@"pinging %@", address);
    
    [self sendPing];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    assert(pinger == self.pinger);
    NSLog(@"failed: %@", error);
    
    if (_networkInitFail) {
        _networkInitFail(error);
    }
    
    if (_isPingSuccess)
    {
        _isPingSuccess = NO;
        if (_networkStatusChangedBlock) _networkStatusChangedBlock(_isPingSuccess);
    }
    
    
    
    
    _isInitSuccess = NO;
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    self.pinger = nil;
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    assert(pinger == self.pinger);
    NSLog(@"#%u sent", (unsigned int) sequenceNumber);
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    if (_isPingSuccess)
    {
        _isPingSuccess = NO;
        if (_networkStatusChangedBlock) _networkStatusChangedBlock(_isPingSuccess);
    }
    
    assert(pinger == self.pinger);
    NSLog(@"#%u send failed: %@", (unsigned int) sequenceNumber, error);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    if (!_isPingSuccess)
    {
        _isPingSuccess = YES;
        if (_networkStatusChangedBlock) _networkStatusChangedBlock(_isPingSuccess);
    }
    
    assert(pinger == self.pinger);
    NSLog(@"#%u received, size=%zu", (unsigned int) sequenceNumber, (size_t) packet.length);
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    if (_isPingSuccess)
    {
        _isPingSuccess = NO;
        if (_networkStatusChangedBlock) _networkStatusChangedBlock(_isPingSuccess);
    }
    assert(pinger == self.pinger);
    NSLog(@"unexpected packet, size=%zu", (size_t) packet.length);
}

-(void) dealloc
{
    if(self.sendTimer){
        [self.sendTimer invalidate];
        self.sendTimer = nil;
    }
    
    _pinger = nil;
    _networkStatusChangedBlock = nil;
}


@end

