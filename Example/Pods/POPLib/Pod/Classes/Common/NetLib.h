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
+(void)downloadAsyncFileToPath:(NSString*) toPath url:(NSString*) url delegate:(id<NSURLConnectionDelegate>)delegate;
+(ReturnSet*)downloadFileToPath:(NSString*) toPath url:(NSString*) url;
+(ReturnSet*)downloadFileToDocument:(NSString*) destinationFile url:(NSString*) url;
+(ReturnSet*)downloadTextFileToPath:(NSString*) toPath url:(NSString*) url;
+(ReturnSet*)downloadTextFileToDocument:(NSString*) destinationFile url:(NSString*) url;
+(ReturnSet*)uploadFileWithPath:(NSString *)filePath toUrl:(NSString *)url uploadTagName:(NSString *)uploadTagName requestData:(Hashtable *)requestData;
+(ReturnSet*)uploadFileToUrl:(NSString *)url withTagNameFilePaths:(Hashtable*)files requestData:(Hashtable *)requestData;
+(BOOL)isInternetAvailable;
+(NSString*)uRLEncoding:(NSString *)val;
+(ReturnSet*)readTextFromUrl:(NSString*) url;
+(ReturnSet*)getFileNameSizeFromURL:(NSString*)url;
+(void)emailWithAttachments:(NSMutableArray*) attachments fromViewController:(UIViewController*)fromVC delegate:(id<MFMailComposeViewControllerDelegate>) delegate;
@end
