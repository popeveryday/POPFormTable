//
//  CommonLib.m
//  CommonLib
//
//  Created by popeveryday on 11/6/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import "CommonLib.h"
#import <sys/sysctl.h>


@implementation CommonLib

+(void)alertWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:container
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    
    if (otherButtonTitles != nil)
    {
        [alert addButtonWithTitle:otherButtonTitles];
        
        va_list args;
        va_start(args, otherButtonTitles);
        NSString* name;
        while ((name = va_arg(args, NSString*))) {
            if (name != nil && ![name isEqualToString:@""]) {
                [alert addButtonWithTitle: name];
            }
        }
        
        
        
        
        va_end(args);
    }
    
    [alert show];
    
}

+(void)alertWithTitle:(NSString*) title message:(NSString*) message
{
    [self alertWithTitle:title message:message container:nil cancelButtonTitle:LocalizedText(@"OK",nil) otherButtonTitles:nil];
    
}

+(void)alert:(NSString*) message
{
    [self alertWithTitle: LocalizedText(@"Message",nil) message:message container:nil cancelButtonTitle: LocalizedText(@"OK",nil) otherButtonTitles:nil];
}

+(UIAlertView*)alertLoginBoxWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:container
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles,nil];
    if (otherButtonTitles != nil) {
        va_list args;
        va_start(args,otherButtonTitles);
        NSString* name = va_arg(args, NSString*);
        if (name != nil && ![name isEqualToString:@""]) {
            [alert addButtonWithTitle: name];
        }
        va_end(args);
    }
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    [alert show];
    
    return alert;
}

+(UIAlertView*)alertInputBoxWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:container
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles,nil];
    if (otherButtonTitles != nil) {
        va_list args;
        va_start(args,otherButtonTitles);
        NSString* name = va_arg(args, NSString*);
        if (name != nil && ![name isEqualToString:@""]) {
            [alert addButtonWithTitle: name];
        }
        va_end(args);
    }
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    [alert show];
    
    return alert;
}

+(UIAlertView*)alertSecureInputBoxWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:container
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles,nil];
    if (otherButtonTitles != nil) {
        va_list args;
        va_start(args,otherButtonTitles);
        NSString* name = va_arg(args, NSString*);
        if (name != nil && ![name isEqualToString:@""]) {
            [alert addButtonWithTitle: name];
        }
        va_end(args);
    }
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [alert show];
    
    return alert;
}


+(void)actionSheetWithTitle:(NSString*) title container:(id) container cancelButtonTitle:(NSString*) cancelButtonTitle destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:container
                                                    cancelButtonTitle: nil
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:otherButtonTitles,nil];
    
    if (otherButtonTitles != nil) {
        va_list args;
        va_start(args,otherButtonTitles);
        NSString* name = va_arg(args, NSString*);
        if (name != nil && ![name isEqualToString:@""]) {
            [actionSheet addButtonWithTitle: name];
        }
        va_end(args);
    }
    
    [actionSheet addButtonWithTitle:cancelButtonTitle];
    actionSheet.cancelButtonIndex = [actionSheet.subviews count] - 2;
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView: [container view]];
}

+(void)actionSheetWithTitle:(NSString*) title container:(id) container cancelButtonTitle:(NSString*) cancelButtonTitle destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitlesArray:(NSArray*)otherButtonTitles
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: title
                                                             delegate: container
                                                    cancelButtonTitle: nil
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: nil];
    
    
    if ( [StringLib IsValid:destructiveButtonTitle] ) {
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
        [actionSheet setDestructiveButtonIndex:0];
    }
    
    if (otherButtonTitles != nil) {
        for (NSString* name in otherButtonTitles) {
            [actionSheet addButtonWithTitle: name];
        }
    }
    
    [actionSheet addButtonWithTitle:cancelButtonTitle];
    [actionSheet setCancelButtonIndex: actionSheet.subviews.count - 2 ];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView: [container view]];
}

+(void)actionSheetWithTitle:(NSString*) title container:(UIView*) container delegate:(id)delegate cancelButtonTitle:(NSString*) cancelButtonTitle destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitlesArray:(NSArray*)otherButtonTitles
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: title
                                                             delegate: delegate
                                                    cancelButtonTitle: nil
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: nil];
    
    
    if ( [StringLib IsValid:destructiveButtonTitle] ) {
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
        [actionSheet setDestructiveButtonIndex:0];
    }
    
    if (otherButtonTitles != nil) {
        for (NSString* name in otherButtonTitles) {
            [actionSheet addButtonWithTitle: name];
        }
    }
    
    [actionSheet addButtonWithTitle:cancelButtonTitle];
    [actionSheet setCancelButtonIndex: actionSheet.subviews.count - 1 ];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView: container];
}

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
    
    if ( [StringLib IndexOf:@"#" inString:hexString] != 0 ) {
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

+(BOOL)alertInternetConnectionStatusWithTitle:(NSString*) title message:(NSString*)message{
    if (![NetLib IsInternetAvailable]) {
        [self alertWithTitle: title == nil ? LocalizedText(@"Connection error",nil) : title message: message == nil ? LocalizedText(@"Unable to connect with the server.\nCheck your internet connection and try again.",nil) : message ];
        return NO;
    }
    return YES;
}

+(BOOL)alertInternetConnectionStatus{
    return [self alertInternetConnectionStatusWithTitle:nil message:nil];
}

+(NSArray*)alertUpgrageFeaturesWithContainer:(id)container isIncludeRestoreButton:(BOOL)isIncludeRestoreButton{
    [self alertWithTitle:LocalizedText( @"Upgrage Required" ,nil) message:LocalizedText( @"To unlock this feature you need to upgrade to pro version. Would you like to upgrade now?" ,nil) container:container cancelButtonTitle:LocalizedText( @"Later" ,nil) otherButtonTitles:LocalizedText( @"Yes, upgrade now" ,nil), isIncludeRestoreButton ? LocalizedText( @"Restore purchases" ,nil) : nil, nil];
    return @[LocalizedText( @"Yes, upgrade now" ,nil), LocalizedText( @"Restore purchases" ,nil)];
}

+(NSArray*)alertUpgrageFeaturesUnlimitWithContainer:(id)container limitMessage:(NSString*)limitMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton
{
    NSString* message = LocalizedText(@"To use unlimited features you need to upgrade to pro version. Would you like to upgrade now?",nil);
    if ( [StringLib IsValid:limitMessage] ) {
        message = [NSString stringWithFormat:@"%@\n%@",limitMessage, message];
    }
    
    
    [self alertWithTitle:LocalizedText(@"Upgrage Required",nil) message: message container:container cancelButtonTitle:LocalizedText(@"Later",nil) otherButtonTitles:LocalizedText(@"Yes, upgrade now",nil), isIncludeRestoreButton ? LocalizedText(@"Restore purchases",nil) : nil, nil];
    
    return @[LocalizedText(@"Yes, upgrade now",nil), LocalizedText(@"Restore purchases",nil)];
}

+(NSArray*)alertUpgrageProVersionWithContainer:(id)container featuresMessage:(NSString*)featuresMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton
{
    NSString* message = LocalizedText(@"Purchase to unlock following features?",nil);
    
    if ( [StringLib IsValid:featuresMessage] ) {
        message = [NSString stringWithFormat:@"%@\n%@", message, featuresMessage];
    }else{
        message = LocalizedText(@"Purchase to unlock full features?",nil);
    }
    
    
    [self alertWithTitle:LocalizedText(@"Upgrage to Pro Version",nil) message: message container:container cancelButtonTitle:LocalizedText(@"Later",nil) otherButtonTitles:LocalizedText(@"Yes, upgrade now",nil), isIncludeRestoreButton ? LocalizedText(@"Restore purchases",nil) : nil, nil];
    
    return @[LocalizedText(@"Yes, upgrade now",nil), LocalizedText(@"Restore purchases",nil)];
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


+(void)boldFontIOS7ForLabel:(UILabel *)label
{
    UIFont *currentFont = label.font;
    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
    label.font = newFont;
}

+(NSString*)deviceModelType
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
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
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+(NSString*)localizedText:(NSString*)text languageCode:(NSString*)code
{
    if (code == nil) {
        code = [self getAppPreference:@"default_language_code" defaultValue:@"-"];
    }
    
    if (![StringLib IsValid:code] || [code isEqualToString:@"-"]) {
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

+(void)localizedDefaulLanguageCode:(NSString*)code
{
    [self setAppPreference:@"default_language_code" value:code];
}

@end




