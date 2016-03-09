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
@import MessageUI;

@interface NetLib : NSObject
+(void) DownloadAsyncFileToPath:(NSString*) toPath url:(NSString*) url delegate:(id<NSURLConnectionDelegate>)delegate;
+(ReturnSet*)DownloadFileToPath:(NSString*) toPath url:(NSString*) url;
+(ReturnSet*)DownloadFileToDocument:(NSString*) destinationFile url:(NSString*) url;
+(ReturnSet*)DownloadTextFileToPath:(NSString*) toPath url:(NSString*) url;
+(ReturnSet*)DownloadTextFileToDocument:(NSString*) destinationFile url:(NSString*) url;
+(ReturnSet*) UploadFileWithPath:(NSString *)filePath toUrl:(NSString *)url uploadTagName:(NSString *)uploadTagName requestData:(Hashtable *)requestData;
+(ReturnSet*) UploadFileToUrl:(NSString *)url withTagNameFilePaths:(Hashtable*)files requestData:(Hashtable *)requestData;
+(BOOL) IsInternetAvailable;
+(NSString *)URLEncoding:(NSString *)val;
+(ReturnSet*)ReadTextFromUrl:(NSString*) url;
+(ReturnSet*) GetFileNameSizeFromURL:(NSString*)url;
+(void) emailWithAttachments:(NSMutableArray*) attachments fromViewController:(UIViewController*)fromVC delegate:(id<MFMailComposeViewControllerDelegate>) delegate;
@end
