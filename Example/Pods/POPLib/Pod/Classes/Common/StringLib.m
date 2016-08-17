//
//  StringLib.m
//  PhotoLib
//
//  Created by popeveryday on 11/22/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "StringLib.h"
#import "NSDate+NVTimeAgo.h"
#import <Foundation/NSNull.h>


@implementation StringLib

+(Hashtable*)deparseString:(NSString*)content
{
    return [self deparseString:content autoTrimKeyValue:YES];
}

+(Hashtable*)deparseString:(NSString*)content autoTrimKeyValue:(BOOL)isTrimContent
{
    if (![self isValid:content]) {
        return nil;
    }
    
    Hashtable* result = [[Hashtable alloc] init];
    result.autoTrimKeyValue = isTrimContent;
    
    NSArray* params = [content componentsSeparatedByString:@"&"];
    NSArray* parts = nil;
    for (NSString* param in params) {
        if ([param isEqualToString:@""] || [param rangeOfString:@"="].location == NSNotFound) {
            continue;
        }
        
        parts = [param componentsSeparatedByString:@"="];
        [result addValue:[self parseStringValidate:parts[1] isParseString:NO] forKey:[self parseStringValidate:parts[0] isParseString:NO]];
    }
    
    return result;
}

+(NSString*)parseString:(Hashtable*)hash
{
    NSString* result = @"[@]";
    
    for (NSString* key in hash.keys) {
        result = [result stringByAppendingFormat:@"&%@=%@", [self parseStringValidate:key isParseString:YES], [self parseStringValidate:[hash hashtable_GetValueForKey:key] isParseString:YES] ];
    }
    
    return [[result stringByReplacingOccurrencesOfString:@"[@]&" withString:@""] stringByReplacingOccurrencesOfString:@"[@]" withString: @""];
}

+(NSString*)parseStringFromDictionary:(NSDictionary*)dictionary
{
    NSString* result = @"[@]";
    
    for (NSString* key in dictionary.allKeys) {
        result = [result stringByAppendingFormat:@"&%@=%@", [self parseStringValidate:key isParseString:YES], [self parseStringValidate:[dictionary valueForKey:key] isParseString:YES]];
    }
    
    return [[result stringByReplacingOccurrencesOfString:@"[@]&" withString:@""] stringByReplacingOccurrencesOfString:@"[@]" withString: @""];
}

+(NSString*)parseStringValidate:(id) value isParseString:(BOOL)isParseString{
    
    NSString* andStr = @"[AnD]";
    NSString* equalStr = @"[EqL]";
    NSString* valueStr = [NSString stringWithFormat:@"%@",value];
    
    if (isParseString) {
        return [[valueStr stringByReplacingOccurrencesOfString:@"&" withString:andStr] stringByReplacingOccurrencesOfString:@"=" withString:equalStr];
    }else{
        return [[valueStr stringByReplacingOccurrencesOfString:andStr withString:@"&"] stringByReplacingOccurrencesOfString:equalStr withString:@"="];
    }
}

+(NSString*)getHashtableValueWithKey:(NSString*)key fromHashString:(NSString*)hashString{
    Hashtable* hash = [self deparseString:hashString];
    return [hash hashtable_GetValueForKey:key];
}








+(NSString*)formatDouble:(double) number decimalLength:(int) decimalLength
{
    return [StringLib formatNumber:[NSNumber numberWithDouble:number] decimalLength:decimalLength];
}

+(NSString*)formatNumber:(NSNumber*) number decimalLength:(int) decimalLength{
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:decimalLength];
    return [formatter stringFromNumber:number];
}

+(NSString*)formatFileSizeWithByteValue:(double)number{
    NSArray* subfix = @[ @"B", @"KB", @"MB", @"TB" ];
    NSInteger subfixIndex = 0;
    
    while (true) {
        if (number < 1024 || subfixIndex == subfix.count-1) {
            return [NSString stringWithFormat:@"%@ %@", [self formatDouble:number decimalLength:2], subfix[subfixIndex] ];
        }
        
        number = number / 1024.0;
        subfixIndex++;
    }
}

+(NSString*)formatDate:(NSDate*) date format:(NSString*) format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

+(NSString*)formatVideoDurationWithSeconds:(double) duration splitString:(NSString*)splitString{
    int minutes = duration/60;
    int seconds = duration - (minutes*60);
    return [NSString stringWithFormat:@"%d%@%@%d",minutes, [StringLib isValid:splitString] ? splitString : @":" ,seconds>9?@"":@"0",seconds ];
}

+(NSString*)formatTimeAgo:(NSDate*) date
{
    return [date formattedAsTimeAgo];
}







+(BOOL)isValid:(NSString*)str{
    if (str == nil || [str isEqual:[NSNull null]] || [str isKindOfClass:[NSNull class]]) return NO;
    str = [self trim:str];
    return str.length > 0;
}

+(NSString*)trim:(NSString*) str{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSInteger)indexOf:(NSString*) str inString:(NSString*) sourcestr{
    return  [self indexOf:str inString:sourcestr fromIndex:0];
}

+(NSInteger)indexOf:(NSString*) str inString:(NSString*) sourcestr fromIndex:(NSInteger) fromIndex
{
    sourcestr = [sourcestr substringFromIndex:fromIndex];
    
    NSRange rs = [sourcestr rangeOfString:str];
    if (rs.location == NSNotFound) {
        return -1;
    }
    return rs.location;
}

+(NSInteger)lastIndexOf:(NSString*)searchStr inString:(NSString*)srcString{
    NSRange rs = [srcString rangeOfString:searchStr options:NSBackwardsSearch];
    if (rs.location == NSNotFound) {
        return -1;
    }
    return rs.location;
}


+(BOOL)contains:(NSString*) str inString:(NSString*) scr{
    return [self indexOf:str inString:scr] >= 0;
}

+(BOOL)isValidEmail:(NSString *)str
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:str];
}

+(BOOL)isEqualString:(NSString*) str1 withString:(NSString*) str2{
    
    if ([str1 isEqualToString:str2]) return YES;
    if (str1 == nil || str2 == nil) return NO;
    
    str1 = [[self trim:str1] uppercaseString];
    str2 = [[self trim:str2] uppercaseString];
    
    return [str1 isEqualToString:str2];
}



+(NSString*)subStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr{
    source = [NSString stringWithFormat:@" %@", source];
    NSInteger index = [self indexOf:startStr inString:source];
    if (index == -1) return nil;
    
    index += startStr.length;
    
    NSInteger endIndex = [self indexOf:endStr inString:source fromIndex:index];
    
    if (endIndex == -1) return nil;
    
    return [[source substringFromIndex:index] substringToIndex:endIndex];
}

+(NSDictionary*)deparseJson:(NSString*)jsonString{
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return json;
}

+(NSString*) convertUnicodeEncoding:(NSString*)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *decodevalue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    return [decodevalue stringByRemovingPercentEncoding];
}


@end















