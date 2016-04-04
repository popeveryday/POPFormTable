//
//  FileLib.m
//  DemoFileManager
//
//  Created by Trung Pham on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileLib.h"
#import "ReturnSet.h"
#import "StringLib.h"

@implementation FileLib

+(NSURL*)getDocumentURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSURL*)getDocumentURL:(NSString*) subFolder
{
    return [[self getDocumentURL] URLByAppendingPathComponent:subFolder];
}

+(NSURL*)getDocumentURL:(NSString*) subFolder isDirectory:(BOOL)isDirectory
{
    return [[self getDocumentURL] URLByAppendingPathComponent:subFolder isDirectory:isDirectory];
}


//Manipulating Document folder
+(NSString*)getDocumentPath{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [searchPaths objectAtIndex: 0];
}

+(NSString*)getDocumentPath: (NSString*) subFolder{
    return [self getDocumentPath:subFolder autoCreateDir:FALSE];
}

+(NSString*)getDocumentPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir {
    NSString* path = [[self getDocumentPath] stringByAppendingPathComponent:subFolder];
    if (autoCreateDir) {
        [self createDirectory:path];
    }
    return path;
}


//Manipulating Library folder
+(NSURL*)getLibraryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSURL*)getLibraryURL:(NSString*) subFolder
{
    return [[self getLibraryURL] URLByAppendingPathComponent:subFolder];
}

+(NSURL*)getLibraryURL:(NSString*) subFolder isDirectory:(BOOL)isDirectory
{
    return [[self getLibraryURL] URLByAppendingPathComponent:subFolder isDirectory:isDirectory];
}

+(NSString*)getLibraryPath{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [searchPaths objectAtIndex: 0];
}

+(NSString*)getLibraryPath: (NSString*) subFolder{
    return [self getLibraryPath:subFolder autoCreateDir:FALSE];
}

+(NSString*)getLibraryPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir {
    NSString* path = [[self getLibraryPath] stringByAppendingPathComponent:subFolder];
    if (autoCreateDir) {
        [self createDirectory:path];
    }
    return path;
}





+(NSString*)getTempPath{
    return NSTemporaryDirectory();
}
+(NSString*)getTempPath: (NSString*) subFolder{
    return [self getTempPath:subFolder autoCreateDir:FALSE];
}
+(NSString*)getTempPath: (NSString*) subFolder autoCreateDir:(BOOL) autoCreateDir{
    NSString* path = [[self getTempPath] stringByAppendingPathComponent:subFolder];
    if (autoCreateDir) {
        [self createDirectory:path];
    }
    return path;
}




+(NSString*)getResourcePath{
    return [[NSBundle mainBundle] resourcePath];
}

+(NSString*)getResourcePath: (NSString*) subFolder{
    return [[self getResourcePath] stringByAppendingPathComponent:subFolder];
}

+(NSURL*)getEmbedResourceURLWithFilename:(NSString*) filename
{
    NSString* path = [self getEmbedResourcePathWithFilename:filename];
    return path == nil ? nil : [[NSURL alloc] initFileURLWithPath: path];
}

+(NSString*)getEmbedResourcePathWithFilename:(NSString*) filename
{
    return [[NSBundle mainBundle] pathForResource:[[filename lastPathComponent] stringByDeletingPathExtension] ofType: [[filename lastPathComponent] pathExtension]];
}

//search like normal way: *abc* or prefix_* or *.txt
//+(NSMutableArray*) GetFileList:(NSString*) path searchString:(NSString*)searchString isFullPath:(BOOL)isFullPath isIncludeSubFolder:(BOOL)isIncludeSubFolder filterListType:(enum GetFileListType) filterListType
//{
//    NSMutableArray* files = [[NSMutableArray alloc] init];
//    NSError* error = nil;
//    NSArray* dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
//
//    if (!error) {
//        if ([StringLib isValid:searchString])
//        {
//            //SELF beginswith[c] 'a' SELF endswith[c] 'a' SELF contains[c] 'a'
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[c] %@", searchString];
//            NSArray *imagesOnly = [dirContents filteredArrayUsingPredicate:predicate];
//            files = [NSMutableArray arrayWithArray:imagesOnly];
//        }else{
//            files = [NSMutableArray arrayWithArray:dirContents];
//        }
//    }else{
//#ifdef DEBUG
//        NSLog(@"[FileLib.GetFileList] error: %@", [error localizedDescription]);
//#endif
//    }
//
//    NSMutableArray* result = [[NSMutableArray alloc] init];
//    NSMutableArray* resultSub = [[NSMutableArray alloc] init];
//    BOOL isDirectory;
//
//    if (isFullPath || isIncludeSubFolder || filterListType != GetFileListTypeAll)
//    {
//        for (int i = 0; i < files.count; i++) {
//            NSLog(@"--%@", files[i]);
//            NSString* filePath = [path stringByAppendingPathComponent:files[i]];
//            isDirectory = [self checkPathIsDirectory:filePath];
//
//            if (filterListType == GetFileListTypeAll
//                || (filterListType == GetFileListTypeFileOnly && !isDirectory)
//                || (filterListType == GetFileListTypeFolderOnly && isDirectory)
//                || (filterListType == GetFileListTypeImageOnly && IsImageFile(filePath))
//                || (filterListType == GetFileListTypeVideoOnly && IsVideoFile(filePath))
//                || (filterListType == GetFileListTypeImageVideoOnly && IsSupportFileType(filePath))
//                )
//            {
//                [result addObject: isFullPath ? filePath : files[i]];
//            }
//
//            if (isIncludeSubFolder && isDirectory) {
//                [resultSub addObjectsFromArray:[self getFileList:filePath searchString:searchString isFullPath:isFullPath isIncludeSubFolder:isIncludeSubFolder filterListType:filterListType]];
//            }
//        }
//
//        if (isIncludeSubFolder) {
//            [result addObjectsFromArray:resultSub];
//        }
//
//        return result;
//    }
//
//    return files;
//}

+(NSArray*)getFileList:(NSString*) path searchString:(NSString*)searchString isFullPath:(BOOL)isFullPath isIncludeSubFolder:(BOOL)isIncludeSubFolder filterListType:(enum GetFileListType) filterListType
{
    
    NSMutableArray* result;
    NSError* error = nil;
    NSArray* dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if (error) {
        NSLog(@"[FileLib.GetFileList] error: %@", [error localizedDescription]);
    }
    
    if (!isIncludeSubFolder && !isFullPath && filterListType == GetFileListTypeAll) {
        result = [NSMutableArray arrayWithArray: dirContents];
    }else{
        NSMutableArray* acceptFiles = [NSMutableArray new];
        BOOL isDirectory;
        NSString* filePath;
        for (NSString* file in dirContents) {
            filePath = [path stringByAppendingPathComponent:file];
            isDirectory = [self checkPathIsDirectory:filePath];
            
            if (filterListType == GetFileListTypeAll
                || (filterListType == GetFileListTypeFileOnly && !isDirectory)
                || (filterListType == GetFileListTypeFolderOnly && isDirectory)
                || (filterListType == GetFileListTypeImageOnly && IsImageFile(filePath))
                || (filterListType == GetFileListTypeVideoOnly && IsVideoFile(filePath))
                || (filterListType == GetFileListTypeImageVideoOnly && IsSupportFileType(filePath))
                )
            {
                [acceptFiles addObject: isFullPath ? filePath : file];
            }
            
            if (isIncludeSubFolder && isDirectory)
            {
                [acceptFiles addObjectsFromArray:[self getFileList:filePath searchString:searchString isFullPath:isFullPath isIncludeSubFolder:isIncludeSubFolder filterListType:filterListType]];
            }
        }
        
        result = [NSMutableArray arrayWithArray:acceptFiles];
    }
    
    //filter result
    if ([StringLib isValid:searchString])
    {
        //SELF beginswith[c] 'a' SELF endswith[c] 'a' SELF contains[c] 'a'
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[c] %@", searchString];
        result = [NSMutableArray arrayWithArray: [result filteredArrayUsingPredicate:predicate]];
    }
    
    return result;
}

+(NSMutableArray*)getFileList:(NSString*) path searchString:(NSString*)searchString isFullPath:(BOOL)isFullPath{
    return [self getFileList:path searchString:searchString isFullPath:isFullPath isIncludeSubFolder:NO filterListType:GetFileListTypeAll];
}

+(NSMutableArray*)getFileList:(NSString*) path fileType:(NSString*) fileType isFullPath:(BOOL)isFullPath{
    return [self getFileList:path searchString:fileType == nil ? nil : [NSString stringWithFormat:@"*.%@", fileType] isFullPath:isFullPath];
}

+(NSMutableArray*)getFileList:(NSString*) path fileType:(NSString*) fileType{
    
    return [self getFileList:path searchString:fileType == nil ? nil : [NSString stringWithFormat:@"*.%@", fileType] isFullPath:NO];
}



+(BOOL)createDirectory:(NSString*) path{
    NSFileManager* filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:path] == FALSE) {
        NSError* error = nil;
        [filemgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return FALSE;
        }
    }
    return TRUE;
}

+(BOOL)removeFileOrDirectory:(NSString*) path{
    NSFileManager* filemgr = [NSFileManager defaultManager];
    NSError* error = nil;
    if ([filemgr fileExistsAtPath:path]) {
        [filemgr removeItemAtPath:path error:&error];
        if (error) {
            return FALSE;
        }
    }
    return TRUE;
}


+(void)saveImage:(UIImage *)photo path:(NSString *)path{
    [self saveImage:photo path:path jpgCompressLevel:0.8];
}

+(void)saveImage:(UIImage *)photo path:(NSString *)path jpgCompressLevel:(CGFloat) jpgCompressLevel{
    NSData *imageData = nil;
    
    if ([[[path pathExtension] uppercaseString] isEqualToString:@".jpg"]) {
        imageData = UIImageJPEGRepresentation(photo, jpgCompressLevel);  // 1.0 = least compression, best quality
    }else{
        imageData = UIImagePNGRepresentation(photo);
    }
    
    
    [imageData writeToFile:path atomically:NO];
}

+(UIImagePickerController*)showPickerController: (id) container sourceType:(UIImagePickerControllerSourceType) sourceType
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = container;
    picker.sourceType = sourceType;
    
    //[((UIViewController*)container) presentModalViewController:picker animated:YES]; -> predicated
    [((UIViewController*)container) presentViewController:picker animated:YES completion:^{}];
    return picker;
}

+(BOOL)writeFile: (NSString*) filePath content:(NSString*) content{
    return [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+(BOOL)writeFileInDocument: (NSString*) fileName content:(NSString*) content{
    fileName = [self getDocumentPath: fileName];
    return [self writeFile:fileName content:content];
}

+(NSString*)readFile: (NSString*) filePath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }
    return nil;
}

+(NSString*)readFileInDocument:(NSString*) fileName{
    fileName = [self getDocumentPath: fileName];
    return [self readFile:fileName];
}

+(NSString*)readEmbedResourceFileWithFilename:(NSString *)filename{
    return [self readFile: [self getEmbedResourcePathWithFilename:filename] ];
}

+(BOOL)moveFileFromPath:(NSString*) fromPath toPath:(NSString*) toPath{
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr moveItemAtPath: fromPath toPath: toPath error: NULL]  == YES){
        
        return YES;
    }else{
        
        return NO;
    }
}

+(BOOL)copyFileFromPath:(NSString*) fromPath toPath:(NSString*) toPath{
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr copyItemAtPath: fromPath toPath: toPath error: NULL]  == YES){
        
        return YES;
    }else{
        
        return NO;
    }
}

+(BOOL)copyFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath
{
    [self createDirectory:toPath];
    
    NSString* destFile;
    
    for (NSString* file in [self getFileList:fromPath searchString:nil isFullPath:YES])
    {
        destFile = [toPath stringByAppendingPathComponent:file.lastPathComponent];
        
        if ([self checkPathIsDirectory:file])
        {
            [self copyFolderFromPath:file toPath: destFile ];
        }else{
            [self copyFileFromPath:file toPath: destFile ];
        }
    }
    
    return YES;
}

+(BOOL)moveFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath
{
    [self createDirectory:toPath];
    
    NSString* destFile;
    
    for (NSString* file in [self getFileList:fromPath searchString:nil isFullPath:YES])
    {
        destFile = [toPath stringByAppendingPathComponent:file.lastPathComponent];
        
        if ([self checkPathIsDirectory:file])
        {
            [self moveFolderFromPath:file toPath: destFile ];
        }else{
            [self moveFileFromPath:file toPath: destFile ];
        }
    }
    
    [self removeFileOrDirectory:fromPath];
    
    return YES;
}

+(ReturnSet*)renameFolderFromPath:(NSString*) fromPath toPath:(NSString*) toPath mergeFolderData:(BOOL) mergeFolderData removeOldFolder:(BOOL)removeOldFolder{
    NSString* oldFile = nil;
    NSString* newFile = nil;
    
    NSFileManager* filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:fromPath] == NO) {
        return [[ReturnSet alloc] initWithMessage:NO message:@"Source folder is not existed."];
    }
    
    if ([filemgr fileExistsAtPath:toPath] == YES) {
        if (mergeFolderData == NO) {
            return [[ReturnSet alloc] initWithMessage:NO message:@"Destination folder is existed."];
        }
    }else{//create folder if is not existed
        [self createDirectory:toPath];
    }
    
    //move file to new folder
    NSMutableArray* files = [self getFileList:fromPath fileType:nil];
    for (NSString* file in files) {
        oldFile = [fromPath stringByAppendingPathComponent:file];
        newFile = [toPath stringByAppendingPathComponent:file];
        [self moveFileFromPath:oldFile toPath:newFile];
    }
    
    //delete old folder
    if (removeOldFolder) {
        [self removeFileOrDirectory:fromPath];
    }
    
    return [[ReturnSet alloc] initWithResult:YES];
}


+(BOOL)checkPathExisted:(NSString*) path{
    NSFileManager* filemgr = [NSFileManager defaultManager];
    return [filemgr fileExistsAtPath:path];
}

+(BOOL)checkPathIsDirectory:(NSString*) path{
    BOOL isDirectory;
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: &isDirectory ] && isDirectory;
}

+(NSString*)getNewName:(NSString*)prefix suffix:(NSString*)suffix{
    NSString* keyname = @"FileLib_GetNewName";
    
    NSString* currentDate = [[DateObject initWithNSDate:[NSDate date]] toYMDString];
    NSString* defaultStr = [NSString stringWithFormat:@"%@_%06d", currentDate, 0];
    
    NSString* str = [self getAppPreference:keyname defaultValue:defaultStr];
    NSArray* parts = [str componentsSeparatedByString:@"_"];
    
    NSString* lastdate = [parts firstObject];
    NSInteger counter = [[parts lastObject] integerValue];
    
    if ([lastdate isEqualToString:currentDate]) {
        counter++;
    }else counter = 1;
    
    NSString* newStr = [NSString stringWithFormat:@"%@_%06ld", currentDate,(long)counter];
    [self setAppPreference:keyname value:newStr];
    
    prefix = prefix == nil ? @"" : prefix;
    suffix = suffix == nil ? @"" : suffix;
    
    return [NSString stringWithFormat:@"%@%@%@", prefix, newStr, suffix];
}

+(NSString*)getNewNameYMDHMSWithPrefix:(NSString*)prefix suffix:(NSString*)suffix{
    NSString* currentDate = [[DateObject initWithNSDate:[NSDate date]] toYMDHMSFileFormatString];
    
    prefix = prefix == nil ? @"" : prefix;
    suffix = suffix == nil ? @"" : suffix;
    
    return [NSString stringWithFormat:@"%@%@%@", prefix, currentDate, suffix];
}

+(void)setAppPreference:(NSString*) key value:(id)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+(id)getAppPreference:(NSString*)key defaultValue:(id)defaultValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults objectForKey:key];
    
    if( value == nil){
        [self setAppPreference:key value:defaultValue];
        return defaultValue;
    }
    
    return value;
}

+(double)getFileSizeWithPath:(NSString*) path
{
    NSError* error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    if(!error) return [[fileAttributes objectForKey:NSFileSize] doubleValue];
    return -1;
}

+(double)getFolderSizeWithPath:(NSString*) path includeSubFolder:(BOOL)includeSubFolder{
    double totalSize = 0;
    
    NSMutableArray* files = [self getFileList:path fileType:nil isFullPath:YES];
    
    for (NSString* file in files) {
        if ([self checkPathIsDirectory:file] && includeSubFolder) {
            totalSize += [self getFolderSizeWithPath:file includeSubFolder:YES];
        }else{
            totalSize += [self getFileSizeWithPath:file];
        }
    }
    
    return totalSize;
}


//auto add number to filename if destination file is existed
+(NSString*)genAutoFilenameWithSourcefile:(NSString*)sourcefile destinationFolder:(NSString*)destinationFolder{
    NSString* filepath = [destinationFolder stringByAppendingPathComponent:sourcefile.lastPathComponent];
    
    if (![self checkPathExisted:filepath]) return filepath;
    
    NSString* ext = sourcefile.pathExtension;
    NSString* filename = sourcefile.lastPathComponent;
    if ( [StringLib contains:@"." inString:filename] ) {
        filename = [filename stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",ext] withString:@""];
    }
    
    NSInteger counter = 2;
    while ([self checkPathExisted:filepath]) {
        filepath = [destinationFolder stringByAppendingPathComponent: [NSString stringWithFormat:@"%@ %ld%@%@", filename, (long)counter, [StringLib isValid:ext] ? @"." : @"", [StringLib isValid:ext] ? ext : @""] ];
        counter++;
    }
    
    return filepath;
}

+(NSArray*)sortFileList:(NSArray*) files sortType:(enum SortFileListType) sortType isSortAscending:(BOOL)isSortAscending
{
    return [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
            {
                NSComparisonResult result = NSOrderedSame;
                
                if (sortType == SortFileListCreateDate || sortType == SortFileListModifyDate) {
                    NSString* key = sortType == SortFileListModifyDate ? NSFileModificationDate : NSFileCreationDate;
                    NSDate* val1 = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1 error:nil][key];
                    NSDate* val2 = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2 error:nil][key];
                    
                    result = [val1 compare:val2];
                }else if (sortType == SortFileListFileSize){
                    NSNumber* val1 = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1 error:nil][NSFileSize];
                    NSNumber* val2 = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2 error:nil][NSFileSize];
                    
                    if (val1.floatValue < val2.floatValue) result = NSOrderedAscending;
                    if (val1.floatValue > val2.floatValue) result = NSOrderedDescending;
                }else if (sortType == SortFileListFileType || sortType == SortFileListFileName){
                    
                    NSString* string1 = sortType == SortFileListFileType ? [obj1 pathExtension] : [obj1 lastPathComponent];
                    NSString* string2 = sortType == SortFileListFileType ? [obj2 pathExtension] : [obj2 lastPathComponent];
                    
                    static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch;
                    result = [string1 compare:string2 options:comparisonOptions];
                }
                
                if (isSortAscending) {
                    return result;
                }else{
                    if (result == NSOrderedAscending) return NSOrderedDescending;
                    else if (result == NSOrderedDescending) return NSOrderedAscending;
                    else return NSOrderedSame;
                }
                
            }];
}

@end


















