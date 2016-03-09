//
//  FileLib.h
//  DemoFileManager
//
//  Created by Trung Pham on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReturnSet.h"
#import "DateObject.h"
#import <UIKit/UIKit.h>
#import "GlobalConfig.h"

enum GetFileListType
{
    GetFileListTypeAll,
    GetFileListTypeFileOnly,
    GetFileListTypeFolderOnly,
    GetFileListTypeImageOnly,
    GetFileListTypeVideoOnly,
    GetFileListTypeImageVideoOnly,
};

enum SortFileListType{
    SortFileListCreateDate,
    SortFileListModifyDate,
    SortFileListFileSize,
    SortFileListFileType,
    SortFileListFileName,
};

@interface FileLib : NSObject

+(NSURL *) GetDocumentURL;
+(NSURL *) GetDocumentURL:(NSString*) subFolder;
+(NSURL *) GetDocumentURL:(NSString*) subFolder isDirectory:(BOOL)isDirectory;

+(NSString*) GetDocumentPath;
+(NSString*) GetDocumentPath: (NSString*) subFolder;
+(NSString*) GetDocumentPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir;

+(NSURL *) GetLibraryURL;
+(NSURL *) GetLibraryURL:(NSString*) subFolder;
+(NSURL *) GetLibraryURL:(NSString*) subFolder isDirectory:(BOOL)isDirectory;

+(NSString*) GetLibraryPath;
+(NSString*) GetLibraryPath: (NSString*) subFolder;
+(NSString*) GetLibraryPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir;

+(NSString*) GetTempPath;
+(NSString*) GetTempPath: (NSString*) subFolder;
+(NSString*) GetTempPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir;

+(NSString*) GetResourcePath;
+(NSString*) GetResourcePath: (NSString*) subFolder;
+(NSURL*) GetEmbedResourceURLWithFilename:(NSString*) filename;
+(NSString*) GetEmbedResourcePathWithFilename:(NSString*) filename;

+(NSMutableArray*) GetFileList:(NSString*) path searchString:(NSString*)searchString isFullPath:(BOOL)isFullPath isIncludeSubFolder:(BOOL)isIncludeSubFolder filterListType:(enum GetFileListType) filterListType;
+(NSMutableArray*) GetFileList:(NSString*) path searchString:(NSString*)searchString isFullPath:(BOOL)isFullPath;
+(NSMutableArray*) GetFileList:(NSString*) path fileType:(NSString*) fileType isFullPath:(BOOL)isFullPath;
+(NSMutableArray*) GetFileList:(NSString*) path fileType:(NSString*) fileType;


+(BOOL) CreateDirectory:(NSString*) path;
+(BOOL) RemoveFileOrDirectory:(NSString*) path;

+ (void)SaveImage:(UIImage *)photo path:(NSString *)path;
+ (void)SaveImage:(UIImage *)photo path:(NSString *)path jpgCompressLevel:(CGFloat) jpgCompressLevel;

+(UIImagePickerController*)ShowPickerController: (id) container sourceType:(UIImagePickerControllerSourceType) sourceType;


+(BOOL)WriteFile: (NSString*) filePath content:(NSString*) content;
+(BOOL)WriteFileInDocument: (NSString*) fileName content:(NSString*) content;
+(NSString*)ReadFile: (NSString*) filePath;
+(NSString*)ReadFileInDocument:(NSString*) fileName;
+(NSString*) ReadEmbedResourceFileWithFilename:(NSString *)filename;

+(BOOL) MoveFileFromPath:(NSString*) fromPath toPath:(NSString*) toPath;
+(BOOL) CopyFileFromPath:(NSString*) fromPath toPath:(NSString*) toPath;

+(BOOL) CopyFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath;
+(BOOL) MoveFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath;

+(ReturnSet*) RenameFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath mergeFolderData:(BOOL) mergeFolderData removeOldFolder:(BOOL)removeOldFolder;


+(BOOL) CheckPathExisted:(NSString*) path;
+(BOOL) CheckPathIsDirectory:(NSString*) path;

+(NSString*) GetNewName:(NSString*)prefix suffix:(NSString*)suffix;
+(NSString*) GetNewNameYMDHMSWithPrefix:(NSString*)prefix suffix:(NSString*)suffix;
+(double) GetFileSizeWithPath:(NSString*) path;
+(double) GetFolderSizeWithPath:(NSString*) path includeSubFolder:(BOOL)includeSubFolder;

+(NSString*) GenAutoFilenameWithSourcefile:(NSString*)sourcefile destinationFolder:(NSString*)destinationFolder;

+(NSArray*) SortFileList:(NSArray*) files sortType:(enum SortFileListType) sortType isSortAscending:(BOOL)isSortAscending;

@end
