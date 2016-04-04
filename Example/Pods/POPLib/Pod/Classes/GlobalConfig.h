//
//  CommonLib.h
//  CommonLib
//
//  Created by popeveryday on 11/6/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

enum ViewDesignStyle
{
    ViewDesignStyleDefault,
    ViewDesignStyleFlatBlue,
    ViewDesignStyleFlatCustomColor,
};

#define GC_App_Version [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

#define GC_Screen_IsIphone5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define GC_ScreenWidth [UIScreen mainScreen].bounds.size.width
#define GC_ScreenHeight [UIScreen mainScreen].bounds.size.height
#define GC_ScreenLong GC_ScreenWidth > GC_ScreenHeight ? GC_ScreenWidth : GC_ScreenHeight
#define GC_ScreenShort GC_ScreenWidth < GC_ScreenHeight ? GC_ScreenWidth : GC_ScreenHeight
#define GC_ScreenCenter CGPointMake(GC_ScreenWidth/2, GC_ScreenHeight/2)
#define GC_ScreenBound CGRectMake(0, 0, GC_ScreenWidth, GC_ScreenHeight)
#define GC_Device_IsIpad     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define IsDeviceLandscape(viewcontroller) UIInterfaceOrientationIsLandscape(self.interfaceOrientation)
#define GC_Device_Orientation [[UIDevice currentDevice] orientation]
#define GC_Device_IsLandscape GC_Device_Orientation == UIDeviceOrientationLandscapeLeft || GC_Device_Orientation == UIDeviceOrientationLandscapeRight


#define GC_Device_iOsVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define GC_Device_iOs6  GC_Device_iOsVersion < 7
#define GC_Device_IsRetina [[UIScreen mainScreen] scale] == 2.0

#define GC_CollectionViewItem_SizeList @{ @"iphonehd6": @89, @"iphonehd6p": @78 }
#define CollectionViewItem_Size(isIpad) ( isIpad ? CGSizeMake(100,100) : ([GC_CollectionViewItem_SizeList.allKeys containsObject:GC_MobileAds_Device] ? CGSizeMake([[GC_CollectionViewItem_SizeList objectForKey:GC_MobileAds_Device] floatValue], [[GC_CollectionViewItem_SizeList objectForKey:GC_MobileAds_Device] floatValue]) : CGSizeMake(75,75)) )
#define CollectionViewItem_ImageThumbSize(isIpad) ( isIpad ? CGSizeMake(200,200) : CGSizeMake(150,150) )

#define GC_CollectionViewItem_Size CollectionViewItem_Size(GC_Device_IsIpad)
#define GC_CollectionViewItem_ImageThumbSize CollectionViewItem_ImageThumbSize(GC_Device_IsIpad)

#define GC_Keyboard_PortraiHeight = 216;
#define GC_Keyboard_LandscapeHeight = 162;

#define GC_FileType_Image @",PNG,JPG,JPEG,BMP,GIF,TIF,"
#define GC_FileType_Video @",MP4,M4V,MOV,"
#define GC_FileType_Office @",DOC,DOCX,PPT,PPTX,XLS,XLSX,PDF,HTML,HTM,KEY,NUMBERS,PAGES,"
#define GC_FileType_Text @",TXT,RTF,INI,INF,CSV,HTML,HTM,"
#define GC_FileType_Sound @",MP3,WAV,"
#define GC_FileType_Archive @",ZIP,7Z,RAR,ACE,"
#define GC_FileType_QLPreview @",MP3,MP4,M4V,MOV,XLS,KEY.ZIP,NUMBERS.ZIP,PAGES.ZIP,RTFD.ZIP,PDF,PPT,DOC,RTF,KEY,NUMBERS,PAGES,TXT,CSV,HTML,HTM,GIF,"

#define GC_OpenIn_Identifiers @"ZIP=com.pkware.zip-archive&PDF=com.adobe.pdf&MP3=public.mp3&MP4=public.mpeg-4&MOV=com.apple.quicktime-movie&XLS=com.microsoft.excel.xls&DOC=com.microsoft.word.doc&PPT=com.microsoft.powerpoint.ppt&KEY=com.apple.keynote.key&HTML=public.html&TXT=public.plain-text&RTF=public.rtf"



#define GC_FileType_Supported [[[[[GC_FileType_Image stringByAppendingString:GC_FileType_Video] stringByAppendingString:GC_FileType_Office] stringByAppendingString:GC_FileType_Text] stringByAppendingString:GC_FileType_Sound] stringByAppendingString:GC_FileType_Archive]

#define IsImageFile(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Image])
#define IsVideoFile(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Video])
#define IsOfficeFile(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Office])
#define IsTextFile(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Text])
#define IsSoundFile(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Sound])
#define IsArchiveFile(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Archive])

#define IsSupportFileType(path) ([StringLib contains:[NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_Supported])
#define IsQLSupportType(path)([StringLib contains: [NSString stringWithFormat:@",%@,", [[path pathExtension] uppercaseString]] inString:GC_FileType_QLPreview])

#define IsOpenInAvailable(path) ( [StringLib contains:[NSString stringWithFormat:@"&%@=", [[path pathExtension] uppercaseString]] inString:[@"&" stringByAppendingString:GC_OpenIn_Identifiers]] )



#define randomf(minX,maxX) ((float)(arc4random() % (maxX - minX + 1)) + (float)minX)
#define ResourcePath(path) [[NSBundle mainBundle] pathForResource:path ofType:nil]
#define ImageWithPath(path) [UIImage imageWithContentsOfFile:path]
#define ImageViewWithPath(path) [[UIImageView alloc] initWithImage: ImageWithPath(path)]
#define ImageViewWithImage(img) [[UIImageView alloc] initWithImage: img]
#define ImageViewWithImagename(name) [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]]

#define IsSideOf(side) GC_ScreenWidth == side/2 || GC_ScreenHeight == side/2
#define GC_MobileAds_Device GC_Device_IsIpad ? (GC_Device_IsRetina ? @"ipadhd" : @"ipad") : IsSideOf((2208/3)*2) ? @"iphonehd6p" : IsSideOf(1334) ? @"iphonehd6" : IsSideOf(1136) ? @"iphonehd5" : IsSideOf(960) ? @"iphonehd" : @"iphone"
#define GC_MobileAds_Url [NSString stringWithFormat:@"http://services.poptato.com/mobileads/?device=%@&appleid=[appleid]", GC_MobileAds_Device]

#define GC_Path_Inbox [FileLib getDocumentPath:@"Inbox"]

#define GC_ObserverKey_DropboxConnected 9001
#define GC_ObserverKey_DropboxPickerUploaded 9002
#define GC_ObserverKey_DropboxPickerDownloaded 9003

#define GC_Popover_Size CGSizeMake(480, 640)

#define LocalizedText(text,lang) [CommonLib localizedText:text languageCode:lang]
#define LocalizedDefaultLanguageCode(lang) [CommonLib localizedDefaulLanguageCode:lang]




