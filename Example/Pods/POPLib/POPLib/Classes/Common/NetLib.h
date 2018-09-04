//
//  NetLib.h
//  PopLibPreview
//
//  Created by popeveryday on 11/2/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReturnSet.h"
#import "FileLib.h"
#import "ReturnSet.h"
#import "Hashtable.h"
#import "Reachability.h"
#import <MessageUI/MessageUI.h>

@interface NetLib : NSObject
+(void)downloadAsyncFileToPath:(NSString*) toPath url:(NSString*) url delegate:(id<NSURLConnectionDelegate>)delegate;
+(ReturnSet*)downloadFileToPath:(NSString*) toPath url:(NSString*) url;
+(ReturnSet*)downloadFileToDocument:(NSString*) destinationFile url:(NSString*) url;
+(ReturnSet*)downloadTextFileToPath:(NSString*) toPath url:(NSString*) url;
+(ReturnSet*)downloadTextFileToDocument:(NSString*) destinationFile url:(NSString*) url;
+(ReturnSet*)uploadFileWithPath:(NSString *)filePath toUrl:(NSString *)url uploadTagName:(NSString *)uploadTagName requestData:(Hashtable *)requestData;
+(ReturnSet*)uploadFileToUrl:(NSString *)url withTagNameFilePaths:(Hashtable*)files requestData:(Hashtable *)requestData;
+(BOOL)isInternetAvailable;
+(BOOL)isNetworkConnectionReady;
+(BOOL)isReachableURL:(NSString*)url;
+(NSString*)uRLEncoding:(NSString *)val;
+(ReturnSet*)readTextFromUrl:(NSString*) url;
+(ReturnSet*)getFileNameSizeFromURL:(NSString*)url;
+(void)emailWithAttachments:(NSMutableArray*) attachments fromViewController:(UIViewController*)fromVC delegate:(id<MFMailComposeViewControllerDelegate>) delegate;
@end



@interface NetworkChecker : NSObject
@property (nonatomic, readonly) BOOL isPingSuccess;
@property (nonatomic, readonly) BOOL isInitSuccess;
@property (nonatomic) BOOL isAutoRetryPing;
@property (nonatomic) CGFloat pingDelay;


+ (instancetype)instance;
-(instancetype) initDefaultAuto;
-(instancetype) initWithHostName:(NSString*)hostName;
-(void)startPinger;
-(void)setNetworkStatusChangedBlock:(void (^)(BOOL isOnline))networkStatusChangedBlock;
-(void)setNetworkInitFail:(void (^)(NSError *error))networkInitFail;
-(void)sendPing;

@end
