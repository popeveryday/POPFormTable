//
//  StringLib.m
//  PhotoLib
//
//  Created by popeveryday on 11/22/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "StringLib.h"
#import "NSDate+NVTimeAgo.h"

@implementation StringLib

+(Hashtable*) DeparseString:(NSString*)content
{
    return [self DeparseString:content autoTrimKeyValue:YES];
}

+(Hashtable*) DeparseString:(NSString*)content autoTrimKeyValue:(BOOL)isTrimContent
{
    if (![self IsValid:content]) {
        return nil;
    }
    
    Hashtable* result = [[Hashtable alloc] init];
    result.AutoTrimKeyValue = isTrimContent;
    
    NSArray* params = [content componentsSeparatedByString:@"&"];
    NSArray* parts = nil;
    for (NSString* param in params) {
        if ([param isEqualToString:@""] || [param rangeOfString:@"="].location == NSNotFound) {
            continue;
        }
        
        parts = [param componentsSeparatedByString:@"="];
        [result AddValue:[self ParseStringValidate:parts[1] isParseString:NO] forKey:[self ParseStringValidate:parts[0] isParseString:NO]];
    }
    
    return result;
}

+(NSString*) ParseString:(Hashtable*)hash
{
    NSString* result = @"[@]";
    
    for (NSString* key in hash.Keys) {
        result = [result stringByAppendingFormat:@"&%@=%@", [self ParseStringValidate:key isParseString:YES], [self ParseStringValidate:[hash Hashtable_GetValueForKey:key] isParseString:YES] ];
    }
    
    return [[result stringByReplacingOccurrencesOfString:@"[@]&" withString:@""] stringByReplacingOccurrencesOfString:@"[@]" withString: @""];
}

+(NSString*) ParseStringFromDictionary:(NSDictionary*)dictionary
{
    NSString* result = @"[@]";
    
    for (NSString* key in dictionary.allKeys) {
        result = [result stringByAppendingFormat:@"&%@=%@", [self ParseStringValidate:key isParseString:YES], [self ParseStringValidate:[dictionary valueForKey:key] isParseString:YES]];
    }
    
    return [[result stringByReplacingOccurrencesOfString:@"[@]&" withString:@""] stringByReplacingOccurrencesOfString:@"[@]" withString: @""];
}

+(NSString*) ParseStringValidate:(id) value isParseString:(BOOL)isParseString{
    
    NSString* andStr = @"[AnD]";
    NSString* equalStr = @"[EqL]";
    NSString* valueStr = [NSString stringWithFormat:@"%@",value];
    
    if (isParseString) {
        return [[valueStr stringByReplacingOccurrencesOfString:@"&" withString:andStr] stringByReplacingOccurrencesOfString:@"=" withString:equalStr];
    }else{
        return [[valueStr stringByReplacingOccurrencesOfString:andStr withString:@"&"] stringByReplacingOccurrencesOfString:equalStr withString:@"="];
    }
}

+(NSString*) GetHashtableValueWithKey:(NSString*)key fromHashString:(NSString*)hashString{
    Hashtable* hash = [self DeparseString:hashString];
    return [hash Hashtable_GetValueForKey:key];
}








+(NSString*) FormatDouble:(double) number decimalLength:(int) decimalLength
{
    return [StringLib FormatNumber:[NSNumber numberWithDouble:number] decimalLength:decimalLength];
}

+(NSString*) FormatNumber:(NSNumber*) number decimalLength:(int) decimalLength{
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:decimalLength];
    return [formatter stringFromNumber:number];
}

+(NSString*) FormatFileSizeWithByteValue:(double)number{
    NSArray* subfix = @[ @"B", @"KB", @"MB", @"TB" ];
    NSInteger subfixIndex = 0;
    
    while (true) {
        if (number < 1024 || subfixIndex == subfix.count-1) {
            return [NSString stringWithFormat:@"%@ %@", [self FormatDouble:number decimalLength:2], subfix[subfixIndex] ];
        }
        
        number = number / 1024.0;
        subfixIndex++;
    }
}

+(NSString*) FormatDate:(NSDate*) date format:(NSString*) format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

+(NSString*) FormatVideoDurationWithSeconds:(double) duration splitString:(NSString*)splitString{
    int minutes = duration/60;
    int seconds = duration - (minutes*60);
    return [NSString stringWithFormat:@"%d%@%@%d",minutes, [StringLib IsValid:splitString] ? splitString : @":" ,seconds>9?@"":@"0",seconds ];
}

+(NSString*) FormatTimeAgo:(NSDate*) date
{
    return [date formattedAsTimeAgo];
}







+(BOOL) IsValid:(NSString*)str{
    if (str == nil) return NO;
    str = [self Trim:str];
    return str.length > 0;
}

+(NSString*) Trim:(NSString*) str{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSInteger) IndexOf:(NSString*) str inString:(NSString*) sourcestr{
    return  [self IndexOf:str inString:sourcestr fromIndex:0];
}

+(NSInteger) IndexOf:(NSString*) str inString:(NSString*) sourcestr fromIndex:(NSInteger) fromIndex
{
    sourcestr = [sourcestr substringFromIndex:fromIndex];
    
    NSRange rs = [sourcestr rangeOfString:str];
    if (rs.location == NSNotFound) {
        return -1;
    }
    return rs.location;
}

+(NSInteger) LastIndexOf:(NSString*)searchStr inString:(NSString*)srcString{
    NSRange rs = [srcString rangeOfString:searchStr options:NSBackwardsSearch];
    if (rs.location == NSNotFound) {
        return -1;
    }
    return rs.location;
}


+(BOOL) Contains:(NSString*) str inString:(NSString*) scr{
    return [self IndexOf:str inString:scr] >= 0;
}

+(BOOL) IsValidEmail:(NSString *)str{
    NSInteger indexAmoc = [self IndexOf:@"@" inString:str];
    NSInteger indexCham = [self LastIndexOf:@"." inString:str];
    if (str.length < 5 || indexAmoc == -1 || indexCham == -1 || indexAmoc > indexCham || indexAmoc == 0) {
        return NO;
    } 
    return YES;
}

+(BOOL) IsEqualString:(NSString*) str1 withString:(NSString*) str2{
    
    if ([str1 isEqualToString:str2]) return YES;
    if (str1 == nil || str2 == nil) return NO;
    
    str1 = [[self Trim:str1] uppercaseString];
    str2 = [[self Trim:str2] uppercaseString];
    
    return [str1 isEqualToString:str2];
}



+(NSString*) SubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr{
    source = [NSString stringWithFormat:@" %@", source];
    NSInteger index = [self IndexOf:startStr inString:source];
    if (index == -1) return nil;
    
    index += startStr.length;
    
    NSInteger endIndex = [self IndexOf:endStr inString:source fromIndex:index];
    
    if (endIndex == -1) return nil;
    
    return [[source substringFromIndex:index] substringToIndex:endIndex];
}

+(NSDictionary*) DeparseJson:(NSString*)jsonString{
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return json;
}


@end















