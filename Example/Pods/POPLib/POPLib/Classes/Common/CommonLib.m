//
//  CommonLib.m
//  CommonLib
//
//  Created by popeveryday on 11/6/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import "CommonLib.h"
#import <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@implementation CommonLib



+(void)setAppPreference:(NSString*) key value:(id)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+(void)setAppPreference:(NSString*) key boolValue:(BOOL)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}

+(id)getAppPreference:(NSString*)key defaultValue:(id)defaultValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults objectForKey:key];
    
    if( value == nil && defaultValue != nil){
        [self setAppPreference:key value:defaultValue];
        return defaultValue;
    }
    
    return value;
}

+(NSInteger)randomFromInt:(NSInteger) from toInt:(NSInteger) to{
    return (( arc4random()%(to-from+1)) + from);
}

+(id)popRandomItemFromArray:(NSMutableArray*) array
{
    id item;
    
    for (int i = 0; i <=[self randomFromInt:0 toInt:array.count]; i++) {
        item = [array objectAtIndex:[self randomFromInt:0 toInt:array.count-1]];
    }
    
    [array removeObject:item];
    return item;
}

+(id)popFirstItemFromArray:(NSMutableArray*) array{
    if (array.count == 0) return nil;
    id item = [array objectAtIndex:0];
    [array removeObjectAtIndex:0];
    return item;
}

+(void)shufflingArray:(NSMutableArray *) array
{
    NSInteger count = [array count];
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger swap = [self randomFromInt:0 toInt:count-1];
        [array exchangeObjectAtIndex:swap withObjectAtIndex:i];
    }
}


+(UIColor*)colorFromHexString:(NSString *)hexString alpha:(float) alpha{
    unsigned rgbValue = 0;
    
    if ( [StringLib indexOf:@"#" inString:hexString] != 0 ) {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

+(void)addObserverBecomeActiveForObject:(id) container activeSelector:(SEL)activeSelector {
    [[NSNotificationCenter defaultCenter] addObserver:container
                                             selector:activeSelector
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:Nil];
}



+(NSArray*)sortArrayIndexPath:(NSArray*) arr ascending:(BOOL) ascending{
    NSArray* sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger r1 = [obj1 row];
        NSInteger r2 = [obj2 row];
        
        if (r1 < r2) {
            return ascending ? (NSComparisonResult)NSOrderedAscending : (NSComparisonResult)NSOrderedDescending;
        }
        if (r1 > r2) {
            return ascending ? (NSComparisonResult)NSOrderedDescending : (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}


+(NSString*)simulatorAppDirectoryPath{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject] path];
}


+(UIFont*)boldFont:(UIFont *)font
{
    if (GC_Device_iOsVersion < 8) {
        return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
    }else{
        return [UIFont boldSystemFontOfSize:font.pointSize];
    }
}

+(NSString*)deviceModelTypeCode{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    return platform;
}

+(NSString*)deviceModelType
{
    NSString *platform = [self deviceModelTypeCode];
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (CDMA)";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (GSM)";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (CDMA)";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (GSM)";
    if ([platform isEqualToString:@"iPhone10,1"])    return @"iPhone 8 (CDMA)";
    if ([platform isEqualToString:@"iPhone10,4"])    return @"iPhone 8 (GSM)";
    if ([platform isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus (CDMA)";
    if ([platform isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus (GSM)";
    if ([platform isEqualToString:@"iPhone10,3"])    return @"iPhone X (CDMA)";
    if ([platform isEqualToString:@"iPhone10,6"])    return @"iPhone X (GSM)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    // iPad PRO 9.7"
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7 Wifi (model A1673)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7 Wifi + Cellular (model A1674)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7 Wifi + Cellular (model A1675)";
    
    //iPad PRO 12.9"
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9 Wifi (model A1584)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9 Wifi + Cellular (model A1652)";
    
    //iPad (5th generation)
    if ([platform isEqualToString:@"iPad6,11"])      return @"iPad 2017 Wifi (model A1822)";
    if ([platform isEqualToString:@"iPad6,12"])      return @"iPad 2017 Wifi + Cellular (model A1823)";
    
    //iPad PRO 12.9" (2nd Gen)
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9 Gen 2 Wifi (model A1670)";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9 Gen 2 Wifi + Cellular (model A1671)";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9 Gen 2 Wifi + Cellular (model A1821)";
    
    //iPad PRO 10.5"
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5 Wifi (model A1701)";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5 Wifi + Cellular (model A1709)";
    
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+(NSString*)getDeviceByResolution
{
    NSDictionary* deviceSizes = @{   @"320,480": @"iphone4"
                                     , @"480,320": @"iphone4"
                                     , @"320,568": @"iphone5"
                                     , @"568,320": @"iphone5"
                                     , @"667,375": @"iphone6"
                                     , @"375,667": @"iphone6"
                                     , @"414,736": @"iphone6p"
                                     , @"736,414": @"iphone6p"
                                     , @"375,812": @"iphonex"
                                     , @"812,375": @"iphonex"
                                     , @"768,1024": @"ipadhd"
                                     , @"1024,768": @"ipadhd"
                                     , @"834,1112": @"ipadpro10"
                                     , @"1112,834": @"ipadpro10"
                                     , @"1024,1366": @"ipadpro12"
                                     , @"1366,1024": @"ipadpro12"
                                     };
    
    NSString* size = [NSString stringWithFormat:@"%@,%@", @(GC_ScreenWidth), @(GC_ScreenHeight) ];
    NSString* device = [deviceSizes objectForKey:size];
    if(device) return device;
    return GC_Device_IsIpad ? @"ipad" : @"iphone";
}

+(NSString*)localizedText:(NSString*)text languageCode:(NSString*)code
{
    if (code == nil) {
        code = [self getAppPreference:@"default_language_code" defaultValue:@"-"];
    }
    
    if (![StringLib isValid:code] || [code isEqualToString:@"-"])
    {
        return NSLocalizedString(text, nil);
    }
    
    NSString * path = [[NSBundle mainBundle] pathForResource:code ofType:@"lproj"];
    NSBundle * bundle = nil;
    if(path == nil){
        bundle = [NSBundle mainBundle];
    }else{
        bundle = [NSBundle bundleWithPath:path];
    }
    return [bundle localizedStringForKey:text value:text table:nil];
}

+(void)localizedDefaultLanguageCode:(NSString*)code
{
    [self setAppPreference:@"default_language_code" value:code];
}

+(NSString*)getLocalizedWithDefaultLanguageCode:(NSString*)code
{
    return [self getAppPreference:@"default_language_code" defaultValue:code];
}



+(UIDeviceOrientation)deviceOrientation
{
#ifndef POPLIB_APP_EXTENSIONS
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if( [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown ){
        if(orientation == 0) //Default orientation
            return UIDeviceOrientationUnknown;
        else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
            return UIDeviceOrientationPortraitUpsideDown;
        else if(orientation == UIInterfaceOrientationPortrait)
            return UIDeviceOrientationPortrait;
        else if(orientation == UIInterfaceOrientationLandscapeLeft)
            return UIDeviceOrientationLandscapeLeft;
        else if(orientation == UIInterfaceOrientationLandscapeRight)
            return UIDeviceOrientationLandscapeRight;
    }
#endif
    
    return [[UIDevice currentDevice] orientation];
}

+(NSString*) genJsonFromObject:(id)obj
{
    @try{
        id finalObject = [self serializationObject:obj];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalObject
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
            return nil;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return [NSString stringWithFormat:@"%@", jsonString];
    }@catch(NSException* exception)
    {
        NSString* error = [NSString stringWithFormat:@"Exception(%s): \n%@", __func__, exception];
        NSLog(@"%@", error);
    }
    return nil;
}

+(id) serializationObject:(id) obj
{
    if (![obj isKindOfClass:[NSDictionary class]] && ![obj isKindOfClass:[NSArray class]]) {
        return [self serializationDictionaryFromObject:obj];
    }
    else if([obj isKindOfClass:[NSArray class]])
    {
        NSMutableArray* array = [NSMutableArray new];
        for (id item in (NSArray*)obj) {
            [array addObject:[self serializationObject:item] ];
        }
        return array;
    }
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    for (id key in ((NSDictionary*)obj).allKeys ) {
        id value = [((NSDictionary*)obj) objectForKey:key];
        
        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]]
            || [value isKindOfClass:[NSNull class]]
            )
        {
            [dict setObject:(value ? value : @"") forKey:key];
        }
        else
        {
            [dict setObject:(value ? [self serializationObject:value] : @"") forKey:key];
        }
    }
    
    return dict;
}

+(NSDictionary*) serializationDictionaryFromObject:(id) obj
{
    @autoreleasepool
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        unsigned int count = 0;
        objc_property_t *attributes = class_copyPropertyList([obj class], &count);
        objc_property_t property;
        NSString *key, *value;
        
        for (int i = 0; i < count; i++)
        {
            property = attributes[i];
            key = [NSString stringWithUTF8String:property_getName(property)];
            value = [obj valueForKey:key];
            
            if ([value isKindOfClass:[NSString class]]
                || [value isKindOfClass:[NSNumber class]]
                || [value isKindOfClass:[NSNull class]]
                )
            {
                [dict setObject:(value ? value : @"") forKey:key];
            }
            else
            {
                [dict setObject:(value ? [self serializationObject:value] : @"") forKey:key];
            }
            
        }
        
        free(attributes);
        attributes = nil;
        
        return dict;
    }
}



+(BOOL) saveObject:(id)obj toFilePath:(NSString*)filePath allowSafeBackup:(BOOL)allowSafeBackup
{
    if (allowSafeBackup)
    {
        NSString* safeFile = filePath.lastPathComponent.stringByDeletingPathExtension;
        safeFile = [safeFile stringByAppendingString:@"_safe_backup"];
        safeFile = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:safeFile];
        if([StringLib isValid:filePath.pathExtension]) safeFile = [NSString stringWithFormat:@"%@.%@", safeFile, filePath.pathExtension];
        
        
        if ([FileLib checkPathExisted:filePath])
        {
            if([FileLib checkPathExisted:safeFile]) unlink([safeFile UTF8String]);
            [FileLib copyFileFromPath:filePath toPath:safeFile];
            unlink([filePath UTF8String]);
        }
        
        return [NSKeyedArchiver archiveRootObject:obj toFile:filePath];
    }
    else
    {
        if([FileLib checkPathExisted:filePath]) unlink([filePath UTF8String]);
        return [NSKeyedArchiver archiveRootObject:obj toFile:filePath];
    }
    
}

+(id) loadObjectFromFile:(NSString*) filePath allowSafeBackup:(BOOL)allowSafeBackup{
    return [self loadObjectFromFile:filePath allowSafeBackup:allowSafeBackup validateBlock:nil];
}

+(id) loadObjectFromFile:(NSString*) filePath allowSafeBackup:(BOOL)allowSafeBackup validateBlock:(BOOL (^)(id obj)) validateBlock
{
    if (allowSafeBackup)
    {
        NSString* safeFile = filePath.lastPathComponent.stringByDeletingPathExtension;
        safeFile = [safeFile stringByAppendingString:@"_safe_backup"];
        safeFile = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:safeFile];
        if([StringLib isValid:filePath.pathExtension]) safeFile = [NSString stringWithFormat:@"%@.%@", safeFile, filePath.pathExtension];
        
        if ([FileLib checkPathExisted:filePath])
        {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            if(obj){
                if(validateBlock){
                    if(validateBlock(obj))return obj;
                }else{
                    return obj;
                }
            }
        }
        
        if ([FileLib checkPathExisted:safeFile]){
            id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:safeFile];
            if(obj){
                if(validateBlock){
                    if(validateBlock(obj))return obj;
                }else{
                    return obj;
                }
            }
        }
        return nil;
    }
    else
    {
        if(![FileLib checkPathExisted:filePath]) return nil;
        id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if(obj){
            if(validateBlock){
                if(validateBlock(obj))return obj;
            }else{
                return obj;
            }
        }
        return nil;
    }
}

@end




