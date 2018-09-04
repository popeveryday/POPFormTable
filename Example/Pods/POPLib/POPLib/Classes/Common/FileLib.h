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

+(NSURL*) getDocumentURL;

+(NSURL*) getDocumentURL:(NSString*) subFolder;

+(NSURL*) getDocumentURL:(NSString*) subFolder isDirectory:(BOOL) isDirectory;

+(NSString*) getDocumentPath;

+(NSString*) getDocumentPath: (NSString*) subFolder;

+(NSString*) getDocumentPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir;

+(NSURL*) getLibraryURL;

+(NSURL*) getLibraryURL:(NSString*) subFolder;

+(NSURL*) getLibraryURL:(NSString*) subFolder isDirectory:(BOOL) isDirectory;

+(NSString*) getLibraryPath;

+(NSString*) getLibraryPath: (NSString*) subFolder;

+(NSString*) getLibraryPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir;

+(NSString*) getTempPath;

+(NSString*) getTempPath: (NSString*) subFolder;

+(NSString*) getTempPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir;

+(NSString*) getResourcePath;

+(NSString*) getResourcePath: (NSString*) subFolder;

+(NSURL*) getEmbedResourceURLWithFilename:(NSString*) filename;

+(NSString*) getEmbedResourcePathWithFilename:(NSString*) filename;

+(NSArray*)getFileList:(NSString*) path searchString:(NSString*)searchString isFullPath:(BOOL)isFullPath isIncludeSubFolder:(BOOL)isIncludeSubFolder filterListType:(enum GetFileListType) filterListType limit:(NSInteger) limit;

+(NSArray*) getFileList:(NSString*) path searchString:(NSString*) searchString isFullPath:(BOOL) isFullPath isIncludeSubFolder:(BOOL) isIncludeSubFolder filterListType:(enum GetFileListType) filterListType;

+(NSArray*) getFileList:(NSString*) path searchString:(NSString*) searchString isFullPath:(BOOL) isFullPath;

+(NSArray*) getFileList:(NSString*) path fileType:(NSString*) fileType isFullPath:(BOOL) isFullPath;

+(NSArray*) getFileList:(NSString*) path fileType:(NSString*) fileType;

+(BOOL) createDirectory:(NSString*) path;

+(BOOL) removeFileOrDirectory:(NSString*) path;

+(void) saveImage:(UIImage*) photo path:(NSString*) path;

+(void) saveImage:(UIImage*) photo path:(NSString*) path jpgCompressLevel:(CGFloat) jpgCompressLevel;

+(UIImagePickerController*) showPickerController: (id) container sourceType:(UIImagePickerControllerSourceType) sourceType;

+(void) writeContent:(NSString*) content toFile:(NSString*) fileName isAppend:(BOOL) isAppend;

+(NSString*) readFile: (NSString*) filePath;

+(NSString*) readFileInDocument:(NSString*) fileName;

+(NSString*) readEmbedResourceFileWithFilename:(NSString*) filename;

+(BOOL) moveFileFromPath:(NSString*) fromPath toPath:(NSString*) toPath;

+(BOOL) copyFileFromPath:(NSString*) fromPath toPath:(NSString*) toPath;

+(BOOL) copyFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath;

+(BOOL) moveFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath;

+(ReturnSet*) renameFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath mergeFolderData:(BOOL) mergeFolderData removeOldFolder:(BOOL) removeOldFolder;

+(BOOL) checkPathExisted:(NSString*) path;

+(BOOL) checkPathIsDirectory:(NSString*) path;

+(NSString*) getNewName:(NSString*) prefix suffix:(NSString*) suffix;

+(NSString*) getNewNameYMDHMSWithPrefix:(NSString*) prefix suffix:(NSString*) suffix;

+(void) setAppPreference:(NSString*) key value:(id) value;

+(id) getAppPreference:(NSString*) key defaultValue:(id) defaultValue;

+(double) getFileSizeWithPath:(NSString*) path;

+(double) getFolderSizeWithPath:(NSString*) path includeSubFolder:(BOOL) includeSubFolder;

+(NSString*) genAutoFilenameWithSourcefile:(NSString*) sourcefile destinationFolder:(NSString*) destinationFolder;

+(NSArray*) sortFileList:(NSArray*) files sortType:(enum SortFileListType) sortType isSortAscending:(BOOL) isSortAscending;

+(NSDictionary*) breakDownPath:(NSString*) filePath;

+(NSString*) updateFilename:(NSString*) filePath withPrefix:(NSString*) prefix suffix:(NSString*) suffix newExtension:(NSString*) newExtension;

+(NSString*) md5HashOfPath:(NSString*) path;

+(NSString*) shaHashOfPath:(NSString*) path;

+(NSString*) base64StringFromFileAtPath:(NSString*) filePath;

+(NSData*) dataFrom64String:(NSString*) stringEncodedWithBase64;

+(NSString*) getFullPathFromParam:(NSString*)param defaultPath:(NSString*)defaultPath;

@end

